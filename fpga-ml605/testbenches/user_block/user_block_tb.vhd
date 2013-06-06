-------------------------------------------------------------------------------
--  CRUSH
--  Cognitive Radio Universal Software Hardware
--  http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php
--  
--  CRUSH is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--  
--  CRUSH is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License
--  along with CRUSH.  If not, see <http://www.gnu.org/licenses/>.
--  
--  
--  
--  File: user_block_tb.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Tests Spectrum Sensing, User Block Control, and UDP Network
--               interface.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity user_block_tb is
end entity;

architecture RTL of user_block_tb is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component debounce
    generic (
      CLOCK_FREQ        : integer := 100e6;   -- Clock frequency (Hz)
      SAMPLE_TIME       : integer := 10);     -- Time between debounce samples (millseconds)
    port (
      clk               : in    std_logic;    -- Clock
      reset             : in    std_logic;    -- Active high reset
      input_async       : in    std_logic;    -- Asynchronous input to debounce
      input_sync        : out   std_logic);   -- Debounced synchronous input
  end component;

  component edge_detect
    generic (
      EDGE              : string  := "RISING"); -- Rising, Falling, or Both
    port (
      clk               : in    std_logic;
      reset             : in    std_logic;
      input_detect      : in    std_logic;      -- Input data
      edge_detect_stb   : out   std_logic);     -- Edge detected strobe
  end component;

  component usrp_ddr_intf
    generic (
      USE_PHASE_SHIFT         : string  := "FALSE";       -- "TRUE/FALSE", Init MMCM phase to MAN_PHASE_SHIFT on reset
      MAN_PHASE_SHIFT         : integer := 0);            -- MMCM phase shift tap setting (0 - 55)
    port (
      reset                   : in    std_logic;                      -- Asynchronous reset
      -- USRP DDR interface control via UART (sampled by clk_ddr clock domain)
      user_ddr_intf_mode      : in    std_logic_vector(7 downto 0);   -- USRP DDR interface mode
      user_ddr_intf_mode_stb  : in    std_logic;                      -- Strobe to set mode
      UART_TX                 : out   std_logic;                      -- UART
      -- Physical Transmit / Receive data interface
      RX_DATA_CLK_N           : in    std_logic;                      -- Receive data clock (N)
      RX_DATA_CLK_P           : in    std_logic;                      -- Receive data clock (P)
      RX_DATA_N               : in    std_logic_vector(6 downto 0);   -- Receive data (N)
      RX_DATA_P               : in    std_logic_vector(6 downto 0);   -- Receive data (N)
      TX_DATA_N               : out   std_logic_vector(7 downto 0);   -- Transmit data (N)
      TX_DATA_P               : out   std_logic_vector(7 downto 0);   -- Transmit data (P)
      clk_ddr                 : out   std_logic;                      -- MMCM derived clock
      clk_ddr_2x              : out   std_logic;                      -- MMCM derived clock (2x)
      clk_ddr_locked          : out   std_logic;                      -- MMCM DDR data clock locked
      clk_ddr_phase           : out   std_logic_vector(9 downto 0);   -- MMCM phase offset, 0 - 559
      -- Receive data FIFO interface
      clk_rx_fifo             : in    std_logic;                      -- Receive data FIFO clock
      rx_fifo_reset           : in    std_logic;                      -- Receive data FIFO reset
      rx_fifo_data_i          : out   std_logic_vector(13 downto 0);  -- Receive data FIFO output
      rx_fifo_data_q          : out   std_logic_vector(13 downto 0);  -- Receive data FIFO output
      rx_fifo_rd_en           : in    std_logic;                      -- Receive data FIFO read enable
      rx_fifo_underflow       : out   std_logic;                      -- Receive data FIFO underflow
      rx_fifo_almost_empty    : out   std_logic;                      -- Receive data FIFO almost empty
      -- Receive data FIFO interface
      clk_tx_fifo             : in    std_logic;                      -- Transmit data FIFO clock
      tx_fifo_reset           : in    std_logic;                      -- Transmit data FIFO reset
      tx_fifo_data_i          : in    std_logic_vector(15 downto 0);  -- Transmit data FIFO output
      tx_fifo_data_q          : in    std_logic_vector(15 downto 0);  -- Transmit data FIFO output
      tx_fifo_wr_en           : in    std_logic;                      -- Transmit data FIFO write enable
      tx_fifo_overflow        : out   std_logic;                      -- Transmit data FIFO overflow
      tx_fifo_almost_full     : out   std_logic);                     -- Transmit data FIFO almost full
  end component;

  component spectrum_sense
    generic (
      DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
    port (
      clk                   : in    std_logic;                      -- Clock
      reset                 : in    std_logic;                      -- Active high reset
      start_stb             : in    std_logic;                      -- Start spectrum sensing
      busy                  : out   std_logic;                      -- Busy
      done_stb              : out   std_logic;                      -- FFT done, begin data unload on next cycle
      -- FFT
      fft_size              : in    std_logic_vector(4 downto 0);   -- 0 = 64, 1 = 128, 2 = 256, etc...
      xn_real               : in    std_logic_vector(13 downto 0);  -- x(n) time domain signal (real)
      xn_imag               : in    std_logic_vector(13 downto 0);  -- x(n) time domain signal (imag)
      xk_valid              : out   std_logic;                      -- X(k) data valid
      xk_real               : out   std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (real)
      xk_imag               : out   std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (imag)
      xk_index              : out   std_logic_vector(12 downto 0);  -- k
      -- Threshold detection
      xk_magnitude_squared  : out   std_logic_vector(31 downto 0);  -- Magnitude squared, X_r(k)^2 + X_i(k)^2
      threshold             : in    std_logic_vector(31 downto 0);  -- Threshold (Magnitude squared)
      threshold_exceeded    : out   std_logic);                     -- Threshold exceeded. Aligned with X(k) data
  end component;

  component bpsk_tx
    port (
      clk                   : in    std_logic;                      -- Clock
      reset                 : in    std_logic;                      -- Active high reset
      -- Control data bus
      mode                  : in    std_logic_vector(1 downto 0);   -- 0 = BPSK, 1 = CW, 2 = PRN data, 3 = Test Pattern
      freq                  : in    std_logic_vector(15 downto 0);  -- Carrier Offset Frequency
      data_freq             : in    std_logic_vector(15 downto 0);  -- Psuedo-Random Data Frequency
      -- I & Q data bus
      i                     : out   std_logic_vector(15 downto 0);  -- Inphase
      q                     : out   std_logic_vector(15 downto 0)); -- Quadrature
  end component;

  component user_block_ctrl
    generic (
      DEVICE                      : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
    port (
      clk                         : in    std_logic;                      -- Clock
      reset                       : in    std_logic;                      -- Active high reset
      -- Network configuration
      user_mac_addr_src           : in    std_logic_vector(47 downto 0);  -- Filter Source MAC address (0 for any)
      user_mac_addr_dest          : in    std_logic_vector(47 downto 0);  -- Destination MAC address
      user_ip_addr_src            : in    std_logic_vector(31 downto 0);  -- Filter Source IP address (0 for any)
      user_ip_addr_dest           : in    std_logic_vector(31 downto 0);  -- Destination IP address
      user_port_src               : in    std_logic_vector(15 downto 0);  -- Filter Source Port (0 for any)
      user_port_dest              : in    std_logic_vector(15 downto 0);  -- Destination Port
      user_payload_size           : in    std_logic_vector(10 downto 0);  -- Size of transmitted payload. Max 1472, reduce if needed.
      -- Manual control interface (versus using UDP control packets)
      override_network_ctrl       : in    std_logic;                      -- Override UDP control interface (set this first)
      man_spec_sense_start_stb    : in    std_logic;                      -- Start spectrum sensing
      man_send_fft_data           : in    std_logic;                      -- Enable sending FFT results via UDP
      man_send_mag_squared        : in    std_logic;                      -- Enable sending FFT magnitude squared via UDP
      man_send_threshold          : in    std_logic;                      -- Enable sending threshold results via UDP
      man_send_counting_pattern   : in    std_logic;                      -- Enable sending the debug counting pattern
      man_fft_size                : in    std_logic_vector(4 downto 0);   -- FFT Size
      man_threshold               : in    std_logic_vector(31 downto 0);  -- Threshold (Magnitude squared)
      man_user_ddr_intf_mode      : in    std_logic_vector(7 downto 0);   -- USRP DDR interface mode
      man_user_ddr_intf_mode_stb  : in    std_logic;                      -- Strobe to set mode
      man_bpsk_mode               : in    std_logic_vector(1 downto 0);   -- 0 = BPSK, 1 = CW, 2 = PRN data, 3 = Test Pattern
      man_bpsk_freq               : in    std_logic_vector(15 downto 0);  -- Carrier Offset Frequency
      man_bpsk_data_freq          : in    std_logic_vector(15 downto 0);  -- Psuedo-Random Data Frequency
      -- ML605 to USRP DDR Interface
      user_ddr_intf_mode          : out   std_logic_vector(7 downto 0);   -- USRP DDR interface mode
      user_ddr_intf_mode_stb      : out   std_logic;                      -- Strobe to set mode
      -- BPSK Transmit Waveform Generator
      bpsk_mode                   : out   std_logic_vector(1 downto 0);   -- 0 = BPSK, 1 = CW, 2 = PRN data, 3 = Test Pattern
      bpsk_freq                   : out   std_logic_vector(15 downto 0);  -- Carrier Offset Frequency
      bpsk_data_freq              : out   std_logic_vector(15 downto 0);  -- Psuedo-Random Data Frequency
      -- Spectrum Sensing User Block
      spec_sense_start_stb        : out   std_logic;                      -- Enable sending threshold results via UDP
      spec_sense_busy             : in    std_logic;                      -- Busy
      spec_sense_done_stb         : in    std_logic;                      -- FFT done, begin data unload on next cycle
      fft_size                    : out   std_logic_vector(4 downto 0);   -- 0 = 64, 1 = 128, etc...
      xk_valid                    : in    std_logic;                      -- X(k) data valid
      xk_real                     : in    std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (real)
      xk_imag                     : in    std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (imag)
      xk_index                    : in    std_logic_vector(12 downto 0);  -- k
      xk_magnitude_squared        : in    std_logic_vector(31 downto 0);  -- Magnitude squared, X_r(k)^2 + X_i(k)^2
      threshold                   : out   std_logic_vector(31 downto 0);  -- Threshold (Magnitude squared)
      threshold_exceeded          : in    std_logic;                      -- Threshold exceeded. Aligned with X(k) data
      -- User RX interface
      -- User receive data filter. Payload is discarded if any of the following do not match.
      -- If a value is set to 0, any value will be accepted.
      rx_mac_addr_src             : out   std_logic_vector(47 downto 0);  -- Filter Source MAC address
      rx_mac_addr_dest            : out   std_logic_vector(47 downto 0);  -- Filter Destination MAC address
      rx_ip_addr_src              : out   std_logic_vector(31 downto 0);  -- Filter Source IP address
      rx_ip_addr_dest             : out   std_logic_vector(31 downto 0);  -- Filter Destination IP address
      rx_port_src                 : out   std_logic_vector(15 downto 0);  -- Filter Source Port
      rx_port_dest                : out   std_logic_vector(15 downto 0);  -- Filter Destination Port
      -- User RX data interface
      rx_done_stb                 : in    std_logic;                      -- Received UDP transmission
      rx_busy                     : in    std_logic;                      -- Receiving ethernet data
      rx_frame_error              : in    std_logic;                      -- Error detected
      rx_payload_size             : in    std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      rx_payload_data             : in    std_logic_vector(7 downto 0);   -- Output FIFO data
      rx_payload_data_rd_en       : out   std_logic;                      -- Output FIFO read enable
      rx_payload_almost_empty     : in    std_logic;                      -- Output FIFO almost empty
      -- User TX interface
      -- User TX Ethernet frame, IP header, & UDP header configuration
      tx_mac_addr_src             : out   std_logic_vector(47 downto 0);  -- Source MAC address
      tx_mac_addr_dest            : out   std_logic_vector(47 downto 0);  -- Destination MAC address
      tx_ip_addr_src              : out   std_logic_vector(31 downto 0);  -- Source IP address
      tx_ip_addr_dest             : out   std_logic_vector(31 downto 0);  -- Destination IP address
      tx_port_src                 : out   std_logic_vector(15 downto 0);  -- Source Port
      tx_port_dest                : out   std_logic_vector(15 downto 0);  -- Destination Port
      -- User TX data interface
      tx_start_stb                : out   std_logic;                      -- Start UDP transmission
      tx_busy                     : in    std_logic;                      -- UDP transmission in process
      tx_payload_size             : out   std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      tx_payload_data             : out   std_logic_vector(7 downto 0);   -- Input FIFO data
      tx_payload_data_wr_en       : out   std_logic;                      -- Input FIFO write enable
      tx_payload_almost_full      : in    std_logic);                     -- Input FIFO almost full
  end component;

  component udp_tx
    generic (
      DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
    port (
      -- User interface
      clk                   : in    std_logic;                      -- Clock (FIFO)
      reset                 : in    std_logic;                      -- Active high reset
      -- User Ethernet frame, IP header, & UDP header configuration
      mac_addr_src          : in    std_logic_vector(47 downto 0);  -- Source MAC address
      mac_addr_dest         : in    std_logic_vector(47 downto 0);  -- Destination MAC address
      ip_addr_src           : in    std_logic_vector(31 downto 0);  -- Source IP address
      ip_addr_dest          : in    std_logic_vector(31 downto 0);  -- Destination IP address
      port_src              : in    std_logic_vector(15 downto 0);  -- Source Port
      port_dest             : in    std_logic_vector(15 downto 0);  -- Destination Port
      -- User data interface
      start_stb             : in    std_logic;                      -- Start UDP transmission
      busy                  : out   std_logic;                      -- UDP transmission in process
      payload_size          : in    std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      payload_data          : in    std_logic_vector(7 downto 0);   -- Input FIFO data
      payload_data_wr_en    : in    std_logic;                      -- Input FIFO write enable
      payload_almost_full   : out   std_logic;                      -- Input FIFO almost full
      -- Tri-Mode Ethernet MAC AXI Interface
      tx_mac_aclk           : in    std_logic;                      -- TX clock (same as clk)
      tx_reset              : in    std_logic;                      -- TX reset
      tx_axis_mac_tdata     : out   std_logic_vector(7 downto 0);   -- Frame data
      tx_axis_mac_tvalid    : out   std_logic;                      -- Frame data valid
      tx_axis_mac_tlast     : out   std_logic;                      -- Last frame
      tx_axis_mac_tuser     : out   std_logic;                      -- Frame error (FIFO underrun)
      tx_axis_mac_tready    : in    std_logic);                     -- Ready for data
  end component;

  component udp_rx
    generic (
      DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
    port (
      -- User interface
      clk                   : in    std_logic;                      -- Clock (FIFO)
      reset                 : in    std_logic;                      -- Active high reset
      -- User receive data filter. Payload is discarded if any of the following do not match.
      -- If a value is set to 0, any value will be accepted.
      mac_addr_src          : in    std_logic_vector(47 downto 0);  -- Filter Source MAC address
      mac_addr_dest         : in    std_logic_vector(47 downto 0);  -- Filter Destination MAC address
      ip_addr_src           : in    std_logic_vector(31 downto 0);  -- Filter Source IP address
      ip_addr_dest          : in    std_logic_vector(31 downto 0);  -- Filter Destination IP address
      port_src              : in    std_logic_vector(15 downto 0);  -- Filter Source Port
      port_dest             : in    std_logic_vector(15 downto 0);  -- Filter Destination Port
      -- User data interface
      done_stb              : out   std_logic;                      -- Received UDP transmission
      busy                  : out   std_logic;                      -- Receiving ethernet data
      frame_error           : out   std_logic;                      -- Error detected
      payload_size          : out   std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      payload_data          : out   std_logic_vector(7 downto 0);   -- Output FIFO data
      payload_data_rd_en    : in    std_logic;                      -- Output FIFO read enable
      payload_almost_empty  : out   std_logic;                      -- Output FIFO almost empty
      -- Tri-Mode Ethernet MAC AXI Interface
      rx_mac_aclk           : in    std_logic;                      -- RX clock
      rx_reset              : in    std_logic;                      -- Reset from EMAC
      rx_axis_mac_tdata     : in    std_logic_vector(7 downto 0);   -- Frame data
      rx_axis_mac_tvalid    : in    std_logic;                      -- Frame data valid
      rx_axis_mac_tlast     : in    std_logic;                      -- Last frame
      rx_axis_mac_tuser     : in    std_logic);                     -- Frame error
  end component;

  component crush_ddr_intf is
    port (
      clk               : in    std_logic;            -- Clock (from ADC)
      reset             : in    std_logic;            -- Active high reset
      RX_DATA_CLK_N     : out   std_logic;            -- RX data clock (P)
      RX_DATA_CLK_P     : out   std_logic;            -- RX data clock (N)
      RX_DATA_N         : out   std_logic_vector(6 downto 0);  -- RX data (P)
      RX_DATA_P         : out   std_logic_vector(6 downto 0);  -- RX data (N)
      TX_DATA_N         : in    std_logic_vector(7 downto 0);  -- TX data (P)
      TX_DATA_P         : in    std_logic_vector(7 downto 0);  -- TX data (N)
      UART_RX           : in    std_logic;            -- Control interface from CRUSH (RX)
      adc_channel_a     : in    std_logic_vector(13 downto 0);  -- ADC data channel a, Raw data from ADC
      adc_channel_b     : in    std_logic_vector(13 downto 0);  -- ADC data channel b, Raw data from ADC
      adc_i             : in    std_logic_vector(23 downto 0);  -- ADC data I, With DC offset correction & IQ Balance
      adc_q             : in    std_logic_vector(23 downto 0);  -- ADC data Q, With DC offset correction & IQ Balance
      dac_channel_a_in  : in    std_logic_vector(15 downto 0);  -- DAC data channel a from USRP (for muxing purposes)
      dac_channel_b_in  : in    std_logic_vector(15 downto 0);  -- DAC data channel b from USRP (for muxing purposes)
      dac_i_in          : in    std_logic_vector(23 downto 0);  -- DAC data I from USRP (for muxing purposes)
      dac_q_in          : in    std_logic_vector(23 downto 0);  -- DAC data Q from USRP (for muxing purposes)
      dac_channel_a     : out   std_logic_vector(15 downto 0);  -- DAC data channel a, Raw data to DAC
      dac_channel_b     : out   std_logic_vector(15 downto 0);  -- DAC data channel b, Raw data to DAC
      dac_i             : out   std_logic_vector(23 downto 0);  -- DAC data I, USRP corrects DC offset correction & IQ Balance
      dac_q             : out   std_logic_vector(23 downto 0)); -- DAC data Q, USRP corrects DC offset correction & IQ Balance
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant DEVICE                 : string := "VIRTEX6";
  constant ClockRate_100MHz       : real   := 100.0e6;
  constant ClockPeriod_100MHz     : time   := (1.0e12/ClockRate_100MHz)*(1 ps);
  constant ClockRate_125MHz       : real   := 125.0e6;
  constant ClockPeriod_125MHz     : time   := (1.0e12/ClockRate_125MHz)*(1 ps);
  constant Timeout                : time   := 5 sec;

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  -- Clocks, Resets
  signal reset                    : std_logic;
  signal reset_n                  : std_logic;
  signal clk_100MHz               : std_logic;
  signal clk_125MHz               : std_logic;

  -- usrp_ddr_intf
  signal user_ddr_intf_mode         : std_logic_vector(7 downto 0);
  signal user_ddr_intf_mode_stb     : std_logic;
  signal rx_data_clk                : std_logic;
  signal rx_data_clk_locked         : std_logic;
  signal clk_ddr_phase              : std_logic_vector(9 downto 0);
  signal reset_rx_data_clk          : std_logic;
  signal adc_data_i                 : std_logic_vector(13 downto 0);
  signal adc_data_q                 : std_logic_vector(13 downto 0);
  signal dac_data_i                 : std_logic_vector(15 downto 0);
  signal dac_data_q                 : std_logic_vector(15 downto 0);
  signal rx_fifo_almost_empty       : std_logic;
  signal rx_fifo_almost_empty_n     : std_logic;
  signal tx_fifo_almost_full        : std_logic;
  signal tx_fifo_almost_full_n      : std_logic;

  -- udp_rx, udp_tx
  signal rx_mac_addr_src          : std_logic_vector(47 downto 0);
  signal rx_mac_addr_dest         : std_logic_vector(47 downto 0);
  signal rx_ip_addr_src           : std_logic_vector(31 downto 0);
  signal rx_ip_addr_dest          : std_logic_vector(31 downto 0);
  signal rx_port_src              : std_logic_vector(15 downto 0);
  signal rx_port_dest             : std_logic_vector(15 downto 0);
  signal rx_done_stb              : std_logic;
  signal rx_busy                  : std_logic;
  signal rx_frame_error           : std_logic;
  signal rx_payload_size          : std_logic_vector(10 downto 0);
  signal rx_payload_data          : std_logic_vector(7 downto 0);
  signal rx_payload_data_rd_en    : std_logic;
  signal rx_payload_almost_empty  : std_logic;
  signal rx_mac_aclk              : std_logic;
  signal rx_reset                 : std_logic;
  signal rx_axis_mac_tdata        : std_logic_vector(7 downto 0);
  signal rx_axis_mac_tvalid       : std_logic;
  signal rx_axis_mac_tlast        : std_logic;
  signal rx_axis_mac_tuser        : std_logic;
  signal tx_mac_addr_src          : std_logic_vector(47 downto 0);
  signal tx_mac_addr_dest         : std_logic_vector(47 downto 0);
  signal tx_ip_addr_src           : std_logic_vector(31 downto 0);
  signal tx_ip_addr_dest          : std_logic_vector(31 downto 0);
  signal tx_port_src              : std_logic_vector(15 downto 0);
  signal tx_port_dest             : std_logic_vector(15 downto 0);
  signal tx_start_stb             : std_logic;
  signal tx_busy                  : std_logic;
  signal tx_payload_size          : std_logic_vector(10 downto 0);
  signal tx_payload_data          : std_logic_vector(7 downto 0);
  signal tx_payload_data_wr_en    : std_logic;
  signal tx_payload_almost_full   : std_logic;
  signal tx_mac_aclk              : std_logic;
  signal tx_reset                 : std_logic;
  signal tx_axis_mac_tdata        : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid       : std_logic;
  signal tx_axis_mac_tlast        : std_logic;
  signal tx_axis_mac_tuser        : std_logic;
  signal tx_axis_mac_tready       : std_logic;
    
  -- spectrum_sense
  signal spec_sense_start_stb     : std_logic;
  signal spec_sense_busy          : std_logic;
  signal spec_sense_done_stb      : std_logic;
  signal fft_size                 : std_logic_vector(4 downto 0);
  signal xk_valid                 : std_logic;
  signal xk_real                  : std_logic_vector(15 downto 0);
  signal xk_imag                  : std_logic_vector(15 downto 0);
  signal xk_index                 : std_logic_vector(12 downto 0);
  signal xk_magnitude_squared     : std_logic_vector(31 downto 0);
  signal threshold                : std_logic_vector(31 downto 0);
  signal threshold_exceeded       : std_logic;

  -- bpsk_tx
  signal bpsk_mode                  : std_logic_vector(1 downto 0);
  signal bpsk_freq                  : std_logic_vector(15 downto 0);
  signal bpsk_data_freq             : std_logic_vector(15 downto 0);

  -- user_block_ctrl
  signal user_mac_addr_src          : std_logic_vector(47 downto 0);
  signal user_mac_addr_dest         : std_logic_vector(47 downto 0);
  signal user_ip_addr_src           : std_logic_vector(31 downto 0);
  signal user_ip_addr_dest          : std_logic_vector(31 downto 0);
  signal user_port_src              : std_logic_vector(15 downto 0);
  signal user_port_dest             : std_logic_vector(15 downto 0);
  signal user_payload_size          : std_logic_vector(10 downto 0);
  signal override_network_ctrl      : std_logic;
  signal man_spec_sense_start_stb   : std_logic;
  signal man_send_fft_data          : std_logic;
  signal man_send_mag_squared       : std_logic;
  signal man_send_threshold         : std_logic;
  signal man_send_counting_pattern  : std_logic;
  signal man_fft_size               : std_logic_vector(4 downto 0);
  signal man_threshold              : std_logic_vector(31 downto 0);
  signal man_user_ddr_intf_mode_stb : std_logic;
  signal man_user_ddr_intf_mode     : std_logic_vector(7 downto 0);
  signal man_bpsk_mode              : std_logic_vector(1 downto 0);
  signal man_bpsk_freq              : std_logic_vector(15 downto 0);
  signal man_bpsk_data_freq         : std_logic_vector(15 downto 0);

  -- crush_ddr_intf
  signal RX_DATA_CLK_N              : std_logic;
  signal RX_DATA_CLK_P              : std_logic;
  signal RX_DATA_N                  : std_logic_vector(6 downto 0);
  signal RX_DATA_P                  : std_logic_vector(6 downto 0);
  signal TX_DATA_N                  : std_logic_vector(7 downto 0);
  signal TX_DATA_P                  : std_logic_vector(7 downto 0);
  signal UART_TX                    : std_logic;
  signal adc_channel_a              : std_logic_vector(13 downto 0);
  signal adc_channel_b              : std_logic_vector(13 downto 0);
  signal adc_i                      : std_logic_vector(23 downto 0);
  signal adc_q                      : std_logic_vector(23 downto 0);
  signal dac_channel_a_in           : std_logic_vector(15 downto 0);
  signal dac_channel_b_in           : std_logic_vector(15 downto 0);
  signal dac_i_in                   : std_logic_vector(23 downto 0);
  signal dac_q_in                   : std_logic_vector(23 downto 0);
  signal dac_channel_a              : std_logic_vector(15 downto 0);
  signal dac_channel_b              : std_logic_vector(15 downto 0);
  signal dac_i                      : std_logic_vector(23 downto 0);
  signal dac_q                      : std_logic_vector(23 downto 0);

  -- Testbench signals
  type udp_packet_type is array(0 to 52) of std_logic_vector(7 downto 0);
  signal udp_packet_1 : udp_packet_type := 
    (x"18",x"03",x"73",x"29",x"AE",x"42", -- MAC destination address
     x"00",x"0A",x"35",x"02",x"50",x"A3", -- MAC source address
     x"08",x"00",x"45",x"00",             -- Type, Version, IHL, DSCP, ECN
     x"00",x"27",                         -- Total size (+28 due to IP and UDP header)
     x"00",x"00",x"00",x"00",x"40",x"11", -- Indentification, Flags, Fragment Offset, Time To Live, Protocol (UDP)
     x"4C",x"77",                         -- Checksum
     x"0C",x"A8",x"0A",x"01",             -- Source IP
     x"0C",x"A8",x"0A",x"FF",             -- Destination IP
     x"23",x"82",                         -- Source Port
     x"23",x"83",                         -- Destination Port
     x"00",x"13",                         -- UDP Payload Size (+8 byte UDP header)
     x"00",x"00",                         -- Checksum (0 is valid)
     -- Commands
     x"A5",                               -- Integrity Check Header
     x"05",                               -- Command: Set USRP mode
     x"11",                               -- ADC Raw Mode, DAC Raw Mode
     x"06",                               -- Command: Set BPSK Mode
     x"01",                               -- PRN Data
     x"07",                               -- Command: Set BPSK Freq
     x"01",x"FF",                         -- Frequency
     x"08",                               -- Command: Set BPSK Data Freq
     x"00",x"10");                        -- Frequency
  signal udp_packet_2 : udp_packet_type := 
    (x"18",x"03",x"73",x"29",x"AE",x"42", -- MAC destination address
     x"00",x"0A",x"35",x"02",x"50",x"A3", -- MAC source address
     x"08",x"00",x"45",x"00",             -- Type, Version, IHL, DSCP, ECN
     x"00",x"27",                         -- Total size (+28 due to IP and UDP header)
     x"00",x"00",x"00",x"00",x"40",x"11", -- Indentification, Flags, Fragment Offset, Time To Live, Protocol (UDP)
     x"4C",x"77",                         -- Checksum
     x"0C",x"A8",x"0A",x"01",             -- Source IP
     x"0C",x"A8",x"0A",x"FF",             -- Destination IP
     x"23",x"82",                         -- Source Port
     x"23",x"83",                         -- Destination Port
     x"00",x"13",                         -- UDP Payload Size (+8 byte UDP header)
     x"00",x"00",                         -- Checksum (0 is valid)
     -- Commands
     x"A5",                               -- Integrity Check Header
     x"02",                               -- Command: Set configuration word
     x"07",                               -- Configuration word
     x"03",                               -- Command: Set FFT size
     x"1F",                               -- FFT size 8192
     x"04",                               -- Command: Set threshold
     x"00",x"00",x"1F",x"FF",             -- Threshold
     x"01");                              -- Command: Start spectrum sensing

begin

  -----------------------------------------------------------------------------
  -- ML605 <-> USRP Interface
  -----------------------------------------------------------------------------
  inst_usrp_ddr_intf : usrp_ddr_intf
    generic map (
      USE_PHASE_SHIFT             => "FALSE",
      MAN_PHASE_SHIFT             => 0)
    port map (
      reset                       => reset,
      user_ddr_intf_mode          => user_ddr_intf_mode,
      user_ddr_intf_mode_stb      => user_ddr_intf_mode_stb,
      UART_TX                     => UART_TX,
      RX_DATA_CLK_N               => RX_DATA_CLK_N,
      RX_DATA_CLK_P               => RX_DATA_CLK_P,
      RX_DATA_N                   => RX_DATA_N,
      RX_DATA_P                   => RX_DATA_P,
      TX_DATA_N                   => TX_DATA_N,
      TX_DATA_P                   => TX_DATA_P,
      clk_ddr                     => rx_data_clk,
      clk_ddr_2x                  => open,
      clk_ddr_locked              => rx_data_clk_locked,
      clk_ddr_phase               => clk_ddr_phase,
      clk_rx_fifo                 => rx_data_clk,
      rx_fifo_reset               => '0',
      rx_fifo_data_i              => adc_data_i,
      rx_fifo_data_q              => adc_data_q,
      rx_fifo_rd_en               => rx_fifo_almost_empty_n,
      rx_fifo_underflow           => open,
      rx_fifo_almost_empty        => rx_fifo_almost_empty,
      clk_tx_fifo                 => rx_data_clk,
      tx_fifo_reset               => '0',
      tx_fifo_data_i              => dac_data_i,
      tx_fifo_data_q              => dac_data_q,
      tx_fifo_wr_en               => tx_fifo_almost_full_n,
      tx_fifo_overflow            => open,
      tx_fifo_almost_full         => tx_fifo_almost_full);

  reset_rx_data_clk               <= NOT(rx_data_clk_locked);
  rx_fifo_almost_empty_n          <= NOT(rx_fifo_almost_empty);
  tx_fifo_almost_full_n           <= NOT(tx_fifo_almost_full);

  -----------------------------------------------------------------------------
  -- ML605 <-> Host UDP packet interface
  -----------------------------------------------------------------------------
  inst_udp_tx : udp_tx
    generic map (
      DEVICE                => DEVICE)
    port map (
      clk                   => rx_data_clk,
      reset                 => reset_rx_data_clk,
      mac_addr_src          => tx_mac_addr_src,
      mac_addr_dest         => tx_mac_addr_dest,
      ip_addr_src           => tx_ip_addr_src,
      ip_addr_dest          => tx_ip_addr_dest,
      port_src              => tx_port_src,
      port_dest             => tx_port_dest,
      start_stb             => tx_start_stb,
      busy                  => tx_busy,
      payload_size          => tx_payload_size,
      payload_data          => tx_payload_data,
      payload_data_wr_en    => tx_payload_data_wr_en,
      payload_almost_full   => tx_payload_almost_full,
      tx_mac_aclk           => tx_mac_aclk,
      tx_reset              => tx_reset,
      tx_axis_mac_tdata     => tx_axis_mac_tdata,
      tx_axis_mac_tvalid    => tx_axis_mac_tvalid,
      tx_axis_mac_tlast     => tx_axis_mac_tlast,
      tx_axis_mac_tuser     => tx_axis_mac_tuser,
      tx_axis_mac_tready    => tx_axis_mac_tready);

  tx_mac_aclk               <= clk_125MHz;

  inst_udp_rx : udp_rx
  generic map (
    DEVICE                  => DEVICE)
  port map (
    clk                     => rx_data_clk,
    reset                   => reset_rx_data_clk,
    mac_addr_src            => rx_mac_addr_src,
    mac_addr_dest           => rx_mac_addr_dest,
    ip_addr_src             => rx_ip_addr_src,
    ip_addr_dest            => rx_ip_addr_dest,
    port_src                => rx_port_src,
    port_dest               => rx_port_dest,
    done_stb                => rx_done_stb,
    busy                    => rx_busy,
    frame_error             => rx_frame_error,
    payload_size            => rx_payload_size,
    payload_data            => rx_payload_data,
    payload_data_rd_en      => rx_payload_data_rd_en,
    payload_almost_empty    => rx_payload_almost_empty,
    rx_mac_aclk             => rx_mac_aclk,
    rx_reset                => rx_reset,
    rx_axis_mac_tdata       => rx_axis_mac_tdata,
    rx_axis_mac_tvalid      => rx_axis_mac_tvalid,
    rx_axis_mac_tlast       => rx_axis_mac_tlast,
    rx_axis_mac_tuser       => rx_axis_mac_tuser);

  rx_mac_aclk               <= clk_125MHz;

  -----------------------------------------------------------------------------
  -- User modules: Spectrum Sensing and User block control
  -----------------------------------------------------------------------------
  inst_spectrum_sense : spectrum_sense
    generic map (
      DEVICE                      => DEVICE)
    port map (
      clk                         => rx_data_clk,
      reset                       => reset_rx_data_clk,
      start_stb                   => spec_sense_start_stb,
      busy                        => spec_sense_busy,
      done_stb                    => spec_sense_done_stb,
      fft_size                    => fft_size,
      xn_real                     => adc_data_i,
      xn_imag                     => adc_data_q,
      xk_valid                    => xk_valid,
      xk_real                     => xk_real,
      xk_imag                     => xk_imag,
      xk_index                    => xk_index,    -- Note: Data is in natural order
      xk_magnitude_squared        => xk_magnitude_squared,
      threshold                   => threshold,
      threshold_exceeded          => threshold_exceeded);

  inst_bpsk_tx : bpsk_tx
    port map (
      clk                         => rx_data_clk,
      reset                       => reset_rx_data_clk,
      mode                        => bpsk_mode,
      freq                        => bpsk_freq,
      data_freq                   => bpsk_data_freq,
      i                           => dac_data_i,
      q                           => dac_data_q);

  inst_user_block_ctrl : user_block_ctrl
    generic map (
      DEVICE                      => DEVICE)
    port map (
      clk                         => rx_data_clk,
      reset                       => reset_rx_data_clk,
      user_mac_addr_src           => user_mac_addr_src,
      user_mac_addr_dest          => user_mac_addr_dest,
      user_ip_addr_src            => user_ip_addr_src,
      user_ip_addr_dest           => user_ip_addr_dest,
      user_port_src               => user_port_src,
      user_port_dest              => user_port_dest,
      user_payload_size           => user_payload_size,
      override_network_ctrl       => override_network_ctrl,
      man_spec_sense_start_stb    => man_spec_sense_start_stb,
      man_send_fft_data           => man_send_fft_data,
      man_send_mag_squared        => man_send_mag_squared,
      man_send_threshold          => man_send_threshold,
      man_send_counting_pattern   => man_send_counting_pattern,
      man_fft_size                => man_fft_size,
      man_threshold               => man_threshold,
      man_user_ddr_intf_mode      => man_user_ddr_intf_mode,
      man_user_ddr_intf_mode_stb  => man_user_ddr_intf_mode_stb,
      man_bpsk_mode               => man_bpsk_mode,
      man_bpsk_freq               => man_bpsk_freq,
      man_bpsk_data_freq          => man_bpsk_data_freq,
      user_ddr_intf_mode          => user_ddr_intf_mode,
      user_ddr_intf_mode_stb      => user_ddr_intf_mode_stb,
      bpsk_mode                   => bpsk_mode,
      bpsk_freq                   => bpsk_freq,
      bpsk_data_freq              => bpsk_data_freq,
      spec_sense_start_stb        => spec_sense_start_stb,
      spec_sense_busy             => spec_sense_busy,
      spec_sense_done_stb         => spec_sense_done_stb,
      fft_size                    => fft_size,
      xk_valid                    => xk_valid,
      xk_real                     => xk_real,
      xk_imag                     => xk_imag,
      xk_index                    => xk_index,
      xk_magnitude_squared        => xk_magnitude_squared,
      threshold                   => threshold,
      threshold_exceeded          => threshold_exceeded,
      rx_mac_addr_src             => rx_mac_addr_src,
      rx_mac_addr_dest            => rx_mac_addr_dest,
      rx_ip_addr_src              => rx_ip_addr_src,
      rx_ip_addr_dest             => rx_ip_addr_dest,
      rx_port_src                 => rx_port_src,
      rx_port_dest                => rx_port_dest,
      rx_done_stb                 => rx_done_stb,
      rx_busy                     => rx_busy,
      rx_frame_error              => rx_frame_error,
      rx_payload_size             => rx_payload_size,
      rx_payload_data             => rx_payload_data,
      rx_payload_data_rd_en       => rx_payload_data_rd_en,
      rx_payload_almost_empty     => rx_payload_almost_empty,
      tx_mac_addr_src             => tx_mac_addr_src,
      tx_mac_addr_dest            => tx_mac_addr_dest,
      tx_ip_addr_src              => tx_ip_addr_src,
      tx_ip_addr_dest             => tx_ip_addr_dest,
      tx_port_src                 => tx_port_src,
      tx_port_dest                => tx_port_dest,
      tx_start_stb                => tx_start_stb,
      tx_busy                     => tx_busy,
      tx_payload_size             => tx_payload_size,
      tx_payload_data             => tx_payload_data,
      tx_payload_data_wr_en       => tx_payload_data_wr_en,
      tx_payload_almost_full      => tx_payload_almost_full);

  -----------------------------------------------------------------------------
  -- Network configuration
  -----------------------------------------------------------------------------
  user_mac_addr_src               <= x"000A350250A3";
  user_mac_addr_dest              <= x"18037329AE42";
  user_ip_addr_src                <= x"0CA80A01"; -- 192.168.10.1
  user_ip_addr_dest               <= x"0CA80AFF"; -- 192.168.10.255, listen for broadcast
  user_port_src                   <= std_logic_vector(to_unsigned(9090,16));
  user_port_dest                  <= std_logic_vector(to_unsigned(9091,16));
  user_payload_size               <= std_logic_vector(to_unsigned(1472,11));
  override_network_ctrl           <= '0';
  man_spec_sense_start_stb        <= '0';
  man_send_fft_data               <= '0';
  man_send_mag_squared            <= '0';
  man_send_threshold              <= '0';
  man_fft_size                    <= (others=>'0');
  man_threshold                   <= (others=>'0');
  man_user_ddr_intf_mode_stb      <= '0';
  man_user_ddr_intf_mode          <= (others=>'0');
  man_bpsk_mode                   <= (others=>'0');
  man_bpsk_freq                   <= (others=>'0');
  man_bpsk_data_freq              <= (others=>'0');

  -----------------------------------------------------------------------------
  -- CRUSH DDR Interface (on USRP)
  -----------------------------------------------------------------------------
  inst_crush_ddr_intf : crush_ddr_intf
    port map (
      clk                         => clk_100MHz,
      reset                       => reset,
      RX_DATA_CLK_N               => RX_DATA_CLK_N,
      RX_DATA_CLK_P               => RX_DATA_CLK_P,
      RX_DATA_N                   => RX_DATA_N,
      RX_DATA_P                   => RX_DATA_P,
      TX_DATA_N                   => TX_DATA_N,
      TX_DATA_P                   => TX_DATA_P,
      UART_RX                     => UART_TX,
      adc_channel_a               => adc_channel_a,
      adc_channel_b               => adc_channel_b,
      adc_i                       => adc_i,
      adc_q                       => adc_q,
      dac_channel_a_in            => dac_channel_a_in,
      dac_channel_b_in            => dac_channel_b_in,
      dac_i_in                    => dac_i_in,
      dac_q_in                    => dac_q_in,
      dac_channel_a               => dac_channel_a,
      dac_channel_b               => dac_channel_b,
      dac_i                       => dac_i,
      dac_q                       => dac_q);

  dac_channel_a_in                <= (others=>'0');
  dac_channel_b_in                <= (others=>'0');
  dac_i_in                        <= (others=>'0');
  dac_q_in                        <= (others=>'0');

  -------------------------------------------------------------------------------
  -- Create Clock Process, 100 MHz
  -------------------------------------------------------------------------------
  proc_create_clock_100MHz : process
  begin
    clk_100MHz        <= '0';
    wait for ClockPeriod_100MHz/2;
    clk_100MHz        <= '1';
    wait for ClockPeriod_100MHz/2;
  end process;

  -------------------------------------------------------------------------------
  -- Create Clock Process, 125 MHz
  -------------------------------------------------------------------------------
  proc_create_clock_125MHz : process
  begin
    clk_125MHz        <= '0';
    wait for ClockPeriod_125MHz/2;
    clk_125MHz        <= '1';
    wait for ClockPeriod_125MHz/2;
  end process;

  -------------------------------------------------------------------------------
  -- Reset Process
  -------------------------------------------------------------------------------
  proc_reset : process
  begin
    reset             <= '1';
    wait for 300 ns;
    reset             <= '0';
    wait;
  end process;
  reset_n             <= NOT(reset);

  -------------------------------------------------------------------------------
  -- Timeout Process
  -------------------------------------------------------------------------------
  proc_timeout : process
  begin
    wait for Timeout;
    assert(FALSE)
      report "ERROR: Simulation timed out."
      severity FAILURE;
    wait;
  end process;

  -------------------------------------------------------------------------------
  -- Create ADC Data
  -------------------------------------------------------------------------------
  proc_create_adc_data : process
    variable PHASE_ACCUM  : real := 0.0;
  begin
    wait until reset = '1';
    loop
      PHASE_ACCUM         := PHASE_ACCUM + 2.0*MATH_PI*1.0/100.0;
      if (PHASE_ACCUM > 2.0*MATH_PI) then
        PHASE_ACCUM       := PHASE_ACCUM - 2.0*MATH_PI;
      end if;
      adc_channel_a       <= std_logic_vector(to_signed(integer(round((2.0**13.0-1.0)*cos(PHASE_ACCUM))),14));
      adc_i               <= std_logic_vector(to_signed(integer(round((2.0**13.0-1.0)*cos(PHASE_ACCUM))),24));
      adc_channel_b       <= std_logic_vector(to_signed(integer(round((2.0**13.0-1.0)*sin(PHASE_ACCUM))),14));
      adc_q               <= std_logic_vector(to_signed(integer(round((2.0**13.0-1.0)*sin(PHASE_ACCUM))),24));
      wait until clk_100MHz = '1';
    end loop;
  end process;

  -------------------------------------------------------------------------------
  -- Test Bench, Send Configuration and Start Spectrum Sensing packet
  -------------------------------------------------------------------------------
  proc_test_bench_send_config : process
  begin
    rx_reset              <= '1';
    rx_axis_mac_tdata     <= (others=>'0');
    rx_axis_mac_tvalid    <= '0';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tuser     <= '0';

    -- Wait for reset
    wait until reset_rx_data_clk = '0';
    -- Align simulation time with rising clock edge
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_reset              <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    for i in 0 to 51 loop
      rx_axis_mac_tdata   <= udp_packet_1(i);
      rx_axis_mac_tvalid  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tdata     <= udp_packet_1(52);
    rx_axis_mac_tlast     <= '1';
    rx_axis_mac_tvalid    <= '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    -- Wait for interface to calibrate, then start spectrum sensing
    wait for 2 ms;
    wait until clk_125MHz = '1';

    for i in 0 to 51 loop
      rx_axis_mac_tdata   <= udp_packet_2(i);
      rx_axis_mac_tvalid  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tdata     <= udp_packet_2(52);
    rx_axis_mac_tlast     <= '1';
    rx_axis_mac_tvalid    <= '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    wait;

  end process;

  -------------------------------------------------------------------------------
  -- Test Bench, Receive UDP packets
  -------------------------------------------------------------------------------
  proc_test_bench_receive_udp_packets : process
  begin
    tx_reset              <= '1';
    tx_axis_mac_tready    <= '0';
    -- Wait for reset
    wait until reset_rx_data_clk = '0';
    -- Align simulation time with rising clock edge
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    tx_reset              <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    -- Begin simulating the AXI interface
    loop
      while (tx_axis_mac_tvalid /= '1') loop
        wait until clk_125MHz = '1';
      end loop;
      tx_axis_mac_tready    <= '1';
      wait until clk_125MHz = '1';
      wait until clk_125MHz = '1';
      tx_axis_mac_tready    <= '0';
      wait until clk_125MHz = '1';
      wait until clk_125MHz = '1';
      wait until clk_125MHz = '1';
      wait until clk_125MHz = '1';
      tx_axis_mac_tready    <= '1';
      wait until tx_axis_mac_tlast = '1';
      wait until clk_125MHz = '1';
      tx_axis_mac_tready    <= '0';
      for i in 0 to 39 loop
        wait until clk_125MHz = '1';
      end loop;
    end loop;
  end process;

end architecture;
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
--  File: top_crush.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Toplevel file for the HDL portion of the CRUSH platform. 
--               Interfaces include:
--               - LVDS DAC data to the radio transmiter (USRP N210)
--               - LVDS ADC data from the radio transmiter (USRP N210)
--               - SPI control interface to the radio (USRP N210)
--               - DDR RAM Interface (TODO)
--               - Gigabit ethernet interface
--               - Misc I/O (LEDs, Push Buttons, DIP Switches)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity top_crush is
  port (
    -- Clocks
    CLK_OSC_66MHZ           : in    std_logic;
    CLK_OSC_200MHZ_N        : in    std_logic;
    CLK_OSC_200MHZ_P        : in    std_logic;
    BUTTON_CPU_RESET        : in    std_logic;
    -- Misc
    UART_DEBUG_RX           : in    std_logic;
    UART_DEBUG_TX           : out   std_logic;
    GPIO_DIP_SW             : in    std_logic_vector(7 downto 0);
    GPIO_LED                : in    std_logic_vector(7 downto 0);
    BUTTON_C                : in    std_logic;
    BUTTON_E                : in    std_logic;
    BUTTON_N                : in    std_logic;
    BUTTON_S                : in    std_logic;
    BUTTON_W                : in    std_logic;
    LED_C                   : out   std_logic;
    LED_E                   : out   std_logic;
    LED_N                   : out   std_logic;
    LED_S                   : out   std_logic;
    LED_W                   : out   std_logic;
    -- USRP <-> ML605 Interface
    RX_DATA_CLK_N           : in    std_logic;
    RX_DATA_CLK_P           : in    std_logic;
    RX_DATA_N               : in    std_logic_vector(13 downto 0);
    RX_DATA_P               : in    std_logic_vector(13 downto 0);
    SPARE0                  : out   std_logic;
    SPARE1                  : out   std_logic;
    SPARE2                  : out   std_logic;
    USRP_UART_TX            : out   std_logic;
    -- Gigabit Ethernet
    GMII_TXD                : out   std_logic_vector(7 downto 0);
    GMII_TX_EN              : out   std_logic;
    GMII_TX_ER              : out   std_logic;
    GMII_TX_CLK             : out   std_logic;
    GMII_RXD                : in    std_logic_vector(7 downto 0);
    GMII_RX_DV              : in    std_logic;
    GMII_RX_ER              : in    std_logic;
    GMII_RX_CLK             : in    std_logic;
    MII_TX_CLK              : in    std_logic;
    GMII_COL                : in    std_logic;
    GMII_CRS                : in    std_logic;
    PHY_RESET_N             : out   std_logic);
end entity;

architecture RTL of top_crush is

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

  component ddr_to_sdr
    generic (
      DEVICE            : string  := "VIRTEX6";                         -- "VIRTEX5", VIRTEX6", "7SERIES"
      BIT_WIDTH         : integer := 14;                                -- Input data width
      USE_PHASE_SHIFT   : string  := "FALSE";                           -- "TRUE/FALSE", Init MMCM phase on reset
      PHASE_SHIFT       : integer := 0);                                -- MMCM phase shift tap setting (0 - 55)
    port (
      reset             : in    std_logic;                              -- Active high reset
      -- Calibrate MMCM Phase
      clk_mmcm_ps       : in    std_logic;                              -- MMCM phase shift clock
      phase_inc_stb     : in    std_logic;                              -- Increment MMCM phase
      phase_dec_stb     : in    std_logic;                              -- Decrement MMCM phase
      phase_cnt         : out   std_logic_vector(5 downto 0);           -- Current phase shift, 0 - 55.
      -- DDR interface
      ddr_data_clk      : in    std_logic;                              -- DDR data clock (from pin)
      ddr_data          : in    std_logic_vector(BIT_WIDTH-1 downto 0); -- DDR data (from pin)
      clk_ddr           : out   std_logic;                              -- MMCM derived DDR clock
      clk_ddr_locked    : out   std_logic;                              -- MMCM DDR data clock locked
      -- SDR interface
      clk_sdr           : in    std_logic;                              -- SDR data clock
      sdr_data_vld      : out   std_logic;                              -- '1' = SDR data valid 
      sdr_data          : out   std_logic_vector((2*BIT_WIDTH)-1 downto 0));
  end component;

  component mmcm_sys_clks
    port (
      CLK_IN_200MHz               : in     std_logic;
      CLK_OUT_100MHz              : out    std_logic;
      CLK_OUT_125MHz              : out    std_logic;
      CLK_OUT_200MHz              : out    std_logic;
      RESET                       : in     std_logic;
      LOCKED                      : out    std_logic);
  end component;

  component network_intf
    generic (
      DEVICE                    : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
    port (
      -- User interface
      clk                       : in    std_logic;                      -- Clock (FIFO)
      reset                     : in    std_logic;                      -- Active high reset
      -- User RX interface
      -- User receive data filter. Payload is discarded if any of the following do not match.
      -- If a value is set to 0, any value will be accepted.
      rx_mac_addr_src           : in    std_logic_vector(47 downto 0);  -- Source MAC address
      rx_mac_addr_dest          : in    std_logic_vector(47 downto 0);  -- Destination MAC address
      rx_ip_addr_src            : in    std_logic_vector(31 downto 0);  -- Source IP address
      rx_ip_addr_dest           : in    std_logic_vector(31 downto 0);  -- Destination IP address
      rx_port_src               : in    std_logic_vector(15 downto 0);  -- Source Port
      rx_port_dest              : in    std_logic_vector(15 downto 0);  -- Destination Port
      -- User RX data interface
      rx_done_stb               : out   std_logic;                      -- Received UDP transmission
      rx_busy                   : out   std_logic;                      -- Receiving ethernet data
      rx_frame_error            : out   std_logic;                      -- Error detected
      rx_payload_size           : out   std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      rx_payload_data           : out   std_logic_vector(7 downto 0);   -- Output FIFO data
      rx_payload_data_rd_en     : in    std_logic;                      -- Output FIFO read enable
      rx_payload_almost_empty   : out   std_logic;                      -- Output FIFO almost empty
      -- User TX interface
      -- User TX Ethernet frame, IP header, & UDP header configuration
      tx_mac_addr_src           : in    std_logic_vector(47 downto 0);  -- Source MAC address
      tx_mac_addr_dest          : in    std_logic_vector(47 downto 0);  -- Destination MAC address
      tx_ip_addr_src            : in    std_logic_vector(31 downto 0);  -- Source IP address
      tx_ip_addr_dest           : in    std_logic_vector(31 downto 0);  -- Destination IP address
      tx_port_src               : in    std_logic_vector(15 downto 0);  -- Source Port
      tx_port_dest              : in    std_logic_vector(15 downto 0);  -- Destination Port
      -- User TX data interface 
      tx_start_stb              : in    std_logic;                      -- Start UDP transmission
      tx_busy                   : out   std_logic;                      -- UDP transmission in process
      tx_payload_size           : in    std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
      tx_payload_data           : in    std_logic_vector(7 downto 0);   -- Input FIFO data
      tx_payload_data_wr_en     : in    std_logic;                      -- Input FIFO write enable
      tx_payload_almost_full    : out   std_logic;                      -- Input FIFO almost full
      -- Tri-mode Ethernet Wrapper Signals
      gtx_clk                   : in    std_logic;                      -- GTX 125 MHz clock
      refclk                    : in    std_logic;                      -- IDELAY 200 MHz clock
      phy_reset_n               : out   std_logic;
      gmii_txd                  : out   std_logic_vector(7 downto 0);
      gmii_tx_en                : out   std_logic;
      gmii_tx_er                : out   std_logic;
      gmii_tx_clk               : out   std_logic;
      gmii_rxd                  : in    std_logic_vector(7 downto 0);
      gmii_rx_dv                : in    std_logic;
      gmii_rx_er                : in    std_logic;
      gmii_rx_clk               : in    std_logic;
      gmii_col                  : in    std_logic;
      gmii_crs                  : in    std_logic;
      mii_tx_clk                : in    std_logic);
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
    -- Spectrum Sensing User Block
    spec_sense_start_stb        : out   std_logic;                      -- Enable sending threshold results via UDP
    spec_sense_busy             : in    std_logic;                      -- Busy
    spec_sense_done_stb         : in    std_logic;                      -- FFT done, begin data unload on next cycle
    fft_size                    : out   std_logic_vector(4 downto 0);   -- 0 = 64, 1 = 128, etc...
    xk_valid                    : in    std_logic;                      -- X(k) data valid
    xk_real                     : in    std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (real)
    xk_imag                     : in    std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (imag)
    xk_index                    : in    std_logic_vector(12 downto 0);  -- k
    xk_magnitude_squared        : out   std_logic_vector(31 downto 0);  -- Magnitude squared, X_r(k)^2 + X_i(k)^2
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

  component microblaze
    port (
      clk                         : in    std_logic;
      reset                       : in    std_logic;
      uart_debug_rx               : in    std_logic;
      uart_debug_tx               : out   std_logic;
      uart_usrp_rx                : in    std_logic;
      uart_usrp_tx                : out   std_logic;
      gpio_1_in                   : in    std_logic_vector(31 downto 0);
      gpio_1_out                  : out   std_logic_vector(31 downto 0);
      fsl_rst                     : out   std_logic;
      fsl_m_clk                   : in    std_logic;
      fsl_m_control               : in    std_logic;
      fsl_m_data                  : in    std_logic_vector(31 downto 0);
      fsl_m_write                 : in    std_logic;
      fsl_m_full                  : out   std_logic;
      fsl_s_clk                   : in    std_logic;
      fsl_s_control               : out   std_logic;
      fsl_s_exists                : out   std_logic;
      fsl_s_data                  : out   std_logic_vector(31 downto 0);
      fsl_s_read                  : in    std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant DEVICE                       : string := "VIRTEX6";

  constant RW_MAC_ADDR_DEST_BYTES_5_4   : std_logic_vector(15 downto 0) := x"0000";
  constant RW_MAC_ADDR_DEST_BYTES_3_2   : std_logic_vector(15 downto 0) := x"0001";
  constant RW_MAC_ADDR_DEST_BYTES_1_0   : std_logic_vector(15 downto 0) := x"0002";
  constant RW_MAC_ADDR_SRC_BYTES_5_4    : std_logic_vector(15 downto 0) := x"0003";
  constant RW_MAC_ADDR_SRC_BYTES_3_2    : std_logic_vector(15 downto 0) := x"0004";
  constant RW_MAC_ADDR_SRC_BYTES_1_0    : std_logic_vector(15 downto 0) := x"0005";
  constant RW_IP_ADDR_DEST_BYTES_3_2    : std_logic_vector(15 downto 0) := x"0006";
  constant RW_IP_ADDR_DEST_BYTES_1_0    : std_logic_vector(15 downto 0) := x"0007";
  constant RW_IP_ADDR_SRC_BYTES_3_2     : std_logic_vector(15 downto 0) := x"0008";
  constant RW_IP_ADDR_SRC_BYTES_1_0     : std_logic_vector(15 downto 0) := x"0009";
  constant RW_PORT_DEST                 : std_logic_vector(15 downto 0) := x"000A";
  constant RW_PORT_SRC                  : std_logic_vector(15 downto 0) := x"000B";
  constant RW_PAYLOAD_SIZE              : std_logic_vector(15 downto 0) := x"000C";
  constant RW_FFT_SIZE                  : std_logic_vector(15 downto 0) := x"000D";
  constant RW_THRESHOLD_BYTES_3_2       : std_logic_vector(15 downto 0) := x"000E";
  constant RW_THRESHOLD_BYTES_1_0       : std_logic_vector(15 downto 0) := x"000F";
  constant RW_CTRL_FLAGS                : std_logic_vector(15 downto 0) := x"0010";

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  -- Clocks, Resets
  signal external_reset           : std_logic;
  signal reset                    : std_logic;
  signal reset_n                  : std_logic;
  signal clk_in_200MHz            : std_logic;
  signal clk_in_200MHz_gbl        : std_logic;
  signal clk_100MHz               : std_logic;
  signal clk_125MHz               : std_logic;
  signal clk_200MHz               : std_logic;

  -- ddr_to_sdr
  signal phase_inc                : std_logic;
  signal phase_inc_stb            : std_logic;
  signal phase_dec                : std_logic;
  signal phase_dec_stb            : std_logic;
  signal phase_cnt                : std_logic_vector(5 downto 0);
  signal rx_data                  : std_logic_vector(27 downto 0);
  signal rx_data_ddr              : std_logic_vector(13 downto 0);
  signal rx_data_clk_ddr          : std_logic;
  signal rx_data_clk              : std_logic;
  signal rx_data_clk_locked       : std_logic;
  signal reset_rx_data_clk        : std_logic;
  signal adc_data_i               : std_logic_vector(13 downto 0);
  signal adc_data_q               : std_logic_vector(13 downto 0);

  -- network_intf
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
  
  -- Microblaze
  signal gpio_1_in                : std_logic_vector(31 downto 0);
  signal gpio_1_out               : std_logic_vector(31 downto 0);
  signal fsl_rst                  : std_logic;
  signal fsl_m_clk                : std_logic;
  signal fsl_m_control            : std_logic;
  signal fsl_m_data               : std_logic_vector(31 downto 0);
  signal fsl_m_write              : std_logic;
  signal fsl_m_full               : std_logic;
  signal fsl_s_clk                : std_logic;
  signal fsl_s_control            : std_logic;
  signal fsl_s_exists             : std_logic;
  signal fsl_s_data               : std_logic_vector(31 downto 0);
  signal fsl_s_read               : std_logic;
  signal man_spec_sense_start     : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Clocks and Reset
  -----------------------------------------------------------------------------
  -- Pushbutton reset debouncing
  inst_reset_debounce : debounce
    generic map (
      CLOCK_FREQ                  => 200e6,
      SAMPLE_TIME                 => 10)      -- 10 millseconds
    port map (
      clk                         => clk_in_200MHz_gbl,
      reset                       => '0',
      input_async                 => BUTTON_CPU_RESET,
      input_sync                  => external_reset);

  -- 200 MHz input clock LVDS to BUFG
  IBUFDS_clk_in_200MHz : IBUFDS
    generic map (
      DIFF_TERM                   => TRUE,
      IOSTANDARD                  => "DEFAULT")
    port map (
      I                           => CLK_OSC_200MHZ_P,
      IB                          => CLK_OSC_200MHZ_N,
      O                           => clk_in_200MHz);

  BUFG_clk_in_200MHz : BUFG
    port map (
      I                           => clk_in_200MHz,
      O                           => clk_in_200MHz_gbl);

  inst_mmcm_sys_clks : mmcm_sys_clks
    port map (
      clk_in_200MHz               => clk_in_200MHz_gbl,
      clk_out_100MHz              => clk_100MHz,
      clk_out_125MHz              => clk_125MHz,
      clk_out_200MHz              => clk_200MHz,
      reset                       => external_reset,
      locked                      => reset_n);

  reset                           <= NOT(reset_n);

  -----------------------------------------------------------------------------
  -- ML605 <-> USRP Interface
  -----------------------------------------------------------------------------
  gen_lvds_input : for i in 0 to 13 generate
    IBUFDS_rx_data : IBUFDS
      generic map (
        DIFF_TERM                 => TRUE,
        IOSTANDARD                => "DEFAULT")
      port map (
        I                         => RX_DATA_P(i),
        IB                        => RX_DATA_N(i),
        O                         => rx_data_ddr(i));
  end generate;

  IBUFDS_rx_data_clk : IBUFDS
    generic map (
      DIFF_TERM                   => TRUE,
      IOSTANDARD                  => "DEFAULT")
    port map (
      I                           => RX_DATA_CLK_P,
      IB                          => RX_DATA_CLK_N,
      O                           => rx_data_clk_ddr);

  inst_ddr_to_sdr : ddr_to_sdr
    generic map (
      DEVICE                      => DEVICE,
      BIT_WIDTH                   => 14,
      USE_PHASE_SHIFT             => "FALSE",
      PHASE_SHIFT                 => 0)
    port map (
      reset                       => reset,
      clk_mmcm_ps                 => clk_100MHz,
      phase_inc_stb               => phase_inc_stb,
      phase_dec_stb               => phase_dec_stb,
      phase_cnt                   => phase_cnt,
      ddr_data_clk                => rx_data_clk_ddr,
      ddr_data                    => rx_data_ddr,
      clk_ddr                     => rx_data_clk,
      clk_ddr_locked              => rx_data_clk_locked,
      clk_sdr                     => rx_data_clk,
      sdr_data_vld                => open,
      sdr_data                    => rx_data);

  reset_rx_data_clk               <= NOT(rx_data_clk_locked);
  adc_data_i                      <= rx_data(27 downto 14);
  adc_data_q                      <= rx_data(13 downto  0);

  -- Rising edge detection for Microblaze GPIO to manually align DDR data interface
  inst_edge_detect_phase_inc : edge_detect
    generic map (
      EDGE                        => "RISING")
    port map (
      clk                         => clk_100MHz,
      reset                       => reset,
      input_detect                => phase_inc,
      edge_detect_stb             => phase_inc_stb);

  inst_edge_detect_phase_dec : edge_detect
    generic map (
      EDGE                        => "RISING")
    port map (
      clk                         => clk_100MHz,
      reset                       => reset,
      input_detect                => phase_dec,
      edge_detect_stb             => phase_dec_stb);

  -----------------------------------------------------------------------------
  -- ML605 <-> Host UDP packet interface
  -----------------------------------------------------------------------------
  inst_network_intf : network_intf
    generic map (
      DEVICE                      => DEVICE)
    port map (
      clk                         => rx_data_clk,
      reset                       => reset_rx_data_clk,
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
      tx_payload_almost_full      => tx_payload_almost_full,
      gtx_clk                     => clk_125MHz,
      refclk                      => clk_200MHz,
      phy_reset_n                 => PHY_RESET_N,
      gmii_txd                    => GMII_TXD,
      gmii_tx_en                  => GMII_TX_EN,
      gmii_tx_er                  => GMII_TX_ER,
      gmii_tx_clk                 => GMII_TX_CLK,
      gmii_rxd                    => GMII_RXD,
      gmii_rx_dv                  => GMII_RX_DV,
      gmii_rx_er                  => GMII_RX_ER,
      gmii_rx_clk                 => GMII_RX_CLK,
      gmii_col                    => GMII_COL,
      gmii_crs                    => GMII_CRS,
      mii_tx_clk                  => MII_TX_CLK);

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
  -- Microblaze processor, debug and network configuration
  -----------------------------------------------------------------------------
  inst_microblaze : microblaze
    port map (
      clk                         => clk_100MHz,
      reset                       => reset,
      uart_debug_rx               => UART_DEBUG_RX,
      uart_debug_tx               => UART_DEBUG_TX,
      uart_usrp_rx                => '1',
      uart_usrp_tx                => USRP_UART_TX,
      gpio_1_in                   => gpio_1_in,
      gpio_1_out                  => gpio_1_out,
      fsl_rst                     => open,
      fsl_m_clk                   => fsl_m_clk,
      fsl_m_control               => '0',
      fsl_m_data                  => fsl_m_data,
      fsl_m_write                 => fsl_m_write,
      fsl_m_full                  => open,
      fsl_s_clk                   => fsl_s_clk,
      fsl_s_control               => fsl_s_control,
      fsl_s_exists                => fsl_s_exists,
      fsl_s_data                  => fsl_s_data,
      fsl_s_read                  => fsl_s_read);

  fsl_m_clk                       <= rx_data_clk;
  fsl_s_clk                       <= rx_data_clk;

  -- Status
  gpio_1_in(0)                    <= rx_data_clk_locked;
  gpio_1_in(25 downto 1)          <= (others=>'0');
  gpio_1_in(31 downto 26)         <= phase_cnt;

  -- Control
  phase_inc                       <= gpio_1_out(0);
  phase_dec                       <= gpio_1_out(1);

  -- Debug registers for manually controlling the network configuration and the user block
  proc_microblaze_register_map : process(rx_data_clk,reset_rx_data_clk)
  begin
    if rising_edge(rx_data_clk) then
      if (reset_rx_data_clk = '1') then
        user_mac_addr_dest                        <= x"18037329AE42";
        user_mac_addr_src                         <= x"000A350250C4";
        user_ip_addr_src                          <= x"C0A80A0A"; -- 192.168.10.10
        user_ip_addr_dest                         <= x"C0A80A01"; -- 192.168.10.1
        user_port_src                             <= std_logic_vector(to_unsigned(9090,16));
        user_port_dest                            <= std_logic_vector(to_unsigned(34672,16));
        user_payload_size                         <= std_logic_vector(to_unsigned(1472,11));
        override_network_ctrl                     <= '0';
        man_spec_sense_start                      <= '0';
        man_send_fft_data                         <= '1';
        man_send_mag_squared                      <= '1';
        man_send_threshold                        <= '1';
        man_send_counting_pattern                 <= '0';
        man_fft_size                              <= "01001";     -- FFT Size 512
        man_threshold                             <= "00001" & (26 downto 0 =>'0');
        fsl_m_data                                <= (others=>'0');
        fsl_s_read                                <= '0';
        fsl_m_write                               <= '0';
      else
        fsl_m_data                                <= (others=>'0');
        fsl_s_read                                <= '0';
        fsl_m_write                               <= '0';
        -- Received data from FSL bus
        if (fsl_s_exists = '1') then
          -- The control bit determines if we are writing or reading
          -- a register. fsl_s_control = '0' means a register read, so
          -- write the value to the fsl master bus.
          fsl_s_read                              <= '1';
          if (fsl_s_control = '0') then
            fsl_m_write                           <= '1';
          end if;
          -- Decode address bits
          case fsl_s_data(31 downto 16) is
            when RW_MAC_ADDR_DEST_BYTES_5_4 =>
              if (fsl_s_control = '1') then
                user_mac_addr_dest(47 downto 32)  <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_dest(47 downto 32);
              end if;

            when RW_MAC_ADDR_DEST_BYTES_3_2 =>
              if (fsl_s_control = '1') then
                user_mac_addr_dest(31 downto 16)  <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_dest(31 downto 16);
              end if;

            when RW_MAC_ADDR_DEST_BYTES_1_0 =>
              if (fsl_s_control = '1') then
                user_mac_addr_dest(15 downto  0)  <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_dest(15 downto 0);
              end if;

            when RW_MAC_ADDR_SRC_BYTES_5_4 =>
              if (fsl_s_control = '1') then
                user_mac_addr_src(47 downto 32)   <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_src(47 downto 32);
              end if;

            when RW_MAC_ADDR_SRC_BYTES_3_2 =>
              if (fsl_s_control = '1') then
                user_mac_addr_src(31 downto 16)   <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_src(31 downto 16);
              end if;

            when RW_MAC_ADDR_SRC_BYTES_1_0 =>
              if (fsl_s_control = '1') then
                user_mac_addr_src(15 downto  0)   <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_mac_addr_src(15 downto  0);
              end if;

            when RW_IP_ADDR_DEST_BYTES_3_2 =>
              if (fsl_s_control = '1') then
                user_ip_addr_dest(31 downto 16)   <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_ip_addr_dest(31 downto 16);
              end if;

            when RW_IP_ADDR_DEST_BYTES_1_0 =>
              if (fsl_s_control = '1') then
                user_ip_addr_dest(15 downto  0)   <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_ip_addr_dest(15 downto  0);
              end if;

            when RW_IP_ADDR_SRC_BYTES_3_2 =>
              if (fsl_s_control = '1') then
                user_ip_addr_src(31 downto 16)    <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_ip_addr_src(31 downto 16);
              end if;

            when RW_IP_ADDR_SRC_BYTES_1_0 =>
              if (fsl_s_control = '1') then
                user_ip_addr_src(15 downto  0)    <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_ip_addr_src(15 downto  0);
              end if;

            when RW_PORT_DEST =>
              if (fsl_s_control = '1') then
                user_port_dest                    <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_port_dest;
              end if;

            when RW_PORT_SRC =>
              if (fsl_s_control = '1') then
                user_port_src                     <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= user_port_src;
              end if;

            when RW_PAYLOAD_SIZE =>
              if (fsl_s_control = '1') then
                user_payload_size                 <= fsl_s_data(10 downto 0);
              else
                fsl_m_data(10 downto 0)           <= user_payload_size;
              end if;

            when RW_FFT_SIZE =>
              if (fsl_s_control = '1') then
                man_fft_size                      <= fsl_s_data(4 downto 0);
              else
                fsl_m_data(4 downto 0)            <= man_fft_size;
              end if;

            when RW_THRESHOLD_BYTES_3_2 =>
              if (fsl_s_control = '1') then
                man_threshold(31 downto 16)       <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= man_threshold(31 downto 16);
              end if;

            when RW_THRESHOLD_BYTES_1_0 =>
              if (fsl_s_control = '1') then
                man_threshold(15 downto 0)        <= fsl_s_data(15 downto 0);
              else
                fsl_m_data(15 downto 0)           <= man_threshold(15 downto 0);
              end if;

            when RW_CTRL_FLAGS =>
              if (fsl_s_control = '1') then
                override_network_ctrl             <= fsl_s_data(14);
                man_spec_sense_start              <= fsl_s_data(15);
                man_send_fft_data                 <= fsl_s_data(0);
                man_send_mag_squared              <= fsl_s_data(1);
                man_send_threshold                <= fsl_s_data(0);
                man_send_counting_pattern         <= fsl_s_data(3);
              else
                fsl_m_data(14)                    <= override_network_ctrl;
                fsl_m_data(15)                    <= man_spec_sense_start;
                fsl_m_data(0)                     <= man_send_threshold;
                fsl_m_data(1)                     <= man_send_fft_data;
                fsl_m_data(2)                     <= man_send_mag_squared;
                fsl_m_data(3)                     <= man_send_counting_pattern;
              end if;

            when others =>
          end case;
        end if;
      end if;
    end if;
  end process;

  -- Create strobe from rising edge
  inst_edge_detect_spec_sense_start : edge_detect
    generic map (
      EDGE                        => "RISING")
    port map (
      clk                         => rx_data_clk,
      reset                       => reset_rx_data_clk,
      input_detect                => man_spec_sense_start,
      edge_detect_stb             => man_spec_sense_start_stb);

  -----------------------------------------------------------------------------
  -- LEDs, GPIO, etc
  -----------------------------------------------------------------------------
  LED_C                           <= rx_data_clk_locked;
  LED_E                           <= '0';
  LED_N                           <= '0';
  LED_S                           <= '0';
  LED_W                           <= '0';

  SPARE0                          <= 'Z';
  SPARE1                          <= 'Z';
  SPARE2                          <= 'Z';

end architecture;
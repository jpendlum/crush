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
--  File: user_block_ctrl.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Decodes control data from UDP packets, sends processed data
--               via UDP packets, and controls user blocks.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unimacro;
use unimacro.vcomponents.all;

entity user_block_ctrl is
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
    user_ddr_intf_mode          : out  std_logic_vector(7 downto 0);    -- USRP DDR interface mode
    user_ddr_intf_mode_stb      : out  std_logic;                       -- Strobe to set mode
    -- BPSK Transmit Waveform Generator
    bpsk_mode                   : out   std_logic_vector(1 downto 0);   -- 0 = BPSK, 1 = CW, 2 = PRN data, 3 = Test Pattern
    bpsk_freq                   : out  std_logic_vector(15 downto 0);   -- Carrier Offset Frequency
    bpsk_data_freq              : out  std_logic_vector(15 downto 0);   -- Psuedo-Random Data Frequency
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
end entity;

architecture RTL of user_block_ctrl is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component fifo_16x8196
    port (
      rst                       : in    std_logic;
      wr_clk                    : in    std_logic;
      wr_en                     : in    std_logic;
      din                       : in    std_logic_vector(15 downto 0);
      full                      : out   std_logic;
      almost_full               : out   std_logic;
      overflow                  : out   std_logic;
      wr_data_count             : out   std_logic_vector(12 downto 0);
      rd_clk                    : in    std_logic;
      rd_en                     : in    std_logic;
      dout                      : out   std_logic_vector(15 downto 0);
      empty                     : out   std_logic;
      almost_empty              : out   std_logic;
      underflow                 : out   std_logic;
      rd_data_count             : out   std_logic_vector(12 downto 0));
  end component;

  component fifo_32x8196
    port (
      rst                       : in    std_logic;
      wr_clk                    : in    std_logic;
      wr_en                     : in    std_logic;
      din                       : in    std_logic_vector(31 downto 0);
      full                      : out   std_logic;
      almost_full               : out   std_logic;
      overflow                  : out   std_logic;
      wr_data_count             : out   std_logic_vector(12 downto 0);
      rd_clk                    : in    std_logic;
      rd_en                     : in    std_logic;
      dout                      : out   std_logic_vector(31 downto 0);
      empty                     : out   std_logic;
      almost_empty              : out   std_logic;
      underflow                 : out   std_logic;
      rd_data_count             : out   std_logic_vector(12 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  -- Commands received over the network interface
  constant CMD_SENSE_SPECTRUM       : std_logic_vector(7 downto 0)  := x"01";
  constant CMD_SET_CONFIG_WORD      : std_logic_vector(7 downto 0)  := x"02";
  constant CMD_SET_FFT_SIZE         : std_logic_vector(7 downto 0)  := x"03";
  constant CMD_SET_THRESHOLD        : std_logic_vector(7 downto 0)  := x"04";
  constant CMD_SET_USRP_MODE        : std_logic_vector(7 downto 0)  := x"05";
  constant CMD_SET_BPSK_MODE        : std_logic_vector(7 downto 0)  := x"06";
  constant CMD_SET_BPSK_FREQ        : std_logic_vector(7 downto 0)  := x"07";
  constant CMD_SET_BPSK_DATA_FREQ   : std_logic_vector(7 downto 0)  := x"08";

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  type ctrl_state_type is (CTRL_IDLE,CTRL_CHECK_INTEGRITY_HEADER,CTRL_CMD_WORD,
                           CTRL_SET_CONFIG_WORD,CTRL_SET_FFT_SIZE,CTRL_SET_THRESHOLD,
                           CTRL_SENSE_SPECTRUM,CTRL_SET_USRP_MODE,CTRL_SET_BPSK,
                           CTRL_SET_BPSK_MODE,CTRL_SET_BPSK_FREQ,
                           CTRL_SET_BPSK_DATA_FREQ,CTRL_UDP_ERROR);
  signal ctrl_state                     : ctrl_state_type;
  signal rx_counter                     : integer range 0 to 1472;
  signal rx_byte_counter                : integer range 0 to 3;
  signal rx_payload_size_reg            : std_logic_vector(10 downto 0);
  signal spec_sense_start_stb_int       : std_logic;
  signal fft_size_int                   : std_logic_vector(4 downto 0);
  signal ctrl_spec_sense_start_stb      : std_logic;
  signal ctrl_fft_size                  : std_logic_vector( 4 downto 0);
  signal ctrl_threshold                 : std_logic_vector(31 downto 0);
  signal ctrl_config_word               : std_logic_vector( 7 downto 0);
  signal ctrl_user_ddr_intf_mode        : std_logic_vector(7 downto 0);
  signal ctrl_user_ddr_intf_mode_stb    : std_logic;
  signal ctrl_bpsk_mode                 : std_logic_vector(1 downto 0);
  signal ctrl_bpsk_freq                 : std_logic_vector(15 downto 0);
  signal ctrl_bpsk_data_freq            : std_logic_vector(15 downto 0);
  signal config_word                    : std_logic_vector( 7 downto 0);
  signal send_mag_squared               : std_logic;
  signal send_fft                       : std_logic;
  signal send_threshold                 : std_logic;
  signal send_counting_pattern          : std_logic;
  signal debug_counter                  : integer range 0 to 255;

  type tx_state_type is (TX_IDLE,TX_WAIT_FOR_DATA,TX_BUFFER_DATA,
                         TX_SEND_HEADER1,TX_SEND_HEADER2,TX_SEND_HEADER3,
                         TX_SEND_HEADER4,TX_SEND_THRESHOLD,TX_SEND_XK_DATA,
                         TX_SEND_XK_MAG_SQ,TX_ZERO_FILL);
  signal tx_state                       : tx_state_type;
  signal tx_byte_counter                : integer range 0 to 3;
  signal tx_payload_count               : integer range 0 to 1473;
  signal tx_threshold_count             : std_logic_vector(12 downto 0);
  signal tx_payload_size_int            : std_logic_vector(10 downto 0);
  signal xk_real_fifo_almost_empty      : std_logic;
  signal xk_real_fifo_out               : std_logic_vector(15 downto 0);
  signal xk_real_fifo_rd_en             : std_logic;
  signal xk_real_valid                  : std_logic;
  signal xk_imag_fifo_almost_empty      : std_logic;
  signal xk_imag_fifo_out               : std_logic_vector(15 downto 0);
  signal xk_imag_fifo_rd_en             : std_logic;
  signal xk_imag_valid                  : std_logic;
  signal xk_mag_sq_fifo_almost_empty    : std_logic;
  signal xk_mag_sq_fifo_out             : std_logic_vector(31 downto 0);
  signal xk_mag_sq_fifo_rd_en           : std_logic;
  signal xk_mag_sq_valid                : std_logic;
  signal threshold_fifo_almost_empty    : std_logic;
  signal threshold_fifo_out             : std_logic_vector(15 downto 0);
  signal threshold_fifo_rd_en           : std_logic;
  signal xk_index_ext                   : std_logic_vector(15 downto 0);
  signal threshold_fifo_wr_en           : std_logic;
  signal threshold_fifo_wr_count        : std_logic_vector(12 downto 0);

begin

  -- Note: Destination and Source are reversed, as the RX source is the
  --       host computer and the RX destination is the FPGA.
  rx_mac_addr_src                           <= user_mac_addr_dest;
  rx_mac_addr_dest                          <= user_mac_addr_src;
  rx_ip_addr_src                            <= user_ip_addr_dest;
  rx_ip_addr_dest                           <= user_ip_addr_src;
  rx_port_src                               <= user_port_dest;
  rx_port_dest                              <= user_port_src;
  -- Note: Destination and Source are not reversed.
  tx_mac_addr_src                           <= user_mac_addr_src;
  tx_mac_addr_dest                          <= user_mac_addr_dest;
  tx_ip_addr_src                            <= user_ip_addr_src;
  tx_ip_addr_dest                           <= user_ip_addr_dest;
  tx_port_src                               <= user_port_src;
  tx_port_dest                              <= user_port_dest;

  -----------------------------------------------------------------------------
  -- UDP control interface state machine
  -- This state machine interfaces with the UDP RX component to receive
  -- control data from the host computer. Manual override logic exists to
  -- allow the control signals to be controlled set by another component, such 
  -- as an embedded Microblaze processor.
  -----------------------------------------------------------------------------
  proc_udp_control_interface : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        spec_sense_start_stb_int            <= '0';
        fft_size_int                        <= (others=>'0');
        threshold                           <= (others=>'0');
        config_word                         <= (others=>'0');
        user_ddr_intf_mode                  <= (others=>'0');
        user_ddr_intf_mode_stb              <= '0';
        bpsk_mode                           <= (others=>'0');
        bpsk_freq                           <= (others=>'0');
        bpsk_data_freq                      <= (others=>'0');
        ctrl_spec_sense_start_stb           <= '0';
        ctrl_fft_size                       <= "01101"; -- FFT size 512
        ctrl_threshold                      <= "00001" & (26 downto 0 =>'0');
        -- By default, set configuration to send fft, mag squared, and threshold data
        ctrl_config_word                    <= "00000111";
        ctrl_user_ddr_intf_mode             <= (others=>'0');
        ctrl_user_ddr_intf_mode_stb         <= '0';
        ctrl_bpsk_mode                      <= (others=>'0');
        ctrl_bpsk_freq                      <= (others=>'0');
        ctrl_bpsk_data_freq                 <= (others=>'0');
        rx_counter                          <= 0;
        rx_byte_counter                     <= 0;
        rx_payload_data_rd_en               <= '0';
        rx_payload_size_reg                 <= (others=>'0');
        ctrl_state                          <= CTRL_IDLE;
      else
        -- Strobes are only one clock cycle
        ctrl_spec_sense_start_stb           <= '0';
        ctrl_user_ddr_intf_mode_stb         <= '0';

        -- Control state machine
        case (ctrl_state) is
          when CTRL_IDLE =>
            rx_payload_data_rd_en           <= '0';
            rx_byte_counter                 <= 0;
            rx_counter                      <= 0;
            if (rx_done_stb = '1') then
              rx_payload_data_rd_en         <= '1';
              rx_counter                    <= rx_counter + 1;
              rx_payload_size_reg           <= std_logic_vector(unsigned(rx_payload_size));
              -- Received UDP packet has an error or user is overriding 
              -- the network control interface
              if (rx_frame_error = '1' OR override_network_ctrl = '1') then
                ctrl_state                  <= CTRL_UDP_ERROR;
              else
                ctrl_state                  <= CTRL_CHECK_INTEGRITY_HEADER;
              end if;
            end if;

          -- All control packets have a special header to ensure integrity.
          when CTRL_CHECK_INTEGRITY_HEADER =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            if (rx_payload_data = x"A5") then
              ctrl_state                    <= CTRL_CMD_WORD;
            else
              ctrl_state                    <= CTRL_UDP_ERROR;
            end if;

          -- Decode the command word
          when CTRL_CMD_WORD =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            case (rx_payload_data) is 
              when CMD_SENSE_SPECTRUM =>
                ctrl_spec_sense_start_stb   <= '1';
                ctrl_state                  <= CTRL_CMD_WORD;

              when CMD_SET_CONFIG_WORD =>
                ctrl_state                  <= CTRL_SET_CONFIG_WORD;

              when CMD_SET_FFT_SIZE =>
                ctrl_state                  <= CTRL_SET_FFT_SIZE;

              when CMD_SET_THRESHOLD =>
                ctrl_state                  <= CTRL_SET_THRESHOLD;

              when CMD_SET_USRP_MODE =>
                ctrl_state                  <= CTRL_SET_USRP_MODE;

              when CMD_SET_BPSK_MODE =>
                ctrl_state                  <= CTRL_SET_BPSK_MODE;

              when CMD_SET_BPSK_FREQ =>
                ctrl_state                  <= CTRL_SET_BPSK_FREQ;

              when CMD_SET_BPSK_DATA_FREQ =>
                ctrl_state                  <= CTRL_SET_BPSK_DATA_FREQ;

              when others =>
                ctrl_state                  <= CTRL_CMD_WORD;
            end case;
            -- All bytes have been read
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            end if;

          -- Set the configuration word
          when CTRL_SET_CONFIG_WORD =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            ctrl_config_word                <= rx_payload_data;
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            else
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set the fft size
          when CTRL_SET_FFT_SIZE =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            ctrl_fft_size                   <= rx_payload_data(4 downto 0);
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            else
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set the threshold
          when CTRL_SET_THRESHOLD =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            case (rx_byte_counter) is
              when 0 =>
                rx_byte_counter               <= 1;
                ctrl_threshold(31 downto 24)  <= rx_payload_data;
              when 1 =>
                rx_byte_counter               <= 2;
                ctrl_threshold(23 downto 16)  <= rx_payload_data;
              when 2 =>
                rx_byte_counter               <= 3;
                ctrl_threshold(15 downto  8)  <= rx_payload_data;
              when 3 => 
                rx_byte_counter               <= 0;
                ctrl_threshold( 7 downto  0)  <= rx_payload_data;
              when others =>
            end case;
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            -- On the final byte, check next cmd word
            elsif (rx_byte_counter = 3) then
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set USRP mode
          when CTRL_SET_USRP_MODE =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            ctrl_user_ddr_intf_mode         <= rx_payload_data;
            ctrl_user_ddr_intf_mode_stb     <= '1';
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            else
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set BPSK mode
          when CTRL_SET_BPSK_MODE =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            ctrl_bpsk_mode                  <= rx_payload_data(1 downto 0);
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            else
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set BSPK carrier frequency
          when CTRL_SET_BPSK_FREQ =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            case (rx_byte_counter) is
              when 0 =>
                rx_byte_counter               <= 1;
                ctrl_bpsk_freq(15 downto  8)  <= rx_payload_data;
              when 1 => 
                rx_byte_counter               <= 0;
                ctrl_bpsk_freq( 7 downto  0)  <= rx_payload_data;
              when others =>
            end case;
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            -- On the final byte, check next cmd word
            elsif (rx_byte_counter = 1) then
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Set BPSK data rate
          when CTRL_SET_BPSK_DATA_FREQ =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            case (rx_byte_counter) is
              when 0 =>
                rx_byte_counter                     <= 1;
                ctrl_bpsk_data_freq(15 downto  8)   <= rx_payload_data;
              when 1 => 
                rx_byte_counter                     <= 0;
                ctrl_bpsk_data_freq( 7 downto  0)   <= rx_payload_data;
              when others =>
            end case;
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            -- On the final byte, check next cmd word
            elsif (rx_byte_counter = 1) then
              ctrl_state                    <= CTRL_CMD_WORD;
            end if;

          -- Frame error, drop the payload data as it may be corrupt.
          when CTRL_UDP_ERROR =>
            rx_payload_data_rd_en           <= '1';
            rx_counter                      <= rx_counter + 1;
            if (rx_counter = to_integer(unsigned(rx_payload_size_reg))) then
              rx_payload_data_rd_en         <= '0';
              ctrl_state                    <= CTRL_IDLE;
            end if;

          when others =>
            ctrl_state                      <= CTRL_IDLE;
        end case;

        -- Override control interface
        if (override_network_ctrl = '1') then
          spec_sense_start_stb_int          <= man_spec_sense_start_stb;
          fft_size_int                      <= man_fft_size;
          threshold                         <= man_threshold;
          config_word                       <= "0000" & 
                                               man_send_counting_pattern &
                                               man_send_mag_squared & 
                                               man_send_fft_data & 
                                               man_send_threshold;
          user_ddr_intf_mode                <= man_user_ddr_intf_mode;
          user_ddr_intf_mode_stb            <= man_user_ddr_intf_mode_stb;
          bpsk_mode                         <= man_bpsk_mode;
          bpsk_freq                         <= man_bpsk_freq;
          bpsk_data_freq                    <= man_bpsk_data_freq;
        else
          spec_sense_start_stb_int          <= ctrl_spec_sense_start_stb;
          fft_size_int                      <= ctrl_fft_size;
          threshold                         <= ctrl_threshold;
          config_word                       <= ctrl_config_word;
          user_ddr_intf_mode                <= ctrl_user_ddr_intf_mode;
          user_ddr_intf_mode_stb            <= ctrl_user_ddr_intf_mode_stb;
          bpsk_mode                         <= ctrl_bpsk_mode;
          bpsk_freq                         <= ctrl_bpsk_freq;
          bpsk_data_freq                    <= ctrl_bpsk_data_freq;
        end if;
      end if;
    end if;
  end process;

  spec_sense_start_stb                      <= spec_sense_start_stb_int;
  fft_size                                  <= fft_size_int;
  send_counting_pattern                     <= config_word(3);
  send_mag_squared                          <= config_word(2);
  send_fft                                  <= config_word(1);
  send_threshold                            <= config_word(0);

  -----------------------------------------------------------------------------
  -- UDP transmit interface state machine
  -- This state machine sends the FFT's output to the host computer via
  -- UDP ethernet transmission.
  -----------------------------------------------------------------------------
  proc_udp_transmit_state_machine : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        tx_start_stb                        <= '0';
        tx_payload_data_wr_en               <= '0';
        threshold_fifo_rd_en                <= '0';
        xk_real_fifo_rd_en                  <= '0';
        xk_imag_fifo_rd_en                  <= '0';
        xk_mag_sq_fifo_rd_en                <= '0';
        tx_payload_size_int                 <= (others=>'0');
        tx_payload_data                     <= (others=>'0');
        tx_payload_count                    <= 0;
        tx_threshold_count                  <= (others=>'0');
        debug_counter                       <= 0;
        tx_state                            <= TX_IDLE;
      else
        -- Ensure these signals deassert unless explicitly set further down.
        tx_payload_data_wr_en               <= '0';
        threshold_fifo_rd_en                <= '0';
        xk_real_fifo_rd_en                  <= '0';
        xk_imag_fifo_rd_en                  <= '0';
        xk_mag_sq_fifo_rd_en                <= '0';
        tx_start_stb                        <= '0';

        -- Transmit state machine
        case (tx_state) is
          when TX_IDLE =>
            tx_start_stb                    <= '0';
            tx_byte_counter                 <= 0;
            tx_payload_count                <= 0;
            tx_threshold_count              <= (others=>'0');
            -- Set UDP packet payload size, max 1472 (checked in udp_rx.vhd)
            tx_payload_size_int             <= user_payload_size;
            -- Start state machine, but only if you are actually goind to send data.
            if (spec_sense_start_stb_int = '1' AND (send_threshold = '1' OR 
                send_fft = '1' OR send_mag_squared = '1')) then
              tx_state                      <= TX_WAIT_FOR_DATA;
            end if;

          when TX_WAIT_FOR_DATA =>
            if (xk_valid = '1') then
              tx_state                      <= TX_BUFFER_DATA;
            end if;

          when TX_BUFFER_DATA =>
            if (xk_valid = '0') then
              tx_state                      <= TX_SEND_HEADER1;
            end if;

          -- Send configuration so we know what data to expect
          when TX_SEND_HEADER1 =>
            tx_payload_data                 <= config_word;
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            tx_state                        <= TX_SEND_HEADER2;

          -- Send FFT size
          when TX_SEND_HEADER2 =>
            tx_payload_data                 <= "000" & fft_size_int;
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            tx_state                        <= TX_SEND_HEADER3;

          -- Send number of bins exceeding threshold (upper byte)
          when TX_SEND_HEADER3 =>
            tx_payload_data                 <= "000" & tx_threshold_count(12 downto 8);
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            tx_state                        <= TX_SEND_HEADER4;

          when TX_SEND_HEADER4 =>
            tx_payload_data                 <= tx_threshold_count(7 downto 0);
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            -- Determine what data to send, depending on the configuration.
            if (send_threshold = '1' AND tx_threshold_count > std_logic_vector(to_unsigned(0,13))) then
              tx_state                      <= TX_SEND_THRESHOLD;
            elsif (send_fft = '1') then
              tx_state                      <= TX_SEND_XK_DATA;
            elsif (send_mag_squared = '1') then
              tx_state                      <= TX_SEND_XK_MAG_SQ;
            end if;

          -- Send threshold data continuously to network interface component, 
          -- which will send packets of tx_payload_size = 1472. We will keep
          -- track how full the packets are, so on the final packet we can
          -- 0 fill instead of using more complicated logic to change
          -- tx_packet_size.
          when TX_SEND_THRESHOLD =>
            case (tx_byte_counter) is
              when 0 =>
                -- Read enable is delayed by one cycle due to register so assert it early
                threshold_fifo_rd_en        <= '1';
                tx_byte_counter             <= 1;
                tx_payload_data             <= threshold_fifo_out(15 downto 8);
              when 1 =>
                tx_byte_counter             <= 0;
                tx_payload_data             <= threshold_fifo_out(7 downto 0);
              when others =>
            end case;
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            -- Send payload when full
            if (tx_payload_count = to_integer(unsigned(tx_payload_size_int))-1) then
              tx_start_stb                  <= '1';
              tx_payload_count              <= 0;
            end if;
            -- Sent all threshold data, determine what data to send.
            if (threshold_fifo_almost_empty = '1' AND tx_byte_counter = 1) then
              if (send_fft = '1') then
                tx_state                    <= TX_SEND_XK_DATA;
              elsif (send_mag_squared = '1') then
                tx_state                    <= TX_SEND_XK_MAG_SQ;
              else
                tx_state                    <= TX_ZERO_FILL;
              end if;
            end if;

          -- Send xk_real and xk_imag data similarly to TX_SEND_THRESHOLD 
          when TX_SEND_XK_DATA =>
            case (tx_byte_counter) is
              when 0 =>
                tx_byte_counter             <= 1;
                tx_payload_data             <= xk_real_fifo_out(15 downto 8);
              when 1 =>
                tx_byte_counter             <= 2;
                tx_payload_data             <= xk_real_fifo_out(7 downto 0);
              when 2 =>
                -- Read enable is delayed by one cycle due to register so assert it early
                xk_real_fifo_rd_en          <= '1';
                xk_imag_fifo_rd_en          <= '1';
                tx_byte_counter             <= 3;
                tx_payload_data             <= xk_imag_fifo_out(15 downto 8);
              when 3 =>
                tx_byte_counter             <= 0;
                tx_payload_data             <= xk_imag_fifo_out(7 downto 0);
              when others =>
            end case;
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            -- Send payload when full
            if (tx_payload_count = to_integer(unsigned(tx_payload_size_int))-1) then
              tx_start_stb                  <= '1';
              tx_payload_count              <= 0;
            end if;
            -- Only need to check xk_imag FIFO, because it will empty last.
            if (xk_imag_fifo_almost_empty = '1' AND tx_byte_counter = 3) then
              if (send_mag_squared = '1') then
                tx_state                    <= TX_SEND_XK_MAG_SQ;
              else
                tx_state                    <= TX_ZERO_FILL;
              end if;
            end if;

          -- Send xk_magnitude_squared data similarly to TX_SEND_THRESHOLD 
          when TX_SEND_XK_MAG_SQ =>
            case (tx_byte_counter) is
              when 0 =>
                tx_byte_counter             <= 1;
                tx_payload_data             <= xk_mag_sq_fifo_out(31 downto 24);
              when 1 =>
                tx_byte_counter             <= 2;
                tx_payload_data             <= xk_mag_sq_fifo_out(23 downto 16);
              when 2 =>
                -- Read enable is delayed by one cycle due to register so assert it early
                xk_mag_sq_fifo_rd_en        <= '1';
                tx_byte_counter             <= 3;
                tx_payload_data             <= xk_mag_sq_fifo_out(15 downto 8);
              when 3 =>
                tx_byte_counter             <= 0;
                tx_payload_data             <= xk_mag_sq_fifo_out(7 downto 0);
              when others =>
            end case;
            tx_payload_data_wr_en           <= '1';
            tx_payload_count                <= tx_payload_count + 1;
            -- Send payload when full
            if (tx_payload_count = to_integer(unsigned(tx_payload_size_int))-1) then
              tx_start_stb                  <= '1';
              tx_payload_count              <= 0;
            end if;
            -- All magnitude data sent. Zero fill if needed.
            if (xk_mag_sq_fifo_almost_empty = '1' AND tx_byte_counter = 3) then
              tx_state                      <= TX_ZERO_FILL;
            end if;

          -- Zero fill last packet
          when TX_ZERO_FILL =>
            tx_payload_data_wr_en           <= '1';
            tx_payload_data                 <= (others=>'0');
            tx_payload_count                <= tx_payload_count + 1;
            -- Send payload when full
            if (tx_payload_count = to_integer(unsigned(tx_payload_size_int))-1) then
              tx_start_stb                  <= '1';
              tx_payload_count              <= 0;
              tx_state                      <= TX_IDLE;
            end if;

          when others =>
            tx_state                        <= TX_IDLE;
        end case;

        -- Count the number of times the threshold was exceeded. This is used for
        -- the UDP packet header. tx_threshold_count is reset in the IDLE state.
        if (threshold_exceeded = '1' AND xk_valid = '1') then
          tx_threshold_count                <= std_logic_vector(unsigned(tx_threshold_count) + "01");
        end if;

        -- Debug, always send a linear counting waveform to find gaps in UDP packets
        if (send_counting_pattern = '1') then
          if (spec_sense_start_stb_int = '1') then
            debug_counter                   <= 0;
          end if;
          if (debug_counter = 255) then
            debug_counter                   <= 0;
          else
            debug_counter                   <= debug_counter + 1;
          end if;
          tx_payload_data                   <= std_logic_vector(to_unsigned(debug_counter,8));
        end if;
      end if;
    end if;
  end process;

  tx_payload_size                           <= tx_payload_size_int;

  -----------------------------------------------------------------------------
  -- Transmit FIFOs
  -- The spectrum sensing component generates data much more quickly than
  -- the network interface can transmit it. These FIFOs buffer all the data for
  -- the TX state machine to send.
  -----------------------------------------------------------------------------
  xk_real_fifo_16x8196 : fifo_16x8196
    port map (
      rst                           => reset,
      wr_clk                        => clk,
      wr_en                         => xk_real_valid,
      din                           => xk_real,
      full                          => open,
      almost_full                   => open,
      overflow                      => open,
      wr_data_count                 => open,
      rd_clk                        => clk,
      rd_en                         => xk_real_fifo_rd_en,
      dout                          => xk_real_fifo_out,
      empty                         => open,
      almost_empty                  => xk_real_fifo_almost_empty,
      underflow                     => open,
      rd_data_count                 => open);

  -- Only store data in FIFO if we are going to send it.
  xk_real_valid                     <= '1' when (xk_valid = '1' AND send_fft = '1') else '0';

  xk_imag_fifo_16x8196 : fifo_16x8196
    port map (
      rst                           => reset,
      wr_clk                        => clk,
      wr_en                         => xk_imag_valid,
      din                           => xk_imag,
      full                          => open,
      almost_full                   => open,
      overflow                      => open,
      wr_data_count                 => open,
      rd_clk                        => clk,
      rd_en                         => xk_imag_fifo_rd_en,
      dout                          => xk_imag_fifo_out,
      empty                         => open,
      almost_empty                  => xk_imag_fifo_almost_empty,
      underflow                     => open,
      rd_data_count                 => open);

  -- Only store data in FIFO if we are going to send it.
  xk_imag_valid                     <= '1' when (xk_valid = '1' AND send_fft = '1') else '0';

  xk_mag_sq_fifo_32x8196 : fifo_32x8196
    port map (
      rst                           => reset,
      wr_clk                        => clk,
      wr_en                         => xk_mag_sq_valid,
      din                           => xk_magnitude_squared,
      full                          => open,
      almost_full                   => open,
      overflow                      => open,
      wr_data_count                 => open,
      rd_clk                        => clk,
      rd_en                         => xk_mag_sq_fifo_rd_en,
      dout                          => xk_mag_sq_fifo_out,
      empty                         => open,
      almost_empty                  => xk_mag_sq_fifo_almost_empty,
      underflow                     => open,
      rd_data_count                 => open);

  -- Only store data in FIFO if we are going to send it.
  xk_mag_sq_valid                   <= '1' when (xk_valid = '1' AND send_mag_squared = '1') else '0';

  -- Handle the threshold data by only reporting bins that exceeded the threshold 
  -- limit. This will allow the data to be transmitted efficiently.
  threshold_fifo_16x8196 : fifo_16x8196
    port map (
      rst                           => reset,
      wr_clk                        => clk,
      wr_en                         => threshold_fifo_wr_en,
      din                           => xk_index_ext,
      full                          => open,
      almost_full                   => open,
      overflow                      => open,
      wr_data_count                 => threshold_fifo_wr_count,
      rd_clk                        => clk,
      rd_en                         => threshold_fifo_rd_en,
      dout                          => threshold_fifo_out,
      empty                         => open,
      almost_empty                  => threshold_fifo_almost_empty,
      underflow                     => open,
      rd_data_count                 => open);

  -- Only store bins that have exceeded that threshold and only if we are going to send threshold data.
  threshold_fifo_wr_en              <= '1' when xk_valid = '1' AND threshold_exceeded = '1' AND send_threshold = '1' else
                                       '0';
  -- Unsigned extend to 2 byte boundary
  xk_index_ext                      <= (2 downto 0 => '0') & xk_index;

end architecture;
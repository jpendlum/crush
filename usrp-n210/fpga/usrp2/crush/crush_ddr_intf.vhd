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
--  File: crush_ddr_intf.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Interface and control for CRUSH. Implements DDR LVDS I/O and 
--               UART control interface. 
--
--               Operates with full bandwidth (100 MSPS), full resolution 
--               (14-bits for the ADC, 16-bits for the DAC) IQ data. Both ADC 
--               and DAC data from CRUSH is synchronous to the input clock.
--
--               The USRP firmware has logic to correct DC offset and IQ 
--               balance for both the ADC and DAC. This path is selectable.
--
--               Note: The digital upconverters and downconverters are 
--                     bypassed, so the CRUSH user should implement the
--                     necessary rate matching filters.
--               
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity crush_ddr_intf is
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
end entity;

architecture RTL of crush_ddr_intf is

  -----------------------------------------------------------------------------
  -- Component Declaration
  -----------------------------------------------------------------------------
  component uart is
    generic (
      CLOCK_FREQ        : integer := 100e6;           -- Input clock frequency (Hz)
      BAUD              : integer := 115200;          -- Baud rate (bits/sec)
      DATA_BITS         : integer := 8;               -- Number of data bits
      PARITY            : string  := "MARK";          -- EVEN, ODD, MARK (always = '1'), SPACE (always = '0'), NONE
      NO_STROBE_ON_ERR  : string  := "TRUE");         -- No rx_data_stb if error in received data.
    port (
      clk               : in    std_logic;            -- Clock
      reset             : in    std_logic;            -- Active high reset
      tx_busy           : out   std_logic;            -- Transmitting data
      tx_data_stb       : in    std_logic;            -- Transmit buffer load and begin transmission strobe
      tx_data           : in    std_logic_vector(DATA_BITS-1 downto 0);
      rx_busy           : out   std_logic;            -- Receiving data
      rx_data_stb       : out   std_logic;            -- Receive buffer data valid strobe
      rx_data           : out   std_logic_vector(DATA_BITS-1 downto 0);
      rx_error          : out   std_logic;            -- '1' = Invalid parity bit, start bit, or stop bit(s)
      tx                : out   std_logic;            -- TX output
      rx                : in    std_logic);           -- RX input
  end component;

  component trunc_unbiased
    generic (
      WIDTH_IN        : integer;                                                -- Input bit width
      TRUNCATE        : integer);                                               -- Number of bits to truncate
    port (
      i               : in    std_logic_vector(WIDTH_IN-1 downto 0);            -- Signed Input
      o               : out   std_logic_vector(WIDTH_IN-TRUNCATE-1 downto 0));  -- Truncated Signed Output
  end component;

  component fifo_1x_to_2x
    port (
      rst               : in    std_logic;
      wr_clk            : in    std_logic;
      rd_clk            : in    std_logic;
      din               : in    std_logic_vector(35 downto 0);
      wr_en             : in    std_logic;
      rd_en             : in    std_logic;
      dout              : out   std_logic_vector(17 downto 0);
      full              : out   std_logic;
      almost_full       : out   std_logic;
      empty             : out   std_logic;
      almost_empty      : out   std_logic);
  end component;

  component fifo_2x_to_1x
    port (
      rst               : in    std_logic;
      wr_clk            : in    std_logic;
      rd_clk            : in    std_logic;
      din               : in    std_logic_vector(17 downto 0);
      wr_en             : in    std_logic;
      rd_en             : in    std_logic;
      dout              : out   std_logic_vector(35 downto 0);
      full              : out   std_logic;
      almost_full       : out   std_logic;
      empty             : out   std_logic;
      almost_empty      : out   std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  -- RX modes (lower nibble)
  constant RX_ADC_RAW_MODE        : std_logic_vector(3 downto 0) := x"0";
  constant RX_ADC_DSP_MODE        : std_logic_vector(3 downto 0) := x"1";
  constant RX_SINE_TEST_MODE      : std_logic_vector(3 downto 0) := x"2";
  constant RX_TEST_PATTERN_MODE   : std_logic_vector(3 downto 0) := x"3";
  constant RX_ALL_1s_MODE         : std_logic_vector(3 downto 0) := x"4";
  constant RX_ALL_0s_MODE         : std_logic_vector(3 downto 0) := x"5";
  constant RX_CHA_1s_CHB_0s_MODE  : std_logic_vector(3 downto 0) := x"6";
  constant RX_CHA_0s_CHB_1s_MODE  : std_logic_vector(3 downto 0) := x"7";
  constant RX_CHECK_ALIGN_MODE    : std_logic_vector(3 downto 0) := x"8";
  constant RX_TX_LOOPBACK_MODE    : std_logic_vector(3 downto 0) := x"9";
  -- TX modes (upper nibble)
  constant TX_PASSTHRU_MODE       : std_logic_vector(3 downto 0) := x"0";
  constant TX_DAC_RAW_MODE        : std_logic_vector(3 downto 0) := x"1";
  constant TX_DAC_DSP_MODE        : std_logic_vector(3 downto 0) := x"2";
  constant TX_SINE_TEST_MODE      : std_logic_vector(3 downto 0) := x"3";

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal clk_2x                 : std_logic;
  signal clk_2x_180             : std_logic;
  signal clk_2x_dcm             : std_logic;
  signal clk_2x_180_dcm         : std_logic;
  signal dcm_locked             : std_logic;
  signal fifo_reset             : std_logic;

  signal ddr_intf_mode          : std_logic_vector(7 downto 0);
  signal ddr_intf_mode_stb      : std_logic;
  signal ddr_intf_rx_mode_reg   : std_logic_vector(3 downto 0);
  signal ddr_intf_tx_mode_reg   : std_logic_vector(3 downto 0);
  signal adc_channel_a_int      : std_logic_vector(13 downto 0);
  signal adc_channel_b_int      : std_logic_vector(13 downto 0);
  signal adc_i_reg              : std_logic_vector(23 downto 0);
  signal adc_q_reg              : std_logic_vector(23 downto 0);
  signal adc_i_trunc            : std_logic_vector(13 downto 0);
  signal adc_q_trunc            : std_logic_vector(13 downto 0);
  signal adc_i_int              : std_logic_vector(13 downto 0);
  signal adc_q_int              : std_logic_vector(13 downto 0);
  signal dac_channel_a_int      : std_logic_vector(15 downto 0);
  signal dac_channel_b_int      : std_logic_vector(15 downto 0);
  signal dac_i_int              : std_logic_vector(23 downto 0);
  signal dac_q_int              : std_logic_vector(23 downto 0);
  signal tx_data_a              : std_logic_vector(15 downto 0);
  signal tx_data_b              : std_logic_vector(15 downto 0);
  signal tx_data_2x_a           : std_logic_vector(7 downto 0);
  signal tx_data_2x_b           : std_logic_vector(7 downto 0);
  signal tx_data_2x_ddr         : std_logic_vector(7 downto 0);
  signal rx_data_a              : std_logic_vector(13 downto 0);
  signal rx_data_b              : std_logic_vector(13 downto 0);
  signal rx_data_2x_a           : std_logic_vector(6 downto 0);
  signal rx_data_2x_b           : std_logic_vector(6 downto 0);
  signal rx_data_2x_ddr         : std_logic_vector(6 downto 0);
  signal rx_data_clk_2x_ddr     : std_logic;
  signal test_pattern_cnt       : integer range 0 to 4;
  signal test_pattern_a         : std_logic_vector(13 downto 0);
  signal test_pattern_b         : std_logic_vector(13 downto 0);
  signal sine_pattern_cnt       : integer range 0 to 3;
  signal sine_pattern_a         : std_logic_vector(15 downto 0);
  signal sine_pattern_b         : std_logic_vector(15 downto 0);
  
  signal tx_fifo_din              : std_logic_vector(17 downto 0);
  signal tx_fifo_almost_full_n    : std_logic;
  signal tx_fifo_almost_empty_n   : std_logic;
  signal tx_fifo_dout             : std_logic_vector(35 downto 0);
  signal tx_fifo_almost_full      : std_logic;
  signal tx_fifo_almost_empty     : std_logic;
  signal rx_fifo_din              : std_logic_vector(35 downto 0);
  signal rx_fifo_almost_full_n    : std_logic;
  signal rx_fifo_almost_empty_n   : std_logic;
  signal rx_fifo_dout             : std_logic_vector(17 downto 0);
  signal rx_fifo_almost_full      : std_logic;
  signal rx_fifo_almost_empty     : std_logic;

begin

  -- UART sets receive and transmit modes
  inst_uart : uart
    generic map (
      CLOCK_FREQ                => 100e6,
      BAUD                      => 115200,
      DATA_BITS                 => 8,
      PARITY                    => "EVEN",
      NO_STROBE_ON_ERR          => "TRUE")
    port map (
      clk                       => clk,
      reset                     => reset,
      tx_busy                   => open,
      tx_data_stb               => '0',
      tx_data                   => x"00",
      rx_busy                   => open,
      rx_data_stb               => ddr_intf_mode_stb,
      rx_data                   => ddr_intf_mode,
      rx_error                  => open,
      tx                        => open,
      rx                        => UART_RX);

  -- Register crush mode from UART
  proc_reg_crush_mode : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        ddr_intf_rx_mode_reg    <= (others=>'0');
        ddr_intf_tx_mode_reg    <= (others=>'0');
      else
        -- Only update mode when valid.
        if (ddr_intf_mode_stb = '1') then
          ddr_intf_rx_mode_reg  <= ddr_intf_mode(3 downto 0);
          ddr_intf_tx_mode_reg  <= ddr_intf_mode(7 downto 4);
        end if;
      end if;
    end if;
  end process;

  -- Truncate to 14-bits
  inst_adc_i_trunc : trunc_unbiased
    generic map (
      WIDTH_IN                  => 24,
      TRUNCATE                  => 10)
    port map (
      i                         => adc_i_reg,
      o                         => adc_i_trunc);

  -- Truncate to 14-bits
  inst_adc_q_trunc : trunc_unbiased
    generic map (
      WIDTH_IN                  => 24,
      TRUNCATE                  => 10)
    port map (
      i                         => adc_q_reg,
      o                         => adc_q_trunc);

  -- Set receive mode via UART
  proc_rx_crush_mode : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        adc_channel_a_int       <= (others=>'0');
        adc_channel_b_int       <= (others=>'0');
        adc_i_reg               <= (others=>'0');
        adc_q_reg               <= (others=>'0');
        adc_i_int               <= (others=>'0');
        adc_q_int               <= (others=>'0');
        rx_data_a               <= (others=>'0');
        rx_data_b               <= (others=>'0');
      else
        -- Register inputs to improve timing
        adc_channel_a_int       <= adc_channel_a;
        adc_channel_b_int       <= adc_channel_b;
        adc_i_reg               <= adc_i;
        adc_q_reg               <= adc_q;
        adc_i_int               <= adc_i_trunc;
        adc_q_int               <= adc_q_trunc;

        -- CRUSH sets the mode through the UART interface
        -- Most modes are for testing.
        case (ddr_intf_rx_mode_reg) is
          -- ADC data directly from the ADC interface
          when RX_ADC_RAW_MODE =>
            rx_data_a           <= adc_channel_a_int;
            rx_data_b           <= adc_channel_b_int;
          -- ADC data after processing to remove DC offset and IQ balance
          when RX_ADC_DSP_MODE =>
            rx_data_a           <= adc_i_int;
            rx_data_b           <= adc_q_int;
          -- Test tone
          when RX_SINE_TEST_MODE =>
            rx_data_a           <= sine_pattern_a(13 downto 0);
            rx_data_b           <= sine_pattern_b(13 downto 0);
          when RX_TEST_PATTERN_MODE =>
            rx_data_a           <= test_pattern_a;
            rx_data_b           <= test_pattern_b;
          when RX_ALL_1s_MODE =>
            rx_data_a           <= "11111111111111";
            rx_data_b           <= "11111111111111";
          when RX_ALL_0s_MODE =>
            rx_data_a           <= "00000000000000";
            rx_data_b           <= "00000000000000";
          when RX_CHA_1s_CHB_0s_MODE =>
            rx_data_a           <= "11111111111111";
            rx_data_b           <= "00000000000000";
          when RX_CHA_0s_CHB_1s_MODE =>
            rx_data_a           <= "00000000000000";
            rx_data_b           <= "11111111111111";
          when RX_CHECK_ALIGN_MODE =>
            rx_data_a           <= "01101101001001";
            rx_data_b           <= "00111001100011";
          -- Loopback DAC data for debug
          when RX_TX_LOOPBACK_MODE =>
            rx_data_a           <= tx_data_a(13 downto 0);
            rx_data_b           <= tx_data_b(13 downto 0);
          when others =>
            rx_data_a           <= adc_channel_a_int;
            rx_data_b           <= adc_channel_b_int;
        end case;
      end if;
    end if;
  end process;

  -- Set transmit mode via UART
  proc_tx_crush_mode : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        dac_channel_a           <= (others=>'0');
        dac_channel_b           <= (others=>'0');
        dac_channel_a_int       <= (others=>'0');
        dac_channel_b_int       <= (others=>'0');
        dac_i                   <= (others=>'0');
        dac_q                   <= (others=>'0');
        dac_i_int               <= (others=>'0');
        dac_q_int               <= (others=>'0');
      else
        -- Register outputs to improve timing
        dac_channel_a           <= dac_channel_a_int;
        dac_channel_b           <= dac_channel_b_int;
        dac_i                   <= dac_i_int;
        dac_q                   <= dac_q_int;

        -- CRUSH sets the mode through the UART interface
        -- Most modes are for testing.
        case (ddr_intf_tx_mode_reg) is
          -- Use data from host computer instead of CRUSH
          when TX_PASSTHRU_MODE =>
            dac_channel_a_int   <= dac_channel_a_in;
            dac_channel_b_int   <= dac_channel_b_in;
            dac_i_int           <= dac_i_in;
            dac_q_int           <= dac_q_in;
          -- Directly drive DACs with CRUSH
          when TX_DAC_RAW_MODE =>
            dac_channel_a_int   <= tx_data_a;
            dac_channel_b_int   <= tx_data_b;
            dac_i_int           <= dac_i_in;
            dac_q_int           <= dac_q_in;
          -- Pass CRUSH DAC data through DC offset and IQ balance correction logic
          when TX_DAC_DSP_MODE =>
            dac_channel_a_int   <= dac_channel_a_in;
            dac_channel_b_int   <= dac_channel_b_in;
            dac_i_int           <= tx_data_a & x"00";
            dac_q_int           <= tx_data_b & x"00";
          -- Directly drive DACs with test tone
          when TX_SINE_TEST_MODE =>
            dac_channel_a_int   <= sine_pattern_a;
            dac_channel_b_int   <= sine_pattern_b;
            dac_i_int           <= dac_i_in;
            dac_q_int           <= dac_q_in;
          when others =>
            dac_channel_a_int   <= dac_channel_a_in;
            dac_channel_b_int   <= dac_channel_b_in;
            dac_i_int           <= dac_i_in;
            dac_q_int           <= dac_q_in;
        end case;
      end if;
    end if;
  end process;

  -- Test patterns for debugging receive and transmit
  -- interfaces
  proc_gen_test_patterns : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        test_pattern_a          <= (others=>'0');
        test_pattern_b          <= (others=>'0');
        test_pattern_cnt        <= 0;
        sine_pattern_a          <= (others=>'0');
        sine_pattern_b          <= (others=>'0');
        sine_pattern_cnt        <= 0;
      else
        -- Generate test pattern
        if (test_pattern_cnt = 4) then
          test_pattern_cnt      <= 0;
        else
          test_pattern_cnt      <= test_pattern_cnt + 1;
        end if;
        case (test_pattern_cnt) is
          when 0 =>
            test_pattern_a      <= "11" & x"FFA";
            test_pattern_b      <= "00" & x"005";
          when 1 =>
            test_pattern_a      <= "11" & x"FAF";
            test_pattern_b      <= "00" & x"050";
          when 2 =>
            test_pattern_a      <= "11" & x"AFF";
            test_pattern_b      <= "00" & x"500";
          when 3 =>
            test_pattern_a      <= "00" & x"00C";
            test_pattern_b      <= "11" & x"FF3";
          when 4 =>
            test_pattern_a      <= "00" & x"0C0";
            test_pattern_b      <= "11" & x"F3F";
          when others =>
            test_pattern_a      <= "00" & x"C00";
            test_pattern_b      <= "11" & x"3FF";
        end case;
        -- Generate sine test pattern (Fs/4) = 25MHz tone
        if (sine_pattern_cnt = 3) then
          sine_pattern_cnt      <= 0;
        else
          sine_pattern_cnt      <= sine_pattern_cnt + 1;
        end if;
        case (sine_pattern_cnt) is
          when 0 =>
            sine_pattern_a      <= x"7FFF";
            sine_pattern_b      <= x"0000";
          when 1 =>
            sine_pattern_a      <= x"0000";
            sine_pattern_b      <= x"7FFF";
          when 2 =>
            sine_pattern_a      <= x"8000";
            sine_pattern_b      <= x"0000";
          when 3 =>
            sine_pattern_a      <= x"0000";
            sine_pattern_b      <= x"8000";
          when others =>
            sine_pattern_a      <= x"7FFF";
            sine_pattern_b      <= x"0000";
        end case;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- LVDS DDR Data Interface, 2x Clock Domain (200 MHz)
  -- Transmit 14-bit RX I/Q data and receive 16-bit TX I/Q data at 
  -- 200 MHz DDR.
  -----------------------------------------------------------------------------

  fifo_reset                    <= NOT(dcm_locked);

  -- DCM to create 2x clocks
  inst_ddr_intf_DCM : DCM_SP 
    generic map (
      CLKDV_DIVIDE              => 2.0,
      CLKFX_DIVIDE              => 1,
      CLKFX_MULTIPLY            => 4,
      CLKIN_DIVIDE_BY_2         => FALSE,
      CLKIN_PERIOD              => 10.0,
      CLKOUT_PHASE_SHIFT        => "NONE",
      CLK_FEEDBACK              => "2X",
      DESKEW_ADJUST             => "SYSTEM_SYNCHRONOUS",
      DLL_FREQUENCY_MODE        => "LOW",
      DUTY_CYCLE_CORRECTION     => TRUE,
      PHASE_SHIFT               => 0,
      STARTUP_WAIT              => FALSE)
    port map (
      CLK0                      => open,
      CLK180                    => open,
      CLK270                    => open,
      CLK2X                     => clk_2x_dcm,
      CLK2X180                  => clk_2x_180_dcm,
      CLK90                     => open,
      CLKDV                     => open,
      CLKFX                     => open,
      CLKFX180                  => open,
      LOCKED                    => dcm_locked,
      PSDONE                    => open,
      STATUS                    => open,
      CLKFB                     => clk_2x,
      CLKIN                     => clk,
      PSCLK                     => '0',
      PSEN                      => '0',
      PSINCDEC                  => '0',
      RST                       => reset);

  inst_clk2x_BUFG : BUFG
    port map (
      I                         => clk_2x_dcm,
      O                         => clk_2x);

  inst_clk2x_180_BUFG : BUFG
    port map (
      I                         => clk_2x_180_dcm,
      O                         => clk_2x_180);

  -- TX data fifo, Interleaved DDR 8 bit I & Q to interleaved SDR 16 bit I & Q
  inst_tx_fifo : fifo_2x_to_1x
    port map (
      rst                       => fifo_reset,
      wr_clk                    => clk_2x,
      rd_clk                    => clk,
      din                       => tx_fifo_din,
      wr_en                     => tx_fifo_almost_full_n,
      rd_en                     => tx_fifo_almost_empty_n,
      dout                      => tx_fifo_dout,
      full                      => open,
      almost_full               => tx_fifo_almost_full,
      empty                     => open,
      almost_empty              => tx_fifo_almost_empty);

  tx_fifo_almost_full_n         <= NOT(tx_fifo_almost_full);
  tx_fifo_almost_empty_n        <= NOT(tx_fifo_almost_empty);
  tx_fifo_din                   <= "00" & tx_data_2x_a & tx_data_2x_b;
  tx_data_a                     <= tx_fifo_dout(33 downto 26) & tx_fifo_dout(15 downto 8);
  tx_data_b                     <= tx_fifo_dout(25 downto 18) & tx_fifo_dout( 7 downto 0);

  -- DDR LVDS Data Input
  gen_tx_ddr_lvds : for i in 0 to 7 generate
    inst_IDDR2 : IDDR2
      generic map (
        DDR_ALIGNMENT           => "C0",
        INIT_Q0                 => '0',
        INIT_Q1                 => '0',
        SRTYPE                  => "ASYNC")
      port map (
        D                       => tx_data_2x_ddr(i),
        C0                      => clk_2x,
        C1                      => clk_2x_180,
        CE                      => '1',
        Q0                      => tx_data_2x_a(i),
        Q1                      => tx_data_2x_b(i),
        R                       => reset,
        S                       => '0');

    inst_IBUFDS : IBUFDS
      generic map (
        DIFF_TERM               => TRUE,
        IOSTANDARD              => "DEFAULT")
      port map (
        I                       => TX_DATA_P(i),
        IB                      => TX_DATA_N(i),
        O                       => tx_data_2x_ddr(i));
  end generate;

  -- RX data fifo, Interleaved SDR 14 bit I & Q to interleaved DDR 7 bit I & Q
  inst_rx_fifo : fifo_1x_to_2x
    port map (
      rst                       => fifo_reset,
      wr_clk                    => clk,
      rd_clk                    => clk_2x,
      din                       => rx_fifo_din,
      wr_en                     => rx_fifo_almost_full_n,
      rd_en                     => rx_fifo_almost_empty_n,
      dout                      => rx_fifo_dout,
      full                      => open,
      almost_full               => rx_fifo_almost_full,
      empty                     => open,
      almost_empty              => rx_fifo_almost_empty);

  rx_fifo_almost_full_n         <= NOT(rx_fifo_almost_full);
  rx_fifo_almost_empty_n        <= NOT(rx_fifo_almost_empty);
  rx_data_2x_a                  <= rx_fifo_dout(13 downto 7);
  rx_data_2x_b                  <= rx_fifo_dout( 6 downto 0);
  rx_fifo_din                   <= "0000" & rx_data_a(13 downto 7) & rx_data_b(13 downto 7) &
                                   "0000" & rx_data_a( 6 downto 0) & rx_data_b( 6 downto 0);

  -- DDR LVDS Data Output
  gen_rx_ddr_lvds : for i in 0 to 6 generate
    inst_ODDR2 : ODDR2
      generic map (
        DDR_ALIGNMENT           => "C0",
        INIT                    => '0',
        SRTYPE                  => "ASYNC")
      port map (
        Q                       => rx_data_2x_ddr(i),
        C0                      => clk_2x,
        C1                      => clk_2x_180,
        CE                      => '1',
        D0                      => rx_data_2x_a(i),
        D1                      => rx_data_2x_b(i),
        R                       => reset,
        S                       => '0');

    inst_OBUFDS : OBUFDS
      generic map (
        IOSTANDARD              => "DEFAULT")
      port map (
        I                       => rx_data_2x_ddr(i),
        O                       => RX_DATA_P(i),
        OB                      => RX_DATA_N(i));
  end generate;

  -- DDR LVDS Clock Output
  inst_ODDR2_clk : ODDR2
    generic map (
      DDR_ALIGNMENT             => "C0",
      INIT                      => '0',
      SRTYPE                    => "ASYNC")
    port map (
      Q                         => rx_data_clk_2x_ddr,
      C0                        => clk_2x,
      C1                        => clk_2x_180,
      CE                        => '1',
      D0                        => '1',
      D1                        => '0',
      R                         => reset,
      S                         => '0');

  inst_OBUFDS : OBUFDS
    generic map (
      IOSTANDARD                => "DEFAULT")
    port map (
      I                         => rx_data_clk_2x_ddr,
      O                         => RX_DATA_CLK_P,
      OB                        => RX_DATA_CLK_N);

end architecture;
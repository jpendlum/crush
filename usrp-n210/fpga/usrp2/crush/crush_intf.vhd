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
--  File: crush_intf.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Interface and control for CRUSH. Implements DDR LVDS I/O and 
--               UART control interface.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity crush_intf is
  port (
    clk               : in    std_logic;            -- Clock (from ADC)
    clk_180           : in    std_logic;            -- Clock (from ADC, 180 deg.)
    reset             : in    std_logic;            -- Active high reset
    RX_DATA_CLK_N     : out   std_logic;            -- RX data clock (P)
    RX_DATA_CLK_P     : out   std_logic;            -- RX data clock (N)
    RX_DATA_N         : out   std_logic_vector(13 downto 0);  -- RX data (P)
    RX_DATA_P         : out   std_logic_vector(13 downto 0);  -- RX data (N)
    UART_RX           : in    std_logic;            -- Control interface from CRUSH (RX)
    adc_channel_a     : in    std_logic_vector(13 downto 0);  -- ADC data channel a
    adc_channel_b     : in    std_logic_vector(13 downto 0);  -- ADC data channel b
    adc_i             : in    std_logic_vector(23 downto 0);  -- ADC data I, ADC data with dc offset correction
    adc_q             : in    std_logic_vector(23 downto 0)); -- ADC data Q, ADC data with dc offset correction
end entity;

architecture RTL of crush_intf is

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

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant ADC_DATA_MODE        : std_logic_vector(7 downto 0) := x"00";
  constant ADC_IQ_MODE          : std_logic_vector(7 downto 0) := x"01";
  constant SINE_WAVE_MODE       : std_logic_vector(7 downto 0) := x"02";
  constant TEST_PATTERN_MODE    : std_logic_vector(7 downto 0) := x"03";
  constant ALL_1s_MODE          : std_logic_vector(7 downto 0) := x"04";
  constant ALL_0s_MODE          : std_logic_vector(7 downto 0) := x"05";
  constant CHA_1s_CHB_0s_MODE   : std_logic_vector(7 downto 0) := x"06";
  constant CHA_0s_CHB_1s_MODE   : std_logic_vector(7 downto 0) := x"07";

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal crush_mode             : std_logic_vector(7 downto 0);
  signal crush_mode_reg         : std_logic_vector(7 downto 0);
  signal crush_mode_stb         : std_logic;
  signal adc_channel_a_int      : std_logic_vector(13 downto 0);
  signal adc_channel_b_int      : std_logic_vector(13 downto 0);
  signal adc_i_reg              : std_logic_vector(23 downto 0);
  signal adc_q_reg              : std_logic_vector(23 downto 0);
  signal adc_i_trunc            : std_logic_vector(13 downto 0);
  signal adc_q_trunc            : std_logic_vector(13 downto 0);
  signal adc_i_int              : std_logic_vector(13 downto 0);
  signal adc_q_int              : std_logic_vector(13 downto 0);
  signal rx_data_a              : std_logic_vector(13 downto 0);
  signal rx_data_b              : std_logic_vector(13 downto 0);
  signal rx_data_ddr            : std_logic_vector(13 downto 0);
  signal rx_data_clk_ddr        : std_logic;
  signal test_pattern_cnt       : integer range 0 to 4;
  signal test_pattern_a         : std_logic_vector(13 downto 0);
  signal test_pattern_b         : std_logic_vector(13 downto 0);
  signal sine_pattern_cnt       : integer range 0 to 3;
  signal sine_pattern_a         : std_logic_vector(13 downto 0);
  signal sine_pattern_b         : std_logic_vector(13 downto 0);

begin

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
      rx_data_stb               => crush_mode_stb,
      rx_data                   => crush_mode,
      rx_error                  => open,
      tx                        => open,
      rx                        => UART_RX);

  -- Truncate to 14-bits
  inst_adc_i_trunc : trunc_unbiased
    generic map (
      WIDTH_IN          => 24,
      TRUNCATE          => 10)
    port map (
      i                 => adc_i_reg,
      o                 => adc_i_trunc);

  -- Truncate to 14-bits
  inst_adc_q_trunc : trunc_unbiased
    generic map (
      WIDTH_IN          => 24,
      TRUNCATE          => 10)
    port map (
      i                 => adc_q_reg,
      o                 => adc_q_trunc);

  proc_crush_mode : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset='1') then
        adc_channel_a_int       <= (others=>'0');
        adc_channel_b_int       <= (others=>'0');
        adc_i_reg               <= (others=>'0');
        adc_q_reg               <= (others=>'0');
        adc_i_int               <= (others=>'0');
        adc_q_int               <= (others=>'0');
        crush_mode_reg          <= (others=>'0');
        rx_data_a               <= (others=>'0');
        rx_data_b               <= (others=>'0');
        test_pattern_a          <= (others=>'0');
        test_pattern_b          <= (others=>'0');
        test_pattern_cnt        <= 0;
        sine_pattern_a          <= (others=>'0');
        sine_pattern_b          <= (others=>'0');
        sine_pattern_cnt        <= 0;
      else
        -- Register inputs to improve timing
        adc_channel_a_int       <= adc_channel_a;
        adc_channel_b_int       <= adc_channel_b;
        adc_i_reg               <= adc_i;
        adc_q_reg               <= adc_q;
        adc_i_int               <= adc_i_trunc;
        adc_q_int               <= adc_q_trunc;

        -- Only update mode when valid.
        if (crush_mode_stb = '1') then
          crush_mode_reg        <= crush_mode;
        end if;
        -- CRUSH sets the mode through the UART interface
        -- Most modes are for testing.
        case (crush_mode_reg) is
          when ADC_DATA_MODE =>
            rx_data_a           <= adc_channel_a_int;
            rx_data_b           <= adc_channel_b_int;
          when ADC_IQ_MODE =>
            rx_data_a           <= adc_i_int;
            rx_data_b           <= adc_q_int;
          when SINE_WAVE_MODE =>
            rx_data_a           <= sine_pattern_a;
            rx_data_b           <= sine_pattern_b;
          when TEST_PATTERN_MODE =>
            rx_data_a           <= test_pattern_a;
            rx_data_b           <= test_pattern_b;
          when ALL_1s_MODE =>
            rx_data_a           <= "11111111111111";
            rx_data_b           <= "11111111111111";
          when ALL_0s_MODE =>
            rx_data_a           <= "00000000000000";
            rx_data_b           <= "00000000000000";
          when CHA_1s_CHB_0s_MODE =>
            rx_data_a           <= "11111111111111";
            rx_data_b           <= "00000000000000";
          when CHA_0s_CHB_1s_MODE =>
            rx_data_a           <= "00000000000000";
            rx_data_b           <= "11111111111111";
        
          when others =>
            rx_data_a           <= adc_channel_a_int;
            rx_data_b           <= adc_channel_b_int;
        end case;
        -- Generate test pattern
        if (test_pattern_cnt = 4) then
          test_pattern_cnt      <= 0;
        else
          test_pattern_cnt      <= test_pattern_cnt + 1;
        end if;
        case (test_pattern_cnt) is
          when 0 =>
            test_pattern_a      <= "11" & x"FFF";
            test_pattern_b      <= "00" & x"000";
          when 1 =>
            test_pattern_a      <= "11" & x"FFA";
            test_pattern_b      <= "00" & x"005";
          when 2 =>
            test_pattern_a      <= "11" & x"FAF";
            test_pattern_b      <= "00" & x"050";
          when 3 =>
            test_pattern_a      <= "11" & x"AFF";
            test_pattern_b      <= "00" & x"500";
          when 4 =>
            test_pattern_a      <= "00" & x"FFF";
            test_pattern_b      <= "11" & x"000";
          when others =>
            test_pattern_a      <= "11" & x"FFF";
            test_pattern_b      <= "00" & x"000";
        end case;
        -- Generate sine test pattern (Fs/4)
        if (sine_pattern_cnt = 3) then
          sine_pattern_cnt      <= 0;
        else
          sine_pattern_cnt      <= sine_pattern_cnt + 1;
        end if;
        case (sine_pattern_cnt) is
          when 0 =>
            sine_pattern_a      <= "01" & x"FFF";
            sine_pattern_b      <= "00" & x"000";
          when 1 =>
            sine_pattern_a      <= "00" & x"000";
            sine_pattern_b      <= "01" & x"FFF";
          when 2 =>
            sine_pattern_a      <= "10" & x"001";
            sine_pattern_b      <= "00" & x"000";
          when 3 =>
            sine_pattern_a      <= "00" & x"000";
            sine_pattern_b      <= "10" & x"001";
          when others =>
            sine_pattern_a      <= "01" & x"FFF";
            sine_pattern_b      <= "00" & x"000";
        end case;
      end if;
    end if;
  end process;

  -- DDR LVDS Data Output
  gen_ddr_lvds : for i in 0 to 13 generate
    inst_ODDR2 : ODDR2
      generic map (
        DDR_ALIGNMENT           => "C0",
        INIT                    => '0',
        SRTYPE                  => "ASYNC")
      port map (
        Q                       => rx_data_ddr(i),
        C0                      => clk,
        C1                      => clk_180,
        CE                      => '1',
        D0                      => rx_data_a(i),
        D1                      => rx_data_b(i),
        R                       => reset,
        S                       => '0');

    inst_OBUFDS : OBUFDS
      generic map (
        IOSTANDARD              => "DEFAULT")
      port map (
        I                       => rx_data_ddr(i),
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
      Q                         => rx_data_clk_ddr,
      C0                        => clk,
      C1                        => clk_180,
      CE                        => '1',
      D0                        => '1',
      D1                        => '0',
      R                         => reset,
      S                         => '0');

  inst_OBUFDS : OBUFDS
    generic map (
      IOSTANDARD                => "DEFAULT")
    port map (
      I                         => rx_data_clk_ddr,
      O                         => RX_DATA_CLK_P,
      OB                        => RX_DATA_CLK_N);

end architecture;
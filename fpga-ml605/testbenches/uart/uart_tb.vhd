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
--  File: uart_tb.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Testbench for Universal asynchronous receiver transmitter.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.all;

entity uart_tb is
end entity;

architecture RTL of uart_tb is

-------------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------------
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
    rx                : in    std_logic);           -- RX inputrx                : in    std_logic);           -- RX input
end component;

-------------------------------------------------------------------------------
-- Constant Declaration
-------------------------------------------------------------------------------
constant ClockRate            : real    := 100.0e6;
constant ClockPeriod          : time    := (1.0e12/ClockRate)*(1 ps);
constant Timeout              : time    := 5 sec;

constant CLOCK_FREQ           : integer := integer(ClockRate);
constant BAUD                 : integer := 115200;
constant DATA_BITS            : integer := 8;
constant BIT_PERIOD           : integer := (CLOCK_FREQ/BAUD);
constant HALF_BIT_PERIOD      : integer := (CLOCK_FREQ/BAUD)/2;

-------------------------------------------------------------------------------
-- Signal Declaration
-------------------------------------------------------------------------------
signal clk                    : std_logic := '0';
signal reset                  : std_logic := '0';
signal reset_n                : std_logic := '1';

signal tx_busy                : std_logic;
signal tx_data_stb            : std_logic;
signal tx_data                : std_logic_vector(DATA_BITS-1 downto 0);
signal rx_busy                : std_logic;
signal rx_data_stb            : std_logic;
signal rx_data                : std_logic_vector(DATA_BITS-1 downto 0);
signal rx_error               : std_logic;
signal tx                     : std_logic;
signal rx                     : std_logic := '1';  -- Uart IDLE state

signal rx_test_data           : std_logic_vector(DATA_BITS-1 downto 0);

begin

  -------------------------------------------------------------------------------
  -- Create Clock Process
  -------------------------------------------------------------------------------
  proc_create_clock : process
  begin
    clk               <= '0';
    wait for ClockPeriod/2;
    clk               <= '1';
    wait for ClockPeriod/2;
  end process;

  -------------------------------------------------------------------------------
  -- Reset Process
  -------------------------------------------------------------------------------
  proc_reset : process
  begin
    reset             <= '1';
    wait for 10*ClockPeriod;
    wait until clk = '1';
    reset             <= '0';
    wait;
  end process;
  reset_n             <= reset;

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
  -- Design Under Test
  -------------------------------------------------------------------------------
  dut : uart
  generic map (
    CLOCK_FREQ        => CLOCK_FREQ,
    BAUD              => BAUD,
    DATA_BITS         => DATA_BITS,
    PARITY            => "EVEN",
    NO_STROBE_ON_ERR  => "FALSE")
  port map (
    clk               => clk,
    reset             => reset,
    tx_busy           => tx_busy,
    tx_data_stb       => tx_data_stb,
    tx_data           => tx_data,
    rx_busy           => rx_busy,
    rx_data_stb       => rx_data_stb,
    rx_data           => rx_data,
    rx_error          => rx_error,
    tx                => tx,
    rx                => rx);

  -------------------------------------------------------------------------------
  -- Test Bench
  -------------------------------------------------------------------------------
  proc_test_bench : process
  begin
    tx_data_stb       <= '0';
    tx_data           <= (others=>'0');
    rx                <= '1';
    rx_test_data      <= x"A5";
    -- Wait for reset
    wait until reset = '0';
    -- Align simulation time with rising clock edge
    wait until clk = '1';

    -- Wait for 1 bit
    wait for BIT_PERIOD*ClockPeriod;

    -- Send RX message
    rx                <= '0'; -- Start bit
    wait for BIT_PERIOD*ClockPeriod;
    for i in 0 to DATA_BITS-1 loop
      rx              <= rx_test_data(i);
      wait for BIT_PERIOD*ClockPeriod;
    end loop;
    rx                <= '1'; -- Invalid parity bit
    wait for BIT_PERIOD*ClockPeriod;
    rx                <= '1'; -- Stop bit
    wait for BIT_PERIOD*ClockPeriod;

    -- Realign with rising clock edge
    wait until clk = '1';

    tx_data_stb       <= '1';
    tx_data           <= x"C9";
    wait until clk = '1';
    tx_data_stb       <= '0';

    wait;

  end process;

end architecture;
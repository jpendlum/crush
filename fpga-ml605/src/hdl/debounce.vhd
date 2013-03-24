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
--  File: debounce.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Debounces input by sampling the input single twice
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debounce is
  generic (
    CLOCK_FREQ        : integer := 100e6;   -- Clock frequency (Hz)
    SAMPLE_TIME       : integer := 10);     -- Time between debounce samples (millseconds)
  port (
    clk               : in    std_logic;    -- Clock
    reset             : in    std_logic;    -- Active high reset
    input_async       : in    std_logic;    -- Asynchronous input to debounce
    input_sync        : out   std_logic);   -- Debounced synchronous input
end entity;

architecture RTL of debounce is

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant DEBOUNCE_PERIOD  : integer := integer((real(SAMPLE_TIME)/(1.0/real(CLOCK_FREQ)))/1.0e3);

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal debounce_cnt       : integer range 0 to DEBOUNCE_PERIOD-1;
  signal input_async_meta1  : std_logic;
  signal input_async_meta2  : std_logic;
  signal input_async_samp1  : std_logic;
  signal input_async_samp2  : std_logic;

begin

  proc_debounce : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        debounce_cnt        <= 0;
        input_async_meta1   <= '0';
        input_async_meta2   <= '0';
        input_async_samp1   <= '0';
        input_async_samp2   <= '0';
        input_sync          <= '0';
      else
        -- Synchronizer
        input_async_meta1   <= input_async;
        input_async_meta2   <= input_async_meta1;
        -- Debounce sampling
        if (debounce_cnt = DEBOUNCE_PERIOD-1) then
          input_async_samp1 <= input_async_meta2;
          input_async_samp2 <= input_async_samp1;
          debounce_cnt      <= 0;
        else
          debounce_cnt      <= debounce_cnt + 1;
        end if;
        -- Only update output on stable input
        if (input_async_samp1 = '1' AND input_async_samp2 = '1') then
          input_sync        <= '1';
        elsif (input_async_samp1 = '0' AND input_async_samp2 = '0') then
          input_sync        <= '0';
        end if;
      end if;
    end if;
  end process;

end architecture;
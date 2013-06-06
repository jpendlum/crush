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
--  File: edge_detect.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Reports a change in the input vector.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detect is
  generic (
    EDGE              : string  := "RISING"); -- RISING, FALLING, or BOTH
  port (
    clk               : in    std_logic;      -- Clock
    reset             : in    std_logic;      -- Active high reset
    input_detect      : in    std_logic;      -- Input data
    edge_detect_stb   : out   std_logic);     -- Edge detected strobe
end entity;

architecture RTL of edge_detect is

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal input_detect_dly1      : std_logic;

begin

  proc_edge_detect : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset='1') then
        input_detect_dly1       <= '0';
        edge_detect_stb         <= '0';
      else
        input_detect_dly1       <= input_detect;
        -- Ensure strobe is 1 clock cycle long
        edge_detect_stb         <= '0';
        -- Rising edge detected
        if (EDGE(EDGE'left) = 'R' AND input_detect = '0' AND input_detect_dly1 = '1') then
          edge_detect_stb       <= '1';
        end if;
        -- Falling edge detected
        if (EDGE(EDGE'left) = 'F' AND input_detect = '1' AND input_detect_dly1 = '0') then
          edge_detect_stb       <= '1';
        end if;
        -- Either edge detected
        if (EDGE(EDGE'left) = 'B' AND input_detect /= input_detect_dly1) then
          edge_detect_stb       <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;
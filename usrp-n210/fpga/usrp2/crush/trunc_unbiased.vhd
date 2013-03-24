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
--  File: trunc_unbiased.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Truncates input without negative bias.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trunc_unbiased is
  generic (
    WIDTH_IN        : integer;                                                -- Input bit width
    TRUNCATE        : integer);                                               -- Number of bits to truncate
  port (
    i               : in    std_logic_vector(WIDTH_IN-1 downto 0);            -- Signed Input
    o               : out   std_logic_vector(WIDTH_IN-TRUNCATE-1 downto 0));  -- Truncated Signed Output
end entity;

architecture RTL of trunc_unbiased is

begin

  proc_trunc_unbiased : process(i)
    variable or_reduce    : std_logic := '0';
  begin
    for k in 0 to TRUNCATE-1 loop
      if (k = 0) then
        or_reduce         := i(k);
      else
        or_reduce         := or_reduce OR i(k);
      end if;
    end loop;
    o                     <= std_logic_vector(unsigned(i(WIDTH_IN-1 downto TRUNCATE)) + ('0' & (i(WIDTH_IN-1) AND or_reduce)));
  end process;

end RTL;
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
--  File: saturate.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Inputs that extend beyond the upper or lower limits are
--               kept from exceeding the upper or lower limit. This prevents 
--               signals from wrapping around.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity saturate is
  generic (
    WIDTH_IN        : integer;                                        -- Input bit width
    WIDTH_OUT       : integer);                                       -- Output bit width
  port (
    i               : in    std_logic_vector(WIDTH_IN-1 downto 0);    -- Signed Input 
    o               : out   std_logic_vector(WIDTH_OUT-1 downto 0));  -- Signed Saturated Output
end entity;

architecture RTL of saturate is

  signal upper_limit    : std_logic_vector(WIDTH_IN-1 downto 0);
  signal lower_limit    : std_logic_vector(WIDTH_IN-1 downto 0);

begin

  upper_limit           <= (WIDTH_IN-1 downto WIDTH_OUT-1 => '0') & (WIDTH_OUT-2 downto 0 => '1');
  lower_limit           <= (WIDTH_IN-1 downto WIDTH_OUT-1 => '1') & (WIDTH_OUT-2 downto 0 => '0');

  proc_saturate : process(i)
  begin
    -- Positive saturate
    if (signed(i) > signed(upper_limit)) then
      o                 <= '0' & (WIDTH_OUT-2 downto 0 => '1');
    -- Negative saturate
    elsif (signed(i) < signed(lower_limit)) then
      o                 <= '1' & (WIDTH_OUT-2 downto 0 => '0');
    -- Input does not need to be saturated
    else
      o                 <= i(WIDTH_OUT-1 downto 0);
    end if;
  end process;

end RTL;
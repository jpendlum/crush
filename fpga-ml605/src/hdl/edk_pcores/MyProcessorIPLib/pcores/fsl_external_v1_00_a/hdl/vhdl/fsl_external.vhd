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
--  File: fsl_external.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Forwards internal FSL signals to external ports to be used 
--               outside of the Microblaze instance.    
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk              : Synchronous clock
-- FSL_Rst              : System reset, should always come from FSL bus
-- FSL_S_Clk            : Slave asynchronous clock
-- FSL_S_Read           : Read signal, requiring next available input to be read
-- FSL_S_Data           : Input data
-- FSL_S_CONTROL        : Control Bit, indicating the input data are control word
-- FSL_S_Exists         : Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk            : Master asynchronous clock
-- FSL_M_Write          : Write signal, enabling writing to output FSL bus
-- FSL_M_Data           : Output data
-- FSL_M_Control        : Control Bit, indicating the output data are contol word
-- FSL_M_Full           : Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity fsl_external is
  port 
  (
    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add or delete. 
    FSL_Clk             : in    std_logic;
    FSL_Rst             : in    std_logic;
    FSL_S_Clk           : in    std_logic;
    FSL_S_Read          : out   std_logic;
    FSL_S_Data          : in    std_logic_vector(0 to 31);
    FSL_S_Control       : in    std_logic;
    FSL_S_Exists        : in    std_logic;
    FSL_M_Clk           : in    std_logic;
    FSL_M_Write         : out   std_logic;
    FSL_M_Data          : out   std_logic_vector(0 to 31);
    FSL_M_Control       : out   std_logic;
    FSL_M_Full          : in    std_logic;
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
    FSL_Ext_Rst         : out   std_logic;
    FSL_Ext_S_Read      : in    std_logic;
    FSL_Ext_S_Data      : out   std_logic_vector(0 to 31);
    FSL_Ext_S_Control   : out   std_logic;
    FSL_Ext_S_Exists    : out   std_logic;
    FSL_Ext_M_Write     : in    std_logic;
    FSL_Ext_M_Data      : in    std_logic_vector(0 to 31);
    FSL_Ext_M_Control   : in    std_logic;
    FSL_Ext_M_Full      : out   std_logic);

  attribute SIGIS               : string; 
  attribute SIGIS of FSL_Clk    : signal is "Clk"; 
  attribute SIGIS of FSL_S_Clk  : signal is "Clk"; 
  attribute SIGIS of FSL_M_Clk  : signal is "Clk"; 

end fsl_external;

architecture RTL of fsl_external is

begin

  FSL_Ext_Rst           <= FSL_Rst;
  FSL_S_Read            <= FSL_Ext_S_Read;
  FSL_Ext_S_Data        <= FSL_S_Data;
  FSL_Ext_S_Control     <= FSL_S_Control;
  FSL_Ext_S_Exists      <= FSL_S_Exists;
  FSL_M_Write           <= FSL_Ext_M_Write;
  FSL_M_Data            <= FSL_Ext_M_Data;
  FSL_M_Control         <= FSL_Ext_M_Control;
  FSL_Ext_M_Full        <= FSL_M_Full;

end architecture;

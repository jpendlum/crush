------------------------------------------------------------------------
-- Title      : Vector Configuration Testbench
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : configuration_tb.vhd
-- Version    : 1.4
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------
-- Description: Management
--
--              This testbench will control the speed settings of the
--              EMAC block (if required) by driving the Tie-off vector.
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity configuration_tb is
    port(
      reset                 : out std_logic;

      ------------------------------------------------------------------
      -- Host interface: host_clk is always required
      ------------------------------------------------------------------
      host_clk              : out std_logic;

      ------------------------------------------------------------------
      -- Testbench semaphores
      ------------------------------------------------------------------
      configuration_busy    : out boolean;
      monitor_finished_1g   : in  boolean;
      monitor_finished_100m : in  boolean;
      monitor_finished_10m  : in  boolean

      );
end configuration_tb;


architecture behavioral of configuration_tb is
  signal hostclk : std_logic;


begin

    --------------------------------------------------------------------
    -- HOSTCLK driver
    --------------------------------------------------------------------

     -- Drive HOSTCLK at one third the frequency of GTX_CLK
     p_hostclk : process
     begin
         hostclk <= '0';
         wait for 2 ns;
         loop
             wait for 12 ns;
             hostclk <= '1';
             wait for 12 ns;
             hostclk <= '0';
         end loop;
     end process P_hostclk;

     host_clk <= hostclk;


    --------------------------------------------------------------------
    -- Testbench configuration
    --------------------------------------------------------------------
    tb_configuration : process
    begin

      reset <= '1';

      -- test bench semaphores
      configuration_busy <= false;

      wait for 200 ns;
      configuration_busy <= true;

      -- Reset the core
      assert false
      report "Resetting the design..." & cr
      severity note;
      assert false
      report "Timing checks are not valid" & cr
      severity note;

      reset <= '1';
      wait for  4000 ns;
      reset <= '0';
      wait for 200 ns;

      assert false
      report "Timing checks are valid" & cr
      severity note;

      wait for 15 us;

      wait for 100 ns;
      configuration_busy <= false;

      -- Wait for 1Gb/s frames to complete
      while (not monitor_finished_1g) loop
         wait for 8 ns;
      end loop;
      wait for 100 ns;

      -- Our work here is done
        assert false
      report "Simulation stopped"
      severity failure;

    end process tb_configuration;


    --------------------------------------------------------------------
    -- If the simulation is still going after 2 ms
    -- then something has gone wrong
    --------------------------------------------------------------------
    p_timebomb : process
    begin
      wait for 2 ms;
     assert false
     report "ERROR - Testbench timed out"
     severity failure;
    end process p_timebomb;


end behavioral;

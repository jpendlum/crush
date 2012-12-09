------------------------------------------------------------------------
-- Title      : Demo Testbench
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : demo_tb.vhd
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
-- Description: This testbench will exercise the PHY ports of the EMAC
--              to demonstrate the functionality.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;


architecture behavioral of testbench is


  ----------------------------------------------------------------------
  -- Component declaration for temac_core_example_design
  --                           (the top level EMAC example deisgn)
  ----------------------------------------------------------------------
  component temac_core_example_design
    port(
        -- Client receiver interface
        EMACCLIENTRXDVLD         : out std_logic;
        EMACCLIENTRXFRAMEDROP    : out std_logic;
        EMACCLIENTRXSTATS        : out std_logic_vector(6 downto 0);
        EMACCLIENTRXSTATSVLD     : out std_logic;
        EMACCLIENTRXSTATSBYTEVLD : out std_logic;

        -- Client transmitter interface
        CLIENTEMACTXIFGDELAY     : in  std_logic_vector(7 downto 0);
        EMACCLIENTTXSTATS        : out std_logic;
        EMACCLIENTTXSTATSVLD     : out std_logic;
        EMACCLIENTTXSTATSBYTEVLD : out std_logic;

        -- MAC Control interface
        CLIENTEMACPAUSEREQ       : in  std_logic;
        CLIENTEMACPAUSEVAL       : in  std_logic_vector(15 downto 0);

        -- Clock signal
        GTX_CLK                  : in  std_logic;

        -- GMII interface
        GMII_TXD                 : out std_logic_vector(7 downto 0);
        GMII_TX_EN               : out std_logic;
        GMII_TX_ER               : out std_logic;
        GMII_TX_CLK              : out std_logic;
        GMII_RXD                 : in  std_logic_vector(7 downto 0);
        GMII_RX_DV               : in  std_logic;
        GMII_RX_ER               : in  std_logic;
        GMII_RX_CLK              : in  std_logic;
        MII_TX_CLK               : in  std_logic;
        GMII_COL                 : in  std_logic;
        GMII_CRS                 : in  std_logic;

        REFCLK                   : in  std_logic;

        -- Asynchronous Reset
        RESET                    : in  std_logic
      );
  end component;


  component configuration_tb is
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
  end component;


  ----------------------------------------------------------------------
  -- Component declaration for the PHY stimulus and monitor
  ----------------------------------------------------------------------

  component phy_tb is
    port(
      ------------------------------------------------------------------
      -- GMII interface
      ------------------------------------------------------------------
      gmii_txd              : in  std_logic_vector(7 downto 0);
      gmii_tx_en            : in  std_logic;
      gmii_tx_er            : in  std_logic;
      gmii_tx_clk           : in  std_logic;
      gmii_rxd              : out std_logic_vector(7 downto 0);
      gmii_rx_dv            : out std_logic;
      gmii_rx_er            : out std_logic;
      gmii_rx_clk           : out std_logic;
      gmii_col              : out std_logic;
      gmii_crs              : out std_logic;
      mii_tx_clk            : out std_logic;

      ------------------------------------------------------------------
      -- Testbench semaphores
      ------------------------------------------------------------------
      configuration_busy    : in  boolean;
      monitor_finished_1g   : out boolean;
      monitor_finished_100m : out boolean;
      monitor_finished_10m  : out boolean
    );
  end component;


  ----------------------------------------------------------------------
  -- Testbench signals
  ----------------------------------------------------------------------
    signal reset              : std_logic := '1';

    signal tx_client_clk      : std_logic;
    signal tx_ifg_delay       : std_logic_vector(7 downto 0)  := (others => '0');
    signal rx_client_clk      : std_logic;
    signal pause_val          : std_logic_vector(15 downto 0) := (others => '0');
    signal pause_req          : std_logic := '0';

    signal rx_clk_enable      : std_logic;
    signal tx_clk_enable      : std_logic;

    -- GMII signals
    signal gmii_tx_clk        : std_logic;
    signal gmii_tx_en         : std_logic;
    signal gmii_tx_er         : std_logic;
    signal gmii_txd           : std_logic_vector(7 downto 0);
    signal gmii_rx_clk        : std_logic;
    signal gmii_rx_dv         : std_logic;
    signal gmii_rx_er         : std_logic;
    signal gmii_rxd           : std_logic_vector(7 downto 0);
    -- Not asserted: full duplex only testbench
    signal mii_tx_clk         : std_logic;
    signal gmii_crs           : std_logic := '0';
    signal gmii_col           : std_logic := '0';


    -- Clock signals
    signal host_clk           : std_logic := '0';
    signal gtx_clk            : std_logic;
    signal refclk             : std_logic;

    ------------------------------------------------------------------
    -- Testbench semaphores
    ------------------------------------------------------------------
    signal configuration_busy    : boolean := false;
    signal monitor_finished_1g   : boolean := false;
    signal monitor_finished_100m : boolean := false;
    signal monitor_finished_10m  : boolean := false;


begin

  ----------------------------------------------------------------------
  -- Wire up device under test
  ----------------------------------------------------------------------
  dut : temac_core_example_design
  port map (
    -- Client receiver interface
    EMACCLIENTRXDVLD               => open,
    EMACCLIENTRXFRAMEDROP          => open,
    EMACCLIENTRXSTATS              => open,
    EMACCLIENTRXSTATSVLD           => open,
    EMACCLIENTRXSTATSBYTEVLD       => open,

    -- Client transmitter interface
    CLIENTEMACTXIFGDELAY           => tx_ifg_delay,
    EMACCLIENTTXSTATS              => open,
    EMACCLIENTTXSTATSVLD           => open,
    EMACCLIENTTXSTATSBYTEVLD       => open,

    -- MAC Control interface
    CLIENTEMACPAUSEREQ             => pause_req,
    CLIENTEMACPAUSEVAL             => pause_val,

    -- Clock signal
    GTX_CLK                       => gtx_clk,

    -- GMII interface
    GMII_TXD                      => gmii_txd,
    GMII_TX_EN                    => gmii_tx_en,
    GMII_TX_ER                    => gmii_tx_er,
    GMII_TX_CLK                   => gmii_tx_clk,
    GMII_RXD                      => gmii_rxd,
    GMII_RX_DV                    => gmii_rx_dv,
    GMII_RX_ER                    => gmii_rx_er,
    GMII_RX_CLK                   => gmii_rx_clk,
    MII_TX_CLK                    => mii_tx_clk,
    GMII_COL                      => gmii_col,
    GMII_CRS                      => gmii_crs,

    REFCLK                          => refclk,

    -- Asynchronous Reset
    RESET                           => reset
  );


    ----------------------------------------------------------------------------
    -- Flow control is unused in this demonstration
    ----------------------------------------------------------------------------
    pause_req <= '0';
    pause_val <= "0000000000000000";


    ----------------------------------------------------------------------------
    -- Clock drivers
    ----------------------------------------------------------------------------

    -- Drive GTX_CLK at 125 MHz
    p_gtx_clk : process
    begin
        gtx_clk <= '0';
        wait for 10 ns;
        loop
            wait for 4 ns;
            gtx_clk <= '1';
            wait for 4 ns;
            gtx_clk <= '0';
        end loop;
    end process p_gtx_clk;

    -- Drive refclk at 200MHz
    p_ref_clk : process
    begin
        refclk <= '0';
        wait for 10 ns;
        loop
            wait for 2.5 ns;
            refclk <= '1';
            wait for 2.5 ns;
            refclk <= '0';
        end loop;
    end process p_ref_clk;


  ----------------------------------------------------------------------
  -- Instantiate the PHY stimulus and monitor
  ----------------------------------------------------------------------

  phy_test: phy_tb
    port map (
      ------------------------------------------------------------------
      -- GMII interface
      ------------------------------------------------------------------
      gmii_txd              => gmii_txd,
      gmii_tx_en            => gmii_tx_en,
      gmii_tx_er            => gmii_tx_er,
      gmii_tx_clk           => gmii_tx_clk,
      gmii_rxd              => gmii_rxd,
      gmii_rx_dv            => gmii_rx_dv,
      gmii_rx_er            => gmii_rx_er,
      gmii_rx_clk           => gmii_rx_clk,
      gmii_col              => gmii_col,
      gmii_crs              => gmii_crs,
      mii_tx_clk            => mii_tx_clk,

      ------------------------------------------------------------------
      -- Testbench semaphores
      ------------------------------------------------------------------
      configuration_busy    => configuration_busy,
      monitor_finished_1g   => monitor_finished_1g,
      monitor_finished_100m => monitor_finished_100m,
      monitor_finished_10m  => monitor_finished_10m
    );

  ----------------------------------------------------------------------
  -- Instantiate the no-host configuration stimulus
  ----------------------------------------------------------------------

  config_test: configuration_tb
    port map (
      reset                 => reset,

      ------------------------------------------------------------------
      -- Host interface: host_clk is always required
      ------------------------------------------------------------------
      host_clk              => host_clk,
      configuration_busy    => configuration_busy,
      monitor_finished_1g   => monitor_finished_1g,
      monitor_finished_100m => monitor_finished_100m,
      monitor_finished_10m  => monitor_finished_10m
    );

end behavioral;

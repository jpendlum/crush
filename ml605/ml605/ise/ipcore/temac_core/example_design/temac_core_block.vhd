-------------------------------------------------------------------------------
-- Title      : Block-level Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : temac_core_block.vhd
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
-------------------------------------------------------------------------------
-- Description:  This is the block-level wrapper for the Virtex-6 Embedded
--               Tri-Mode Ethernet MAC. It is intended that this example design
--               can be quickly adapted and downloaded onto an FPGA to provide
--               a hardware test environment.
--
--               The block-level wrapper:
--
--               * instantiates appropriate PHY interface modules (GMII, MII,
--                 RGMII, SGMII or 1000BASE-X) as required per the user
--                 configuration;
--
--               * instantiates some clocking and reset resources to operate
--                 the EMAC and its example design.
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Entity declaration for the block-level wrapper
-------------------------------------------------------------------------------

entity temac_core_block is
   port(

      -- TX clock output
      TX_CLK_OUT               : out std_logic;
      -- TX clock input from BUFG
      TX_CLK                   : in  std_logic;

      -- Speed indicator
      EMACSPEEDIS10100         : out std_logic;

      -- Client receiver interface
      RX_CLIENT_CLK_ENABLE     : out std_logic;
      EMACCLIENTRXD            : out std_logic_vector(7 downto 0);
      EMACCLIENTRXDVLD         : out std_logic;
      EMACCLIENTRXGOODFRAME    : out std_logic;
      EMACCLIENTRXBADFRAME     : out std_logic;
      EMACCLIENTRXFRAMEDROP    : out std_logic;
      EMACCLIENTRXSTATS        : out std_logic_vector(6 downto 0);
      EMACCLIENTRXSTATSVLD     : out std_logic;
      EMACCLIENTRXSTATSBYTEVLD : out std_logic;

      -- Client transmitter interface
      TX_CLIENT_CLK_ENABLE     : out std_logic;
      CLIENTEMACTXD            : in  std_logic_vector(7 downto 0);
      CLIENTEMACTXDVLD         : in  std_logic;
      EMACCLIENTTXACK          : out std_logic;
      CLIENTEMACTXFIRSTBYTE    : in  std_logic;
      CLIENTEMACTXUNDERRUN     : in  std_logic;
      EMACCLIENTTXCOLLISION    : out std_logic;
      EMACCLIENTTXRETRANSMIT   : out std_logic;
      CLIENTEMACTXIFGDELAY     : in  std_logic_vector(7 downto 0);
      EMACCLIENTTXSTATS        : out std_logic;
      EMACCLIENTTXSTATSVLD     : out std_logic;
      EMACCLIENTTXSTATSBYTEVLD : out std_logic;

      -- MAC control interface
      CLIENTEMACPAUSEREQ       : in  std_logic;
      CLIENTEMACPAUSEVAL       : in  std_logic_vector(15 downto 0);

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               : in  std_logic;

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

      -- Asynchronous reset
      RESET                    : in  std_logic

   );
end temac_core_block;


architecture TOP_LEVEL of temac_core_block is

-------------------------------------------------------------------------------
-- Component declarations for lower hierarchial level entities
-------------------------------------------------------------------------------

  -- Component declaration for the primitive-level EMAC wrapper
  component temac_core is
    port(

      -- Client receiver interface
      EMACCLIENTRXCLIENTCLKOUT    : out std_logic;
      CLIENTEMACRXCLIENTCLKIN     : in  std_logic;
      EMACCLIENTRXD               : out std_logic_vector(7 downto 0);
      EMACCLIENTRXDVLD            : out std_logic;
      EMACCLIENTRXDVLDMSW         : out std_logic;
      EMACCLIENTRXGOODFRAME       : out std_logic;
      EMACCLIENTRXBADFRAME        : out std_logic;
      EMACCLIENTRXFRAMEDROP       : out std_logic;
      EMACCLIENTRXSTATS           : out std_logic_vector(6 downto 0);
      EMACCLIENTRXSTATSVLD        : out std_logic;
      EMACCLIENTRXSTATSBYTEVLD    : out std_logic;

      -- Client transmitter interface
      EMACCLIENTTXCLIENTCLKOUT    : out std_logic;
      CLIENTEMACTXCLIENTCLKIN     : in  std_logic;
      CLIENTEMACTXD               : in  std_logic_vector(7 downto 0);
      CLIENTEMACTXDVLD            : in  std_logic;
      CLIENTEMACTXDVLDMSW         : in  std_logic;
      EMACCLIENTTXACK             : out std_logic;
      CLIENTEMACTXFIRSTBYTE       : in  std_logic;
      CLIENTEMACTXUNDERRUN        : in  std_logic;
      EMACCLIENTTXCOLLISION       : out std_logic;
      EMACCLIENTTXRETRANSMIT      : out std_logic;
      CLIENTEMACTXIFGDELAY        : in  std_logic_vector(7 downto 0);
      EMACCLIENTTXSTATS           : out std_logic;
      EMACCLIENTTXSTATSVLD        : out std_logic;
      EMACCLIENTTXSTATSBYTEVLD    : out std_logic;

      -- MAC control interface
      CLIENTEMACPAUSEREQ          : in  std_logic;
      CLIENTEMACPAUSEVAL          : in  std_logic_vector(15 downto 0);

      -- Clock signals
      GTX_CLK                     : in  std_logic;
      PHYEMACTXGMIIMIICLKIN       : in  std_logic;
      EMACPHYTXGMIIMIICLKOUT      : out std_logic;

      -- GMII interface
      GMII_TXD                    : out std_logic_vector(7 downto 0);
      GMII_TX_EN                  : out std_logic;
      GMII_TX_ER                  : out std_logic;
      GMII_RXD                    : in  std_logic_vector(7 downto 0);
      GMII_RX_DV                  : in  std_logic;
      GMII_RX_ER                  : in  std_logic;
      GMII_RX_CLK                 : in  std_logic;
      MII_TX_CLK                  : in  std_logic;
      GMII_COL                    : in  std_logic;
      GMII_CRS                    : in  std_logic;

      -- Speed indicator
      EMACSPEEDIS10100            : out std_logic;

      -- MMCM lock indicator
      MMCM_LOCKED                 : in  std_logic;

      -- Asynchronous reset
      RESET                       : in  std_logic

    );
  end component;

  -- Component declaration for the GMII physcial interface
  component gmii_if
    port(
      RESET          : in  std_logic;
      -- GMII interface
      GMII_TXD       : out std_logic_vector(7 downto 0);
      GMII_TX_EN     : out std_logic;
      GMII_TX_ER     : out std_logic;
      GMII_TX_CLK    : out std_logic;
      GMII_RXD       : in  std_logic_vector(7 downto 0);
      GMII_RX_DV     : in  std_logic;
      GMII_RX_ER     : in  std_logic;
      -- MAC interface
      TXD_FROM_MAC   : in  std_logic_vector(7 downto 0);
      TX_EN_FROM_MAC : in  std_logic;
      TX_ER_FROM_MAC : in  std_logic;
      TX_CLK         : in  std_logic;
      RXD_TO_MAC     : out std_logic_vector(7 downto 0);
      RX_DV_TO_MAC   : out std_logic;
      RX_ER_TO_MAC   : out std_logic;
      RX_CLK         : in  std_logic
    );
  end component;

  -- Component declaration for the FCS block
  component fcs_blk_mii is
   port(
      -- Global signals
      reset               : in  std_logic;
      -- PHY-side input signals
      tx_phy_clk          : in  std_logic;
      txd_from_mac        : in  std_logic_vector(7 downto 0);
      tx_en_from_mac      : in  std_logic;
      tx_er_from_mac      : in  std_logic;
      -- Client-side signals
      tx_client_clk       : in  std_logic;
      tx_stats_byte_valid : in  std_logic;
      tx_collision        : in  std_logic;
      speed_is_10_100     : in  std_logic;
      -- PHY outputs
      txd                 : out std_logic_vector(7 downto 0);
      tx_en               : out std_logic;
      tx_er               : out std_logic
    );
  end component;


-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

    -- Power and ground signals
    signal gnd_i                      : std_logic;
    signal vcc_i                      : std_logic;

    -- Asynchronous reset signals
    signal reset_ibuf_i               : std_logic;
    signal reset_i                    : std_logic;

    -- Client clocking signals
    signal rx_client_clk_out_i        : std_logic;
    signal rx_client_clk_in_i         : std_logic;
    signal tx_client_clk_out_i        : std_logic;
    signal tx_client_clk_in_i         : std_logic;
    signal tx_enable_i                : std_logic;
    signal tx_enable_pre_r            : std_logic;
    signal tx_enable_r                : std_logic;
    signal rx_enable_i                : std_logic;
    signal rx_enable_pre_r            : std_logic;
    signal rx_enable_r                : std_logic;

    -- Physical interface clocking signals
    signal tx_gmii_mii_clk_out_i      : std_logic;
    signal tx_gmii_mii_clk_in_i       : std_logic;

    -- Client acknowledge signals
    signal tx_client_ack_r            : std_logic;
    signal tx_client_ack_i            : std_logic;

    -- Physical interface signals
    signal gmii_tx_en_i               : std_logic;
    signal gmii_tx_er_i               : std_logic;
    signal gmii_txd_i                 : std_logic_vector(7 downto 0);
    signal gmii_tx_en_fa_i            : std_logic;
    signal gmii_tx_er_fa_i            : std_logic;
    signal gmii_txd_fa_i              : std_logic_vector(7 downto 0);
    signal mii_tx_clk_i               : std_logic;
    signal gmii_col_i                 : std_logic;
    signal gmii_rx_clk_i              : std_logic;
    signal gmii_rx_dv_r               : std_logic;
    signal gmii_rx_er_r               : std_logic;
    signal gmii_rxd_r                 : std_logic_vector(7 downto 0);

    -- 125MHz reference clock
    signal gtx_clk_ibufg_i            : std_logic;

    -- Speed output for physical interface clocking
    signal speed_vector_int           : std_logic;

    -- FCS block signals
    signal tx_stats_byte_valid_i      : std_logic;
    signal tx_collision_i             : std_logic;

-------------------------------------------------------------------------------
-- Attribute declarations
-------------------------------------------------------------------------------

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of tx_enable_pre_r : signal is "TRUE";
  attribute ASYNC_REG of rx_enable_pre_r : signal is "TRUE";

-------------------------------------------------------------------------------
-- Main body of code
-------------------------------------------------------------------------------

begin

    gnd_i <= '0';
    vcc_i <= '1';

    ---------------------------------------------------------------------------
    -- Main reset circuitry
    ---------------------------------------------------------------------------

    reset_ibuf_i <= RESET;
    reset_i <= reset_ibuf_i;

    ---------------------------------------------------------------------------
    -- GMII circuitry for the physical interface
    ---------------------------------------------------------------------------

    gmii : gmii_if port map (
        RESET          => reset_i,
        GMII_TXD       => GMII_TXD,
        GMII_TX_EN     => GMII_TX_EN,
        GMII_TX_ER     => GMII_TX_ER,
        GMII_TX_CLK    => GMII_TX_CLK,
        GMII_RXD       => GMII_RXD,
        GMII_RX_DV     => GMII_RX_DV,
        GMII_RX_ER     => GMII_RX_ER,
        TXD_FROM_MAC   => gmii_txd_i,
        TX_EN_FROM_MAC => gmii_tx_en_i,
        TX_ER_FROM_MAC => gmii_tx_er_i,
        TX_CLK         => tx_gmii_mii_clk_in_i,
        RXD_TO_MAC     => gmii_rxd_r,
        RX_DV_TO_MAC   => gmii_rx_dv_r,
        RX_ER_TO_MAC   => gmii_rx_er_r,
        RX_CLK         => GMII_RX_CLK
    );

    gmii_col_i <= GMII_COL AND gmii_tx_en_fa_i;

    -- Instantiate the FCS block to correct possible duplicate
    -- transmission of the final FCS byte
    fcs_blk_inst : fcs_blk_mii port map (
        reset               => reset_i,
        tx_phy_clk          => tx_gmii_mii_clk_in_i,
        txd_from_mac        => gmii_txd_fa_i,
        tx_en_from_mac      => gmii_tx_en_fa_i,
        tx_er_from_mac      => gmii_tx_er_fa_i,
        tx_client_clk       => tx_client_clk_in_i,
        tx_stats_byte_valid => tx_stats_byte_valid_i,
        tx_collision        => tx_collision_i,
        speed_is_10_100     => speed_vector_int,
        txd                 => gmii_txd_i,
        tx_en               => gmii_tx_en_i,
        tx_er               => gmii_tx_er_i
    );

    EMACCLIENTTXCOLLISION    <= tx_collision_i;
    EMACCLIENTTXSTATSBYTEVLD <= tx_stats_byte_valid_i;


    -- GTX reference clock
    gtx_clk_ibufg_i <= GTX_CLK;

    -- GMII PHY-side transmit clock
    tx_gmii_mii_clk_in_i <= TX_CLK;

    -- GMII PHY-side receive clock, regionally-buffered
    gmii_rx_clk_i <= PHY_RX_CLK;

    -- GMII client-side transmit clock
    tx_client_clk_in_i <= TX_CLK;

    -- GMII client-side receive clock
    rx_client_clk_in_i <= gmii_rx_clk_i;

    -- MII transmitter clock
    mii_tx_clk_i <= MII_TX_CLK;

    --------------------------------------------------------------------------
    -- Clock Enable management
    --------------------------------------------------------------------------

    -- Register the TX ACK signal on the MII TX clock
    tx_client_ack_pr : process(tx_gmii_mii_clk_in_i, reset_i)
    begin
        if reset_i = '1' then
            tx_client_ack_r <= '0';
        elsif tx_gmii_mii_clk_in_i'event and tx_gmii_mii_clk_in_i = '1' then
            tx_client_ack_r <= tx_client_ack_i;
        end if;
    end process tx_client_ack_pr;

    -- Multiplex ACK signal depending on speed
    tx_client_ack_sel_pr : process(tx_client_ack_r, tx_client_ack_i, speed_vector_int)
    begin
      if speed_vector_int = '1' then
        EMACCLIENTTXACK <= tx_client_ack_r;
      else
        EMACCLIENTTXACK <= tx_client_ack_i;
      end if;
    end process tx_client_ack_sel_pr;

    -- TX clock output
    TX_CLK_OUT <= tx_gmii_mii_clk_out_i;

    -- Clock enables
    TX_CLIENT_CLK_ENABLE <= tx_enable_r;
    RX_CLIENT_CLK_ENABLE <= rx_enable_r;

    -- Double register the enables to cope with any
    -- metastability during a speed change
    tx_en_pr : process(tx_gmii_mii_clk_in_i, reset_i)
    begin
        if reset_i = '1' then
            tx_enable_pre_r <= '0';
            tx_enable_r     <= '0';
        elsif tx_gmii_mii_clk_in_i'event and tx_gmii_mii_clk_in_i = '1' then
            tx_enable_pre_r <= tx_enable_i after 1 ps;
            tx_enable_r     <= tx_enable_pre_r after 1 ps;
        end if;
    end process tx_en_pr;

    rx_en_pr : process(gmii_rx_clk_i, reset_i)
    begin
        if reset_i = '1' then
            rx_enable_pre_r <= '0';
            rx_enable_r     <= '0';
        elsif gmii_rx_clk_i'event and gmii_rx_clk_i = '1' then
            rx_enable_pre_r <= rx_enable_i after 1 ps;
            rx_enable_r     <= rx_enable_pre_r after 1 ps;
        end if;
    end process rx_en_pr;

    -- Speed indicator
    EMACSPEEDIS10100 <= speed_vector_int;

    --------------------------------------------------------------------------
    -- Instantiate the primitive-level EMAC wrapper (temac_core.vhd)
    --------------------------------------------------------------------------

    temac_core_inst : temac_core
    port map (
        -- Client receiver interface
        EMACCLIENTRXCLIENTCLKOUT    => rx_enable_i,
        CLIENTEMACRXCLIENTCLKIN     => gnd_i,
        EMACCLIENTRXD               => EMACCLIENTRXD,
        EMACCLIENTRXDVLD            => EMACCLIENTRXDVLD,
        EMACCLIENTRXDVLDMSW         => open,
        EMACCLIENTRXGOODFRAME       => EMACCLIENTRXGOODFRAME,
        EMACCLIENTRXBADFRAME        => EMACCLIENTRXBADFRAME,
        EMACCLIENTRXFRAMEDROP       => EMACCLIENTRXFRAMEDROP,
        EMACCLIENTRXSTATS           => EMACCLIENTRXSTATS,
        EMACCLIENTRXSTATSVLD        => EMACCLIENTRXSTATSVLD,
        EMACCLIENTRXSTATSBYTEVLD    => EMACCLIENTRXSTATSBYTEVLD,

        -- Client transmitter interface
        EMACCLIENTTXCLIENTCLKOUT    => tx_enable_i,
        CLIENTEMACTXCLIENTCLKIN     => gnd_i,
        CLIENTEMACTXD               => CLIENTEMACTXD,
        CLIENTEMACTXDVLD            => CLIENTEMACTXDVLD,
        CLIENTEMACTXDVLDMSW         => gnd_i,
        EMACCLIENTTXACK             => tx_client_ack_i,
        CLIENTEMACTXFIRSTBYTE       => CLIENTEMACTXFIRSTBYTE,
        CLIENTEMACTXUNDERRUN        => CLIENTEMACTXUNDERRUN,
        EMACCLIENTTXCOLLISION       => tx_collision_i,
        EMACCLIENTTXRETRANSMIT      => EMACCLIENTTXRETRANSMIT,
        CLIENTEMACTXIFGDELAY        => CLIENTEMACTXIFGDELAY,
        EMACCLIENTTXSTATS           => EMACCLIENTTXSTATS,
        EMACCLIENTTXSTATSVLD        => EMACCLIENTTXSTATSVLD,
        EMACCLIENTTXSTATSBYTEVLD    => tx_stats_byte_valid_i,

        -- MAC control interface
        CLIENTEMACPAUSEREQ          => CLIENTEMACPAUSEREQ,
        CLIENTEMACPAUSEVAL          => CLIENTEMACPAUSEVAL,

        -- Clock signals
        GTX_CLK                     => gtx_clk_ibufg_i,
        EMACPHYTXGMIIMIICLKOUT      => tx_gmii_mii_clk_out_i,
        PHYEMACTXGMIIMIICLKIN       => tx_gmii_mii_clk_in_i,

        -- GMII interface
        GMII_TXD                    => gmii_txd_fa_i,
        GMII_TX_EN                  => gmii_tx_en_fa_i,
        GMII_TX_ER                  => gmii_tx_er_fa_i,
        GMII_RXD                    => gmii_rxd_r,
        GMII_RX_DV                  => gmii_rx_dv_r,
        GMII_RX_ER                  => gmii_rx_er_r,
        GMII_RX_CLK                 => gmii_rx_clk_i,
        MII_TX_CLK                  => mii_tx_clk_i,
        GMII_COL                    => gmii_col_i,
        GMII_CRS                    => GMII_CRS,

        -- Speed indicator
        EMACSPEEDIS10100            => speed_vector_int,

        -- MMCM lock indicator
        MMCM_LOCKED                 => vcc_i,

        -- Asynchronous reset
        RESET                       => reset_i
      );


end TOP_LEVEL;

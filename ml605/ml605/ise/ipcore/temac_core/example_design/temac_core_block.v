//-----------------------------------------------------------------------------
// Title      : Block-level Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
// Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : temac_core_block.v
// Version    : 1.4
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Description:  This is the block-level wrapper for the Virtex-6 Embedded
//               Tri-Mode Ethernet MAC. It is intended that this example design
//               can be quickly adapted and downloaded onto an FPGA to provide
//               a hardware test environment.
//
//               The block-level wrapper:
//
//               * instantiates appropriate PHY interface modules (GMII, MII,
//                 RGMII, SGMII or 1000BASE-X) as required per the user
//                 configuration;
//
//               * instantiates some clocking and reset resources to operate
//                 the EMAC and its example design.
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// Module declaration for the block-level wrapper
//-----------------------------------------------------------------------------

module temac_core_block
(

    // TX clock output
    TX_CLK_OUT,
    // TX clock input from BUFG
    TX_CLK,

    // Speed indicator
    EMACSPEEDIS10100,

    // Client receiver interface
    RX_CLIENT_CLK_ENABLE,
    EMACCLIENTRXD,
    EMACCLIENTRXDVLD,
    EMACCLIENTRXGOODFRAME,
    EMACCLIENTRXBADFRAME,
    EMACCLIENTRXFRAMEDROP,
    EMACCLIENTRXSTATS,
    EMACCLIENTRXSTATSVLD,
    EMACCLIENTRXSTATSBYTEVLD,

    // Client transmitter interface
    TX_CLIENT_CLK_ENABLE,
    CLIENTEMACTXD,
    CLIENTEMACTXDVLD,
    EMACCLIENTTXACK,
    CLIENTEMACTXFIRSTBYTE,
    CLIENTEMACTXUNDERRUN,
    EMACCLIENTTXCOLLISION,
    EMACCLIENTTXRETRANSMIT,
    CLIENTEMACTXIFGDELAY,
    EMACCLIENTTXSTATS,
    EMACCLIENTTXSTATSVLD,
    EMACCLIENTTXSTATSBYTEVLD,

    // MAC control interface
    CLIENTEMACPAUSEREQ,
    CLIENTEMACPAUSEVAL,

    // Receive-side PHY clock on regional buffer, to EMAC
    PHY_RX_CLK,

    // Clock signal
    GTX_CLK,

    // GMII interface
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_TX_CLK,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    MII_TX_CLK,
    GMII_COL,
    GMII_CRS,

    // Asynchronous reset
    RESET
);


//-----------------------------------------------------------------------------
// Port declarations
//-----------------------------------------------------------------------------

    // TX clock output
    output          TX_CLK_OUT;
    // TX clock input from BUFG
    input           TX_CLK;

    // Speed indicator
    output          EMACSPEEDIS10100;

    // Client receiver interface
    output          RX_CLIENT_CLK_ENABLE;
    output   [7:0]  EMACCLIENTRXD;
    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXGOODFRAME;
    output          EMACCLIENTRXBADFRAME;
    output          EMACCLIENTRXFRAMEDROP;
    output   [6:0]  EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;

    // Client transmitter interface
    output          TX_CLIENT_CLK_ENABLE;
    input    [7:0]  CLIENTEMACTXD;
    input           CLIENTEMACTXDVLD;
    output          EMACCLIENTTXACK;
    input           CLIENTEMACTXFIRSTBYTE;
    input           CLIENTEMACTXUNDERRUN;
    output          EMACCLIENTTXCOLLISION;
    output          EMACCLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;

    // MAC control interface
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;

    // Receive-side PHY clock on regional buffer, to EMAC
    input           PHY_RX_CLK;

    // Clock signal
    input           GTX_CLK;

    // GMII interface
    output   [7:0]  GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    output          GMII_TX_CLK;
    input    [7:0]  GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           MII_TX_CLK;
    input           GMII_COL;
    input           GMII_CRS;

    // Asynchronous reset
    input           RESET;


//-----------------------------------------------------------------------------
// Wire and register declarations
//-----------------------------------------------------------------------------

    // Asynchronous reset signals
    wire            reset_ibuf_i;
    wire            reset_i;

    // Client clocking signals
    wire            rx_client_clk_out_i;
    wire            rx_client_clk_in_i;
    wire            tx_client_clk_out_i;
    wire            tx_client_clk_in_i;
    wire            tx_enable_i;

    // ASYNC_REG attribute added to simulate actual behavior under
    // asynchronous operating conditions.
    (* ASYNC_REG = "TRUE" *)
    reg             tx_enable_pre_r;

    reg             tx_enable_r;
    wire            rx_enable_i;

    // ASYNC_REG attribute added to simulate actual behavior under
    // asynchronous operating conditions.
    (* ASYNC_REG = "TRUE" *)
    reg             rx_enable_pre_r;

    reg             rx_enable_r;
    wire            tx_gmii_mii_clk_out_i;
    wire            tx_gmii_mii_clk_in_i;

    // Client acknowledge signals
    reg             EMACCLIENTTXACK;
    reg             tx_client_ack_r;
    wire            tx_client_ack_i;

    // Physical interface signals
    wire            gmii_tx_en_i;
    wire            gmii_tx_er_i;
    wire     [7:0]  gmii_txd_i;
    wire            gmii_rx_dv_r;
    wire            gmii_rx_er_r;
    wire     [7:0]  gmii_rxd_r;
    wire            gmii_tx_en_fa_i;
    wire            gmii_tx_er_fa_i;
    wire     [7:0]  gmii_txd_fa_i;
    wire            mii_tx_clk_i;
    wire            gmii_col_i;
    wire            gmii_rx_clk_i;

    // 125MHz reference clock
    wire            gtx_clk_ibufg_i;

    // Speed output for physical interface clocking
    wire            speed_vector_int;

    // FCS block signals
    wire            tx_stats_byte_valid_i;
    wire            tx_collision_i;

//-----------------------------------------------------------------------------
// Main body of code
//-----------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    // Main reset circuitry
    //-------------------------------------------------------------------------

    assign reset_ibuf_i = RESET;
    assign reset_i = reset_ibuf_i;

    //-------------------------------------------------------------------------
    // GMII circuitry for the physical interface
    //-------------------------------------------------------------------------

    gmii_if gmii (
        .RESET          (reset_i),
        .GMII_TXD       (GMII_TXD),
        .GMII_TX_EN     (GMII_TX_EN),
        .GMII_TX_ER     (GMII_TX_ER),
        .GMII_TX_CLK    (GMII_TX_CLK),
        .GMII_RXD       (GMII_RXD),
        .GMII_RX_DV     (GMII_RX_DV),
        .GMII_RX_ER     (GMII_RX_ER),
        .TXD_FROM_MAC   (gmii_txd_i),
        .TX_EN_FROM_MAC (gmii_tx_en_i),
        .TX_ER_FROM_MAC (gmii_tx_er_i),
        .TX_CLK         (tx_gmii_mii_clk_in_i),
        .RXD_TO_MAC     (gmii_rxd_r),
        .RX_DV_TO_MAC   (gmii_rx_dv_r),
        .RX_ER_TO_MAC   (gmii_rx_er_r),
        .RX_CLK         (GMII_RX_CLK)
    );

    assign gmii_col_i = GMII_COL & gmii_tx_en_fa_i;

    // Instantiate the FCS block to correct possible duplicate
    // transmission of the final FCS byte
    fcs_blk_mii fcs_blk_inst (
        .reset               (reset_i),
        .tx_phy_clk          (tx_gmii_mii_clk_in_i),
        .txd_from_mac        (gmii_txd_fa_i),
        .tx_en_from_mac      (gmii_tx_en_fa_i),
        .tx_er_from_mac      (gmii_tx_er_fa_i),
        .tx_client_clk       (tx_client_clk_in_i),
        .tx_stats_byte_valid (tx_stats_byte_valid_i),
        .tx_collision        (tx_collision_i),
        .speed_is_10_100     (speed_vector_int),
        .txd                 (gmii_txd_i),
        .tx_en               (gmii_tx_en_i),
        .tx_er               (gmii_tx_er_i)
    );

    assign EMACCLIENTTXCOLLISION    = tx_collision_i;
    assign EMACCLIENTTXSTATSBYTEVLD = tx_stats_byte_valid_i;


    // GTX reference clock
    assign gtx_clk_ibufg_i = GTX_CLK;

    // GMII PHY-side transmit clock
    assign tx_gmii_mii_clk_in_i = TX_CLK;

    // GMII PHY-side receive clock, regionally-buffered
    assign gmii_rx_clk_i = PHY_RX_CLK;

    // GMII client-side transmit clock
    assign tx_client_clk_in_i = TX_CLK;

    // GMII client-side receive clock
    assign rx_client_clk_in_i = gmii_rx_clk_i;

    // MII Transmitter clock
    assign mii_tx_clk_i = MII_TX_CLK;

    //------------------------------------------------------------------------
    // Clock Enable management
    //------------------------------------------------------------------------

    // Register the TX ACK signal with the MII TX clock
    always @(posedge tx_gmii_mii_clk_in_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
            tx_client_ack_r <= 1'b0;
        else
            tx_client_ack_r <= tx_client_ack_i;
    end

    // Multiplex ACK signal depending on speed
    always @(tx_client_ack_r, tx_client_ack_i, speed_vector_int)
    begin
        if (speed_vector_int == 1'b1)
            EMACCLIENTTXACK = tx_client_ack_r;
        else
            EMACCLIENTTXACK = tx_client_ack_i;
    end

    // TX clock output
    assign TX_CLK_OUT = tx_gmii_mii_clk_out_i;

    // Clock enables
    assign TX_CLIENT_CLK_ENABLE = tx_enable_r;
    assign RX_CLIENT_CLK_ENABLE = rx_enable_r;

    // Double register the enables to cope with any
    // metastability during a speed change
    always @(posedge tx_gmii_mii_clk_in_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            tx_enable_pre_r <= 1'b0;
            tx_enable_r     <= 1'b0;
        end
        else
        begin
            tx_enable_pre_r <= tx_enable_i;
            tx_enable_r     <= tx_enable_pre_r;
        end
    end

    always @(posedge gmii_rx_clk_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            rx_enable_pre_r <= 1'b0;
            rx_enable_r     <= 1'b0;
        end
        else
        begin
            rx_enable_pre_r <= rx_enable_i;
            rx_enable_r     <= rx_enable_pre_r;
        end
    end

    // Speed indicator
    assign EMACSPEEDIS10100 = speed_vector_int;

    //------------------------------------------------------------------------
    // Instantiate the primitive-level EMAC wrapper (temac_core.v)
    //------------------------------------------------------------------------

    temac_core temac_core_inst
    (
        // Client receiver interface
        .EMACCLIENTRXCLIENTCLKOUT    (rx_enable_i),
        .CLIENTEMACRXCLIENTCLKIN     (1'b0),
        .EMACCLIENTRXD               (EMACCLIENTRXD),
        .EMACCLIENTRXDVLD            (EMACCLIENTRXDVLD),
        .EMACCLIENTRXDVLDMSW         (),
        .EMACCLIENTRXGOODFRAME       (EMACCLIENTRXGOODFRAME),
        .EMACCLIENTRXBADFRAME        (EMACCLIENTRXBADFRAME),
        .EMACCLIENTRXFRAMEDROP       (EMACCLIENTRXFRAMEDROP),
        .EMACCLIENTRXSTATS           (EMACCLIENTRXSTATS),
        .EMACCLIENTRXSTATSVLD        (EMACCLIENTRXSTATSVLD),
        .EMACCLIENTRXSTATSBYTEVLD    (EMACCLIENTRXSTATSBYTEVLD),

        // Client transmitter interface
        .EMACCLIENTTXCLIENTCLKOUT    (tx_enable_i),
        .CLIENTEMACTXCLIENTCLKIN     (1'b0),
        .CLIENTEMACTXD               (CLIENTEMACTXD),
        .CLIENTEMACTXDVLD            (CLIENTEMACTXDVLD),
        .CLIENTEMACTXDVLDMSW         (1'b0),
        .EMACCLIENTTXACK             (tx_client_ack_i),
        .CLIENTEMACTXFIRSTBYTE       (CLIENTEMACTXFIRSTBYTE),
        .CLIENTEMACTXUNDERRUN        (CLIENTEMACTXUNDERRUN),
        .EMACCLIENTTXCOLLISION       (tx_collision_i),
        .EMACCLIENTTXRETRANSMIT      (EMACCLIENTTXRETRANSMIT),
        .CLIENTEMACTXIFGDELAY        (CLIENTEMACTXIFGDELAY),
        .EMACCLIENTTXSTATS           (EMACCLIENTTXSTATS),
        .EMACCLIENTTXSTATSVLD        (EMACCLIENTTXSTATSVLD),
        .EMACCLIENTTXSTATSBYTEVLD    (tx_stats_byte_valid_i),

        // MAC control interface
        .CLIENTEMACPAUSEREQ          (CLIENTEMACPAUSEREQ),
        .CLIENTEMACPAUSEVAL          (CLIENTEMACPAUSEVAL),

        // Clock signals
        .GTX_CLK                     (gtx_clk_ibufg_i),
        .EMACPHYTXGMIIMIICLKOUT      (tx_gmii_mii_clk_out_i),
        .PHYEMACTXGMIIMIICLKIN       (tx_gmii_mii_clk_in_i),

        // GMII interface
        .GMII_TXD                    (gmii_txd_fa_i),
        .GMII_TX_EN                  (gmii_tx_en_fa_i),
        .GMII_TX_ER                  (gmii_tx_er_fa_i),
        .GMII_RXD                    (gmii_rxd_r),
        .GMII_RX_DV                  (gmii_rx_dv_r),
        .GMII_RX_ER                  (gmii_rx_er_r),
        .GMII_RX_CLK                 (gmii_rx_clk_i),
        .MII_TX_CLK                  (mii_tx_clk_i),
        .GMII_COL                    (gmii_col_i),
        .GMII_CRS                    (GMII_CRS),

        // Speed indicator
        .EMACSPEEDIS10100            (speed_vector_int),

         // MMCM lock indicator
        .MMCM_LOCKED                 (1'b1),

        // Asynchronous reset
        .RESET                       (reset_i)
    );


endmodule

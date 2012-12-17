
//
//-----------------------------------------------------------------------------
// Description:  This is the Example Design wrapper for the Virtex-6
//               Embedded Tri-Mode Ethernet MAC. It is intended that this
//               example design can be quickly adapted and downloaded onto an
//               FPGA to provide a hardware test environment.
//
//               The Example Design wrapper:
//
//               * instantiates the EMAC LocalLink-level wrapper (the EMAC
//                 block-level wrapper with the RX and TX FIFOs and a
//                 LocalLink interface);
//
//               * instantiates a simple example design which provides an
//                 address swap and loopback function at the user interface;
//
//               * instantiates the fundamental clocking resources required
//                 by the core;
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//
//    ---------------------------------------------------------------------
//    |EXAMPLE DESIGN WRAPPER                                             |
//    |           --------------------------------------------------------|
//    |           |LOCALLINK-LEVEL WRAPPER                                |
//    |           |              -----------------------------------------|
//    |           |              |BLOCK-LEVEL WRAPPER                     |
//    |           |              |    ---------------------               |
//    | --------  |  ----------  |    | INSTANCE-LEVEL    |               |
//    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
//    | |      |->|->|        |->|--->| Tx            Tx  |->|       |--->|
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | | ADDR |  |  | LOCAL- |  |    | I/F           I/F |  |       |    |
//    | | SWAP |  |  | LINK   |  |    |                   |  | PHY   |    |
//    | |      |  |  | FIFO   |  |    |                   |  | I/F   |    |
//    | |      |  |  |        |  |    |                   |  |       |    |
//    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
//    | |      |  |  |        |  |    | client        PHY |  |       |    |
//    | |      |<-|<-|        |<-|<---| I/F           I/F |<-|       |<---|
//    | |      |  |  |        |  |    |                   |  ---------    |
//    | --------  |  ----------  |    ---------------------               |
//    |           |              -----------------------------------------|
//    |           --------------------------------------------------------|
//    ---------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
//---------------------------------------------------------


module ethernet
(
    // Client receiver interface
    output EMACCLIENTRXDVLD,
    output EMACCLIENTRXFRAMEDROP,
    output [6:0] EMACCLIENTRXSTATS,
    output EMACCLIENTRXSTATSVLD,
    output EMACCLIENTRXSTATSBYTEVLD,

    // Client transmitter interface
    input [7:0] CLIENTEMACTXIFGDELAY,
    output EMACCLIENTTXSTATS,
    output EMACCLIENTTXSTATSVLD,
    output EMACCLIENTTXSTATSBYTEVLD,

    // MAC control interface
    input CLIENTEMACPAUSEREQ,
    input [15:0] CLIENTEMACPAUSEVAL,

    // Clock signal
    input GTX_CLK,

    // GMII interface
    output [7:0] GMII_TXD,
    output GMII_TX_EN,
    output GMII_TX_ER,
    output GMII_TX_CLK,
    input [7:0] GMII_RXD,
    input GMII_RX_DV,
    input GMII_RX_ER,
    input GMII_RX_CLK,
    input MII_TX_CLK,
    input GMII_COL,
    input GMII_CRS,

    // Reference clock for IODELAYs
    input REFCLK,

    // Asynchronous reset
    input RESET,
	 
	 //ethernet received signals
	  //general data
	 output [7:0]	gen_numChannels,
	 output  [7:0]	gen_spare0,
	 output  [7:0]	gen_spare1,
	 output  [7:0]	gen_spare2,
	 
	 //channel 0 data
	 output  [31:0] ch0_threshold,
	 output  [7:0]	ch0_mode,
	 output  [7:0]	ch0_fftSize,
	 output  [31:0]	ch0_frequency,
	 output  [7:0]	ch0_spare0,
	 output  [7:0]	ch0_spare1,
	  
	 //channel 1 data
	 output  [31:0] ch1_threshold,
	 output  [7:0]	ch1_mode,
	 output  [7:0]	ch1_fftSize,
	 output  [31:0]	ch1_frequency,
	 output  [7:0]	ch1_spare0,
	 output  [7:0]	ch1_spare1,
	 
	 //channel 2 data
	 output  [31:0] ch2_threshold,
	 output  [7:0]	ch2_mode,
	 output  [7:0]	ch2_fftSize,
	 output  [31:0]	ch2_frequency,
	 output  [7:0]	ch2_spare0,
	 output  [7:0]	ch2_spare1,
	 
	 //channel 3 data
	 output  [31:0] ch3_threshold,
	 output  [7:0]	ch3_mode,
	 output  [7:0]	ch3_fftSize,
	 output  [31:0]	ch3_frequency,
	 output  [7:0]	ch3_spare0,
	 output  [7:0]	ch3_spare1,
	 
	 //ethernet data / header signals
	 input					clk_ext,		
	 input		[31:0]	ethData,		//data to write out ethernet port
	 input					ethData_we, //enable line to check data into fifo
	 input		[10:0]	ethLength,	//amount of data, reported in words
	 input		[7:0]		ethHdrData,	//data for the header
	 input		[10:0]	ethHdrAddr, //address for the header
	 input					ethHdrWE,	//write enable for the ethernet header
	 input					rawPacketFlag,
	 input 		[7:0] 	fftSize,
	 output					packetBusy,	//1 when we are writing a packet, 0 when we are free
	 input					packetReady, //incoming signal that a packet is ready
	 output					packetValid
);
	 

//-----------------------------------------------------------------------------
// Wire and register declarations
//-----------------------------------------------------------------------------

    // Global asynchronous reset
    wire            reset_i;

    // LocalLink interface clocking signal
    wire            ll_clk_i;

    // Address swap transmitter connections
    wire      [7:0] tx_ll_data_i;
    wire            tx_ll_sof_n_i;
    wire            tx_ll_eof_n_i;
    wire            tx_ll_src_rdy_n_i;
    wire            tx_ll_dst_rdy_n_i;

    // Address swap receiver connections
    wire      [7:0] rx_ll_data_i;
    wire            rx_ll_sof_n_i;
    wire            rx_ll_eof_n_i;
    wire            rx_ll_src_rdy_n_i;
    wire            rx_ll_dst_rdy_n_i;

    // Synchronous reset registers in the LocalLink clock domain
    (* ASYNC_REG = "TRUE" *)
    reg       [5:0] ll_pre_reset_i;

    reg             ll_reset_i;

    // Reference clock for IODELAYs
    wire            refclk_ibufg_i;
    wire            refclk_bufg_i;

    // GMII input clocks to wrappers
    (* KEEP = "TRUE" *)
    wire            tx_clk;
    wire            rx_clk_i;
    wire            gmii_rx_clk_bufio;
    wire            gmii_rx_clk_delay;

    // IDELAY controller
    reg      [12:0] idelayctrl_reset_r;
    wire            idelayctrl_reset_i;

    // Speed indication from EMAC wrappers
    wire            speed_vector_i;
    // GTX reference clock
    wire            gtx_clk_i;
	 
	 //my wires
	 wire				  packetValid;
	 wire rawPacketFlag;
	 wire [7:0] fftSize;
	 
	  //general data
	 wire [7:0]	gen_numChannels;
	 wire [7:0]	gen_spare0;
	 wire [7:0]	gen_spare1;
	 wire [7:0]	gen_spare2;
	 
	 //channel 0 data
	 wire [31:0] ch0_threshold;
	 wire [7:0]	ch0_mode;
	 wire [7:0]	ch0_fftSize;
	 wire [31:0]	ch0_frequency;
	 wire [7:0]	ch0_spare0;
	 wire [7:0]	ch0_spare1;
	  
	 //channel 1 data
	 wire [31:0] ch1_threshold;
	 wire [7:0]	ch1_mode;
	 wire [7:0]	ch1_fftSize;
	 wire [31:0]	ch1_frequency;
	 wire [7:0]	ch1_spare0;
	 wire [7:0]	ch1_spare1;
	 
	 //channel 2 data
	 wire [31:0] ch2_threshold;
	 wire [7:0]	ch2_mode;
	 wire [7:0]	ch2_fftSize;
	 wire [31:0]	ch2_frequency;
	 wire [7:0]	ch2_spare0;
	 wire [7:0]	ch2_spare1;
	 
	 //channel 3 data
	 wire [31:0] ch3_threshold;
	 wire [7:0]	ch3_mode;
	 wire [7:0]	ch3_fftSize;
	 wire [31:0]	ch3_frequency;
	 wire [7:0]	ch3_spare0;
	 wire [7:0]	ch3_spare1;


//-----------------------------------------------------------------------------
// Main body of code
//-----------------------------------------------------------------------------

    // Reset input buffer
    BUF reset_ibuf (
       .I (RESET),
       .O (reset_i)
    );

    //------------------------------------------------------------------------
    // Clock skew management: use IDELAY on GMII_RX_CLK to move
    // the clock into proper alignment with the data
    //------------------------------------------------------------------------

    // Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode
    (* SYN_NOPRUNE = "TRUE" *)
    IDELAYCTRL dlyctrl (
       .RDY    (),
       .REFCLK (refclk_bufg_i),
       .RST    (idelayctrl_reset_i)
    );

    // Assert the proper reset pulse for the IDELAYCTRL
    always @(posedge refclk_bufg_i, posedge reset_i)
    begin
       if (reset_i == 1'b1)
       begin
          idelayctrl_reset_r[0]    <= 1'b0;
          idelayctrl_reset_r[12:1] <= 12'b111111111111;
       end
       else
       begin
          idelayctrl_reset_r[0]    <= 1'b0;
          idelayctrl_reset_r[12:1] <= idelayctrl_reset_r[11:0];
       end
    end
    assign idelayctrl_reset_i = idelayctrl_reset_r[12];

    // Please modify the IDELAY_VALUE to suit your design.
    // The IDELAY_VALUE set here is tuned to this example design.
    // For more information on IDELAYCTRL and IODELAY, please
    // refer to the Virtex-6 User Guide.
    IODELAY #(
       .IDELAY_TYPE           ("FIXED"),
       .IDELAY_VALUE          (0),
       .DELAY_SRC             ("I"),
       .SIGNAL_PATTERN        ("CLOCK"),
       .HIGH_PERFORMANCE_MODE ("TRUE")
    )
    gmii_rxc_delay (
       .IDATAIN (GMII_RX_CLK),
       .ODATAIN (1'b0),
       .DATAOUT (gmii_rx_clk_delay),
       .DATAIN  (1'b0),
       .C       (1'b0),
       .T       (1'b0),
       .CE      (1'b0),
       .INC     (1'b0),
       .RST     (1'b0)
    );


    // Clock the transmit-side function of the EMAC wrappers:
    // Use the 125MHz reference clock when running at 1000Mb/s and
    // the 2.5/25MHz transmit-side PHY clock when running at 100 or 10Mb/s.
    // This selection is handled by the EMAC automatically.
    BUFGMUX bufg_tx (
       .I0 (gtx_clk_i),
       .I1 (MII_TX_CLK),
       .S  (speed_vector_i),
       .O  (tx_clk)
    );

    // Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    // GMII phyical interface block to capture incoming data and control.
    BUFIO bufio_rx (
       .I (gmii_rx_clk_delay),
       .O (gmii_rx_clk_bufio)
    );

    // Regionally-buffer the receive-side GMII physical interface clock
    // for use with receive-side functions of the EMAC
    BUFR bufr_rx (
       .I   (gmii_rx_clk_delay),
       .O   (rx_clk_i),
       .CE  (1'b1),
       .CLR (1'b0)
    );

    // Clock the LocalLink interface with the globally-buffered tx_clk
    assign ll_clk_i = tx_clk;

    //------------------------------------------------------------------------
    // Instantiate the LocalLink-level EMAC wrapper (temac_locallink.v)
    //------------------------------------------------------------------------
    temac_core_locallink temac_core_locallink_inst
    (
    // TX clock output
    .TX_CLK_OUT               (),
    // TX Clock input from BUFG
    .TX_CLK                   (tx_clk),

    // Speed indicator
    .EMACSPEEDIS10100         (speed_vector_i),

    // LocalLink receiver interface
    .RX_LL_CLOCK              (ll_clk_i),
    .RX_LL_RESET              (ll_reset_i),
    .RX_LL_DATA               (rx_ll_data_i),
    .RX_LL_SOF_N              (rx_ll_sof_n_i),
    .RX_LL_EOF_N              (rx_ll_eof_n_i),
    .RX_LL_SRC_RDY_N          (rx_ll_src_rdy_n_i),
    .RX_LL_DST_RDY_N          (rx_ll_dst_rdy_n_i),
    .RX_LL_FIFO_STATUS        (),

    // Client receiver signals
    .EMACCLIENTRXDVLD         (EMACCLIENTRXDVLD),
    .EMACCLIENTRXFRAMEDROP    (EMACCLIENTRXFRAMEDROP),
    .EMACCLIENTRXSTATS        (EMACCLIENTRXSTATS),
    .EMACCLIENTRXSTATSVLD     (EMACCLIENTRXSTATSVLD),
    .EMACCLIENTRXSTATSBYTEVLD (EMACCLIENTRXSTATSBYTEVLD),

    // LocalLink transmitter interface
    .TX_LL_CLOCK              (ll_clk_i),
    .TX_LL_RESET              (ll_reset_i),
    .TX_LL_DATA               (tx_ll_data_i),
    .TX_LL_SOF_N              (tx_ll_sof_n_i),
    .TX_LL_EOF_N              (tx_ll_eof_n_i),
    .TX_LL_SRC_RDY_N          (tx_ll_src_rdy_n_i),
    .TX_LL_DST_RDY_N          (tx_ll_dst_rdy_n_i),

    // Client transmitter signals
    .CLIENTEMACTXIFGDELAY     (CLIENTEMACTXIFGDELAY),
    .EMACCLIENTTXSTATS        (EMACCLIENTTXSTATS),
    .EMACCLIENTTXSTATSVLD     (EMACCLIENTTXSTATSVLD),
    .EMACCLIENTTXSTATSBYTEVLD (EMACCLIENTTXSTATSBYTEVLD),

    // MAC control interface
    .CLIENTEMACPAUSEREQ       (CLIENTEMACPAUSEREQ),
    .CLIENTEMACPAUSEVAL       (CLIENTEMACPAUSEVAL),

    // Receive-side PHY clock on regional buffer, to EMAC
    .PHY_RX_CLK               (rx_clk_i),

    // Reference clock (unused)
    .GTX_CLK                  (1'b0),

    // GMII interface
    .GMII_TXD                 (GMII_TXD),
    .GMII_TX_EN               (GMII_TX_EN),
    .GMII_TX_ER               (GMII_TX_ER),
    .GMII_TX_CLK              (GMII_TX_CLK),
    .GMII_RXD                 (GMII_RXD),
    .GMII_RX_DV               (GMII_RX_DV),
    .GMII_RX_ER               (GMII_RX_ER),
    .GMII_RX_CLK              (gmii_rx_clk_bufio),
    .MII_TX_CLK               (tx_clk),
    .GMII_COL                 (GMII_COL),
    .GMII_CRS                 (GMII_CRS),

    // Asynchronous reset
    .RESET                    (reset_i)
    );

    //-------------------------------------------------------------------
    //  Instatiate the address swapping module
    //-------------------------------------------------------------------
    /*
	 address_swap_module_8 client_side_asm (
       .rx_ll_clock         (ll_clk_i),
       .rx_ll_reset         (ll_reset_i),
       .rx_ll_data_in       (rx_ll_data_i),
       .rx_ll_sof_in_n      (rx_ll_sof_n_i),
       .rx_ll_eof_in_n      (rx_ll_eof_n_i),
       .rx_ll_src_rdy_in_n  (rx_ll_src_rdy_n_i),
       .rx_ll_data_out      (tx_ll_data_i),
       .rx_ll_sof_out_n     (tx_ll_sof_n_i),
       .rx_ll_eof_out_n     (tx_ll_eof_n_i),
       .rx_ll_src_rdy_out_n (tx_ll_src_rdy_n_i),
       .rx_ll_dst_rdy_in_n  (tx_ll_dst_rdy_n_i)
    );

    assign rx_ll_dst_rdy_n_i = tx_ll_dst_rdy_n_i;
	 */
	 
	 ethReader ethReader_inst (
    .clk(ll_clk_i), 
    .rst(ll_reset_i), 
    .dataIn(rx_ll_data_i), 
    .sof_n(rx_ll_sof_n_i), 
    .eof_n(rx_ll_eof_n_i), 
    .src_rdy_n(rx_ll_src_rdy_n_i), 
    .dst_rdy_n(rx_ll_dst_rdy_n_i),
	 .gen_numChannels(gen_numChannels), 
    .gen_spare0(gen_spare0), 
    .gen_spare1(gen_spare1), 
    .gen_spare2(gen_spare2), 
    .ch0_threshold(ch0_threshold), 
    .ch0_mode(ch0_mode), 
    .ch0_fftSize(ch0_fftSize), 
    .ch0_frequency(ch0_frequency), 
    .ch0_spare0(ch0_spare0), 
    .ch0_spare1(ch0_spare1), 
    .ch1_threshold(ch1_threshold), 
    .ch1_mode(ch1_mode), 
    .ch1_fftSize(ch1_fftSize), 
    .ch1_frequency(ch1_frequency), 
    .ch1_spare0(ch1_spare0), 
    .ch1_spare1(ch1_spare1), 
    .ch2_threshold(ch2_threshold), 
    .ch2_mode(ch2_mode), 
    .ch2_fftSize(ch2_fftSize), 
    .ch2_frequency(ch2_frequency), 
    .ch2_spare0(ch2_spare0), 
    .ch2_spare1(ch2_spare1), 
    .ch3_threshold(ch3_threshold), 
    .ch3_mode(ch3_mode), 
    .ch3_fftSize(ch3_fftSize), 
    .ch3_frequency(ch3_frequency), 
    .ch3_spare0(ch3_spare0), 
    .ch3_spare1(ch3_spare1),
    .packetValid(packetValid)
    );
	 
	 //write into the transmitter
	 ethWriter ethWriter_inst (
    .clk(ll_clk_i), 
    .rst(ll_reset_i), 
	 .clk_ext(clk_ext), 
    .ethData(ethData), 
    .ethData_we(ethData_we), 
    .ethLength(ethLength), 
    .ethHdrData_e(ethHdrData), 
    .ethHdrAddr_e(ethHdrAddr), 
    .ethHdrWE_e(ethHdrWE),
	 .fftSize(fftSize),
	 .rawPacket(rawPacketFlag),
    .data_out(tx_ll_data_i), 
    .sof_n(tx_ll_sof_n_i), 
    .eof_n(tx_ll_eof_n_i), 
    .src_rdy_n(tx_ll_src_rdy_n_i), 
    .dst_rdy_n(tx_ll_dst_rdy_n_i),
	 .packetBusy(packetBusy), 
    .packetReady(packetReady)
    );
	 



    // Create synchronous reset in the transmitter clock domain
    always @(posedge ll_clk_i, posedge reset_i)
    begin
      if (reset_i === 1'b1)
      begin
        ll_pre_reset_i <= 6'h3F;
        ll_reset_i     <= 1'b1;
      end
      else
      begin
        ll_pre_reset_i[0]   <= 1'b0;
        ll_pre_reset_i[5:1] <= ll_pre_reset_i[4:0];
        ll_reset_i          <= ll_pre_reset_i[5];
      end
    end

    // Globally-buffer the reference clock used for
    // the IODELAYCTRL primitive
    BUFG refclk_ibufg (
       .I (REFCLK),
       .O (refclk_ibufg_i)
    );
    BUFG refclk_bufg (
       .I (refclk_ibufg_i),
       .O (refclk_bufg_i)
    );
	 /*
    // Prepare the GTX_CLK for a BUFG
    BUFG gtx_clk_ibufg (
       .I (GTX_CLK),
       .O (gtx_clk_i)
    );*/
	 assign gtx_clk_i=GTX_CLK;


endmodule

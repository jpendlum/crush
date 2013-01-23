`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    12:46:06 02/12/2011
// Design Name:
// Module Name:    simplemicro
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module top(
  input clk_200_n,
  input clk_200_p,
  input clk_66,
  input Button_CPU_RESET,
  input USB_RX,
  output USB_TX,
  input [14:0] debug_in,
  input debug_clk_in,
  output debug_clk_out,
  input debug_ack,
  output debug_req,
  output [13:0] debug_bus,
  /*
  inout [15:0] Mic1DE,	//Mictor 1, Data Even
  inout [15:0] Mic1DO,	//Mictor 1, Data Odd
  inout [1:0]  Mic1Clk,	//Mictor 1, Clocks
  inout [15:0] Mic2DE,	//Mictor 2, Data Even
  inout [15:0] Mic2DO,	//Mictor 2, Data Odd
  inout [1:0]  Mic2Clk,	//Mictor 2, Clocks
  inout [15:0] Mic3DE,	//Mictor 3, Data Even
  inout [15:0] Mic3DO,	//Mictor 3, Data Odd
  inout [1:0]  Mic3Clk,	//Mictor 3, Clocks
  inout [15:0] Mic4DE,	//Mictor 4, Data Even
  inout [15:0] Mic4DO,	//Mictor 4, Data Odd
  inout [1:0]  Mic4Clk,	//Mictor 4, Clocks
  */
  //ethernet
  //RX
  output [7:0] GMII_TXD,
  output GMII_TX_EN,
  output GMII_TX_ER,
  output GMII_TX_CLK,

  //TX
  input [7:0] GMII_RXD,
  input GMII_RX_DV,
  input GMII_RX_ER,
  input GMII_RX_CLK,
  //Other
  input MII_TX_CLK,
  input GMII_COL,
  input GMII_CRS,
  input PHY_MDIO, //what does this do?
  input PHY_MDC, //what does this do?
  input PHY_RESET_n, //what does this do?
  input PHY_INT, //what does this do?
  input GTX_CLK_P,
  input GTX_CLK_N,

  input Button_N,
  input Button_S,
  input Button_E,
  input Button_W,
  input Button_C,
  input [7:0] DIP,
  output reg LED_test,
  output [3:0] LEDs,
  output [7:0] LED2);

parameter FIRMWARE_ID  	 = 32'h55535250;  // USRP in ASCII.
parameter FIRMWARE_MAJOR = 16'h000A;  		// Firmware major version
parameter FIRMWARE_MINOR = 16'h0001;  		// Firmware minor version (major.minor)

//================================================================================
// Microblaze IO
//================================================================================
wire 					ublaze_rnw;
wire    [15:0] 	ublaze_addr_rev;
reg     [15:0] 	ublaze_addr;
reg     [31:0] 	ublaze_din_rev;	// Native format - big endian, bit reversed
wire    [31:0] 	ublaze_dout_rev;
reg     [31:0] 	ublaze_din;
reg     [31:0] 	ublaze_dout;
wire           	ublaze_cs;
reg		[3:0]		leds_int;
reg		[3:0]		state;
reg		[3:0]		block;
reg 		[3:0]		counter;
wire 					startFlag;
reg					bus_startFlag;
reg 		[15:0]	errors;
reg					doneFlag;
reg					testState;
//reg		[15:0]	Mic1DE_l;
//reg		[15:0]	Mic1DO_l;
reg 		[15:0]	ADC_I;
reg 		[15:0]	ADC_Q;
reg					testFlag;
reg 		[16:0]	usrp_data;
wire 		[13:0]	 adc_dataI2,adc_dataQ2;
wire		[15:0] adc_dataI3,adc_dataQ3;
wire 		[1023:0] vector_out;
reg					readFlag;

wire 		[15:0]	freqAddr;
reg 		[15:0]	bus_freqAddr;
wire 		[31:0]	freqData;
wire 		[31:0]	threshold;
reg 		[31:0]	ublaze_threshold;
reg 		[15:0]	ublaze_threshAddr;
reg 		[31:0] threshold_scale;
wire 		[4:0]		transformWidth;
reg 		[4:0]		bus_transformWidth;
wire					clk, clk_ext;
wire					debug_clk_in_buf;
wire		[31:0]	timer[0:7];
reg					timer6Flag_reg,timer7Flag_reg,timer7Start_reg;
reg [15:0] fftScale;

//ethernet signals
wire  [31:0] 	ethData;
wire 		 		ethData_we;
wire	[10:0]	ethLength;
reg	[7:0]		ethHdrData;
reg   [10:0]	ethHdrAddr;
reg 				ethHdrWE;
wire 				packetBusy;
wire 				packetReady;
reg				packetFlag;
reg	[31:0]	unused;
wire [31:0] threshData;

//ethernet
wire GTX_CLK;
wire REFCLK;
reg RESET_eth;
wire packetValid;
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

	 wire fftInProgress,fftMemFull;
	 reg ethCtrl;
	 wire [31:0] theshData;
	wire thresholdingDone;
	wire [8:0] threshAddr;

(* KEEP = "TRUE" *)wire [15:0] adc_i_test;
(* KEEP = "TRUE" *)wire [15:0] adc_q_test;

  wire rst_100MHz;
  wire rst_100MHz_n;
  wire rst_ext;
  wire rst_ext_n;

localparam 	init			=	4'd0,
				start			=	4'd1,
				check			=	4'd2,
				increment	=	4'd3,
				report		=	4'd4,
				waitState	=	4'd5,
				waitState2	=	4'd6;

  reg reset_meta1;
  reg reset_meta2;
  reg reset_debounce1;
  reg reset_debounce2;
  reg reset;
  reg [31:0] reset_debounce_cnt;
  reg button_n_meta1;
  reg button_n_meta2;
  reg button_n_debounce1;
  reg button_n_debounce2;
  reg button_s_meta1;
  reg button_s_meta2;
  reg button_s_debounce1;
  reg button_s_debounce2;
  reg phase_inc;
  reg phase_inc_dly1;
  reg phase_inc_stb;
  reg phase_dec;
  reg phase_dec_dly1;
  reg phase_dec_stb;

  // Debouncing
  always@(posedge clk)
  begin
    reset_meta1           <= Button_CPU_RESET;
    reset_meta2           <= reset_meta1;
    button_n_meta1        <= Button_N;
    button_n_meta2        <= button_n_meta1;
    button_s_meta1        <= Button_S;
    button_s_meta2        <= button_s_meta1;
    if (reset_debounce_cnt == 32'd1000000) begin
      reset_debounce1     <= reset_meta2;
      reset_debounce2     <= reset_debounce1;
      button_n_debounce1  <= button_n_meta2;
      button_n_debounce2  <= button_n_debounce1;
      button_s_debounce1  <= button_s_meta2;
      button_s_debounce2  <= button_s_debounce1;
    end
    if (reset_debounce2 == 1'b1 && reset_debounce1 == 1'b1) begin
      reset               <= 1'b1;
    end else if (reset_debounce2 == 1'b0 && reset_debounce1 == 1'b0) begin
      reset               <= 1'b0;
    end
    if (button_n_debounce2 == 1'b1 && button_n_debounce1 == 1'b1) begin
      phase_inc           <= 1'b1;
    end else if (button_n_debounce2 == 1'b0 && button_n_debounce1 == 1'b0) begin
      phase_inc           <= 1'b0;
    end
    phase_inc_dly1        <= phase_inc;
    if (phase_inc_dly1 == 1'b0 && phase_inc == 1'b1) begin
      phase_inc_stb       <= 1'b1;
    end else begin
      phase_inc_stb       <= 1'b0;
    end
    if (button_s_debounce2 == 1'b1 && button_s_debounce1 == 1'b1) begin
      phase_dec           <= 1'b1;
    end else if (button_s_debounce2 == 1'b0 && button_s_debounce1 == 1'b0) begin
      phase_dec           <= 1'b0;
    end
    phase_dec_dly1        <= phase_dec;
    if (phase_dec_dly1 == 1'b0 && phase_dec == 1'b1) begin
      phase_dec_stb       <= 1'b1;
    end else begin
      phase_dec_stb       <= 1'b0;
    end
    // Debounce counter. Resets approx. every 1 ms.
    if (reset_debounce_cnt > 32'd10000000) begin
      reset_debounce_cnt  <= 32'd0;
    end else begin
      reset_debounce_cnt  <= reset_debounce_cnt + 1;
    end
  end

dcm_200 dcm1
   (// Clock in ports
    .CLK_IN1_P          (clk_200_p),    // IN
    .CLK_IN1_N          (clk_200_n),    // IN
    // Clock out ports
    .CLK_OUT1           (clk),     // OUT //100M
	 .CLK_OUT2            (REFCLK),     // OUT //200M
	 .CLK_OUT3            (GTX_CLK),
    // Status and control signals
    .RESET              (rst),        // IN
    .LOCKED             (rst_100MHz_n));      // OUT

  assign rst_100MHz     = ~rst_100MHz_n;

  wire [27:0] adc_data;
  wire [14:0] adc_dataI;
  wire [14:0] adc_dataQ;
  wire        adc_data_vld;

  ddr_to_sdr #(
    .BIT_WIDTH(14),
    .USE_PHASE_SHIFT("TRUE"),
    .PHASE_SHIFT(14))
  ddr_to_sdr_int (
    .reset(rst_100MHz),
    .clk_mmcm_ps(clk),
    .phase_inc_stb(phase_inc_stb),
    .phase_dec_stb(phase_dec_stb),
    .phase_cnt(),
    .ddr_data_clk(debug_clk_in),
    .ddr_data(debug_in[13:0]),
    .clk_ddr(clk_ext),
    .clk_ddr_locked(rst_ext_n),
    .clk_sdr(clk_ext),
    .sdr_data_vld(adc_data_vld),
    .sdr_data(adc_data));

  assign rst_ext = ~rst_ext_n;
  // Sign extend to correct length
  assign adc_dataI = {adc_data[27],adc_data[27:14]};
  assign adc_dataQ = {adc_data[13],adc_data[13:0]};

	 reg [7:0] bus_mode;
	 reg [31:0] bus_echo;
	 reg [15:0] bus_freq;
	 reg [7:0] bus_testLengthLog;

	 /*
	 always@(posedge clk) begin
		if(rst == 1'b1)  begin
			bus_mode <= 8'd0;
			bus_echo <= 32'h0;
			bus_freq <= 16'd0;
			bus_testLengthLog <= 8'd0; //256;
		end
		else begin
			bus_mode <= 8'd0;
			bus_echo <= 32'hDEADBEEF;
			bus_freq <= 16'd1000;
			bus_testLengthLog <= 8'd8; //256;
		end
	 end
	 */
	 wire [31:0] bus_threshold;
	 wire bus_threshold_stb;
	 wire [7:0] bus_fftLengthLog;
	 wire bus_fftLengthLog_stb;
	 wire [7:0] bus_fftAvg;
	 wire bus_fftAvg_stb;
	 reg [8:0] bus_threshAddr;

master_data_bus_WO masterBus (
    //clock signals
	 .clk(clk_ext),
    .rst(rst_ext),
	 //bus signals
	 .REQ(debug_req),
	 .ACK(debug_ack),
    .bus(debug_bus),
    .clk_out(debug_clk_out),
	 //input data
    .mode(bus_mode),
    .echo(bus_echo),
    .freq(bus_freq),
    .testLengthLog(bus_testLengthLog)
    );




	 always@(posedge clk_ext) begin
		RESET_eth <= 1'b0;
		if(rst_ext == 1'b1) begin
			RESET_eth <= 1'b1;
		end
	 end

	 reg packetRequested;

	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			packetRequested <= 1'b0;
		end
		else begin
			if(packetFlag == 1'b1) begin
				packetRequested <= 1'b1;
			end
			if(packetBusy == 1'b1) begin
				packetRequested <= 1'b0;
			end
		end
	 end

	 (* KEEP = "TRUE" *)reg [9:0] ethState;
	 reg [31:0] ethData_l;
	 reg			ethData_we_l;
	 reg [10:0] ethLength_l;
	 reg			packetReady_l;
	 reg			ch0_startFlag;
	 reg [15:0] ch0_freqAddr;
	 reg [8:0] ch0_threshAddr;
	 reg			rawPacketFlag;
	 reg [7:0]	fftSize;
	 reg [7:0]	packetCounter;
	 reg [7:0]	totalPackets;
	 reg [15:0] localCounter;
	 reg [7:0] fakeCounter;
	 localparam	ethStart			=	10'd0,
					ethRawStart		=	10'd1,
					ethRawWait		=	10'd25,
					ethRawHeader	=	10'd3,
					ethRawCheck		=	10'd4,
					ethRawSetup		=	10'd5,
					ethRawWrite		=	10'd6,
					ethRawFinish	=	10'd7,
					ethRawVerify	=	10'd8,
					ethRawZeros		=	10'd9,
					ethManStart		=	10'd10,
					ethManWait		=	10'd11,
					ethManHeader	=	10'd12,
					ethManCheck		=	10'd13,
					ethManSetup		=	10'd14,
					ethManWrite		=	10'd15,
					ethManFinish	=	10'd16,
					ethRawStall		=	10'd17,
					ethManRawStart		=	10'd18,
					ethManRawWait		=	10'd19,
					ethManRawHeader	=	10'd20,
					ethManRawCheck		=	10'd21,
					ethManRawSetup		=	10'd22,
					ethManRawWrite		=	10'd23,
					ethManRawFinish	=	10'd24;


	reg [31:0] watchEthCounter;
	reg watchEthFlag;
	(* KEEP = "TRUE" *)reg watchEthTrigger;

	always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			watchEthCounter <= 32'd10000000; //0.1 seconds?
		end
		else begin
			if(watchEthCounter > 32'd0) watchEthCounter <= watchEthCounter-1;
			if(watchEthFlag == 1'b1) watchEthCounter <= 32'd50000000;;
		end
	end

	 //state machine to fill data for ethernet
	 //TODO: add a watchdog timer to make sure it doesn't get stuck
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			ethState <= ethStart;
			ethData_l <= 32'd0;
			ethData_we_l <= 1'd0;
			ethLength_l <= 11'd0;
			packetReady_l <= 1'd0;
			ethCtrl <= 1'b0;
			ch0_startFlag <= 1'b0;
			fftSize <= 8'd0;
			rawPacketFlag <= 1'b0;
			packetCounter <= 8'd0;
			totalPackets <= 8'd0;
			fakeCounter <= 0;
			ch0_threshAddr <= 0;
			ch0_freqAddr <= 0;
			watchEthFlag <= 1'b0;
			watchEthTrigger <= 1'b0;
		end
		else begin
			packetReady_l <= 1'd0;
			case (ethState)
				ethStart: begin
					watchEthFlag <= 1'b1;
					fftSize <= 8'd0;
					rawPacketFlag <= 1'b0;
					ethData_l <= 32'd0;
					ethData_we_l <= 1'd0;
					ethLength_l <= 11'd14;
					packetReady_l <= 1'd0;
					ethCtrl <= 1'b0;
					packetCounter <= 8'd0;
					if(packetValid == 1'b1) begin
						case(ch0_mode)
							8'd2: begin
								ethCtrl <= 1'b1;
								fftSize <= ch0_fftSize;
								if(ch0_fftSize <=5) fftSize <= 8'd5; //smallest packet is a 32 bit word
								totalPackets <= 1;
								packetCounter <= 8'd1;
								rawPacketFlag <= 1'b0;
								ethState <= ethManStart;
								watchEthFlag <= 1'b0;
							end
							8'd4: begin
								ethCtrl <= 1'b1;
								ethState <= ethRawStart;
								rawPacketFlag <= 1'b1;
								fftSize <= 8'd0;
								packetCounter <= 8'd1;
								if(ch0_fftSize <=8) totalPackets <= 1;
								if(ch0_fftSize > 8) totalPackets <= (((1<<ch0_fftSize)<<2)>>10); //(2^fftsize*4 = number of bytes)/1024
								watchEthFlag <= 1'b0;
							end
							8'd5: begin
								ethCtrl <= 1'b1;
								fftSize <= ch0_fftSize;
								if(ch0_fftSize <=5) fftSize <= 8'd5; //smallest packet is a 32 bit word
								totalPackets <= 1;
								packetCounter <= 8'd1;
								rawPacketFlag <= 1'b0;
								ethState <=ethManRawStart;
								watchEthFlag <= 1'b0;
							end
							//8'd3: begin
							//	ethState <= ethAutoStart;
							//end
							default: begin
								watchEthFlag <= 1'b0;
							end
						endcase
					end
				end

				ethManRawStart: begin //start the test
					ch0_startFlag <= 1'b1; //start the FFT
					ethState <= ethManRawWait;
				end
				ethManRawWait: begin //wait for the test to complete
					ch0_startFlag <= 1'b0;
					ethData_we_l <= 1'd0;
					if(thesholdingDone == 1'b1) begin
						ethState <= ethManRawHeader;
					end
				end
				ethManRawHeader: begin
					ch0_startFlag <= 1'b0;
					ethData_l<={packetCounter,totalPackets,8'd0,ch0_mode};
					ethLength_l <= (1<<(fftSize-5))+1; //(2^fftsize)/8 + 1
					ethData_we_l <= 1'd1;
					ethState <= ethManRawCheck;
				end
				ethManRawCheck: begin
					ethData_we_l <= 1'd0;
					if(packetBusy == 1'b0) begin //make sure the ethernet controller is free
						ethState <= ethManRawSetup;
						ch0_threshAddr <= 0;
					end
				end
				ethManRawSetup: begin
					ethData_we_l <= 1'd0;
					ethState <= ethManRawWrite;
					ch0_threshAddr <=ch0_threshAddr+1;
					packetReady_l <= 1'd1;
				end
				ethManRawWrite: begin
					ch0_threshAddr <=ch0_threshAddr+1;
					ethData_l<=threshData;
					ethData_we_l <= 1'd1;
					packetReady_l <= 1'd0;
					if(ch0_threshAddr == (1<<(fftSize-5))) begin //if we've read out all of the FFT values
						ethState <= ethManRawFinish;
						ethData_we_l <= 1'd1;
					end
				end
				ethManRawFinish: begin
					fftSize <= 8'd0;
					ethData_l<=threshData;
					ethData_we_l <= 1'd0;
					ch0_startFlag <= 1'b0;
					ethState <= ethRawHeader;
					packetCounter <= 8'd1;
					if(ch0_fftSize <=8) totalPackets <= 1;
					if(ch0_fftSize > 8) totalPackets <= (((1<<ch0_fftSize)<<2)>>10); //(2^fftsize*4 = number of bytes)/1024
				end


				ethManStart: begin //start the test
					ch0_startFlag <= 1'b1; //start the FFT
					ethState <= ethManWait;
				end
				ethManWait: begin //wait for the test to complete
					ch0_startFlag <= 1'b0;
					ethData_we_l <= 1'd0;
					if(thesholdingDone == 1'b1) begin
						ethState <= ethManHeader;
					end
				end
				ethManHeader: begin
					ch0_startFlag <= 1'b0;
					ethData_l<={packetCounter,totalPackets,8'd0,ch0_mode};
					ethLength_l <= (1<<(fftSize-5))+1; //(2^fftsize)/8 + 1
					ethData_we_l <= 1'd1;
					ethState <= ethManCheck;
				end
				ethManCheck: begin
					ethData_we_l <= 1'd0;
					if(packetBusy == 1'b0) begin //make sure the ethernet controller is free
						ethState <= ethManSetup;
						ch0_threshAddr <= 0;
					end
				end
				ethManSetup: begin
					ethData_we_l <= 1'd0;
					ethState <= ethManWrite;
					ch0_threshAddr <=ch0_threshAddr+1;
					packetReady_l <= 1'd1;
				end
				ethManWrite: begin
					ch0_threshAddr <=ch0_threshAddr+1;
					ethData_l<=threshData;
					ethData_we_l <= 1'd1;
					packetReady_l <= 1'd0;
					if(ch0_threshAddr == (1<<(fftSize-5))) begin //if we've read out all of the FFT values
						ethState <= ethManFinish;
						ethData_we_l <= 1'd1;
					end
				end
				ethManFinish: begin
					ethData_l<=threshData;
					ethData_we_l <= 1'd0;
					ethState <= ethStart;
				end

				ethRawStart: begin
					ch0_startFlag <= 1'b1; //start the FFT
					ethState <= ethRawWait;
				end
				ethRawWait: begin //wait for the FFT to complete
					ch0_startFlag <= 1'b0;
					ethData_we_l <= 1'd0;
					if(fftMemFull == 1'b1) begin
						ethState <= ethRawHeader;
					end
				end
				ethRawHeader: begin //checking the header for the packet
					ethData_we_l <= 1'd0;
					if(packetBusy == 1'b0) begin //just added this, I think we're checking the beginning of the packet in too early and its wrapping.
						if(packetCounter <= totalPackets) begin
							ch0_startFlag <= 1'b0;
							ethData_l<={packetCounter,totalPackets,8'd0,ch0_mode};
							ethLength_l <= 257;
							ethData_we_l <= 1'd1;
							ethState <= ethRawStall;
						end
						else begin
							ethState <= ethStart;
						end
					end
				end
				ethRawStall: begin
					ethData_l<={packetCounter,totalPackets,8'd0,ch0_mode};
					ethData_we_l <= 1'd0;
					ethState <= ethRawCheck;
				end
				ethRawCheck: begin
					ethData_we_l <= 1'd0;
					if(packetBusy == 1'b0) begin //make sure the ethernet controller is free
						ethState <= ethRawSetup;
						ch0_freqAddr <= (packetCounter-1)*256;
					end
				end
				ethRawSetup: begin
					ethData_we_l <= 1'd0;
					ethState <= ethRawWrite;
					ch0_freqAddr <=ch0_freqAddr+1;
					packetReady_l <= 1'd1;
				end
				ethRawWrite: begin
					localCounter <= localCounter - 1;
					ch0_freqAddr <=ch0_freqAddr+1;
					ethData_l<=freqData;
					ethData_we_l <= 1'd1;
					packetReady_l <= 1'd0;
					if(ch0_freqAddr%256 == (((1<<ch0_fftSize))%256)) begin //if we've read out all of the FFT values
						ethState <= ethRawFinish;
						ethData_we_l <= 1'd1;
					end
				end
				ethRawFinish: begin
					ethData_l<=freqData;
					ethData_we_l <= 1'd0;
					ethState <= ethRawVerify;
				end
				ethRawVerify: begin
					ethData_we_l <= 1'd0;
					if(ch0_freqAddr >=256) begin
						ethState <= ethRawHeader;
						packetCounter <= packetCounter + 1'b1;
					end
					else begin
						ethState <= ethRawZeros;
						fakeCounter <= 0;
					end
				end
				ethRawZeros: begin
					ch0_freqAddr <=ch0_freqAddr+1;
					//ethData_l<=8'hf1; //temporary fill variable to see where we stop
					ethData_l<=0; //temporary fill variable to see where we stop
					fakeCounter <= fakeCounter + 1;
					ethData_we_l <= 1'd1;
					if(ch0_freqAddr >=255) begin
						ethState <= ethRawHeader;
						packetCounter <= packetCounter + 1'b1;
					end
				end
				default: begin
					ethData_l <= 32'd0;
					ethData_we_l <= 1'd0;
					ethLength_l <= 11'd0;
					packetReady_l <= 1'd0;
					ethState <= ethStart;
					ethCtrl <= 1'b0;
					watchEthFlag <= 1'b0;
				end
			endcase
			watchEthTrigger <= 1'b0;
			if(watchEthCounter == 0) begin
				ethState <= ethStart;
				watchEthTrigger <= 1'b1;
			end
		end
	end

	 /*
	 //doing it this way because this is temporary to see if it works properly
	 reg [3:0] ethState;
	 reg [31:0] ethData_l;
	 reg			ethData_we_l;
	 reg [10:0] ethLength_l;
	 reg			packetReady_l;

	 //state machine to fill data for ethernet
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			ethState <= 4'd0;
			ethData_l <= 32'd0;
			ethData_we_l <= 1'd0;
			ethLength_l <= 11'd0;
			packetReady_l <= 1'd0;
		end
		else begin
			case (ethState)
				4'd0: begin
					ethData_l <= 32'd0;
					ethData_we_l <= 1'd0;
					ethLength_l <= 11'd14;
					packetReady_l <= 1'd0;
					if(packetBusy == 1'b0&&(packetRequested||packetValid)) begin //make sure the ethernet controller is free
						ethState <= 4'd1;
					end
				end
				4'd1: begin
					packetReady_l <= 1'd1;
					ethLength_l <= 11'd14;
					if(packetBusy == 1'b1) begin //make sure it was really free
						ethState <= 4'd2;
						packetReady_l <= 1'd0;
					end
				end
				4'd2: begin //start loading data.  This is ok to tell it to start because it needs to load the header first, we have 42 cycles
					ethData_l <= 32'h8BADF00D;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd3: begin
					ethData_l <= 32'h1BADB002;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd4: begin
					ethData_l <= 32'hBAADF00D;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd5: begin
					ethData_l <= 32'hCAFEBABE;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd6: begin
					ethData_l <= 32'hCAFED00D;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd7: begin
					ethData_l <= 32'hD15EA5E;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd8: begin
					ethData_l <= 32'hDEADBABE;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd9: begin
					ethData_l <= 32'hDEADBEEF;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd10: begin
					ethData_l <= 32'hDEADFA11;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd11: begin
					ethData_l <= 32'hDEFEC8ED;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd12: begin
					ethData_l <= 32'hFACEFEED;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd13: begin
					ethData_l <= 32'hFEE1DEAD;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd14: begin
					ethData_l <= 32'hE011CFD0;
					ethData_we_l <= 1'b1;
					ethState <= ethState + 1'b1;
				end
				4'd15: begin
					ethData_l <= 32'h74686545; //theE in ascii, sort of the end
					ethData_we_l <= 1'b1;
					ethState <= 4'd0;
				end
				default: begin
					ethData_l <= 32'd0;
					ethData_we_l <= 1'd0;
					ethLength_l <= 11'd0;
					packetReady_l <= 1'd0;
					ethState <= 4'd0;
				end
			endcase
		end
	 end
	 */

	 /*
	 //assign registers to wires
	 assign ethData = ethData_l;
	 assign ethData_we = ethData_we_l;
	 assign ethLength = ethLength_l;
	 assign packetReady = packetReady_l;
	 */
ethernet ethernet_inst (
    .EMACCLIENTRXDVLD(EMACCLIENTRXDVLD),
    .EMACCLIENTRXFRAMEDROP(EMACCLIENTRXFRAMEDROP),
    .EMACCLIENTRXSTATS(EMACCLIENTRXSTATS),
    .EMACCLIENTRXSTATSVLD(EMACCLIENTRXSTATSVLD),
    .EMACCLIENTRXSTATSBYTEVLD(EMACCLIENTRXSTATSBYTEVLD),
    .CLIENTEMACTXIFGDELAY(CLIENTEMACTXIFGDELAY),
    .EMACCLIENTTXSTATS(EMACCLIENTTXSTATS),
    .EMACCLIENTTXSTATSVLD(EMACCLIENTTXSTATSVLD),
    .EMACCLIENTTXSTATSBYTEVLD(EMACCLIENTTXSTATSBYTEVLD),
    .CLIENTEMACPAUSEREQ(CLIENTEMACPAUSEREQ),
    .CLIENTEMACPAUSEVAL(CLIENTEMACPAUSEVAL),
    .GTX_CLK(GTX_CLK),
    .GMII_TXD(GMII_TXD),
    .GMII_TX_EN(GMII_TX_EN),
    .GMII_TX_ER(GMII_TX_ER),
    .GMII_TX_CLK(GMII_TX_CLK),
    .GMII_RXD(GMII_RXD),
    .GMII_RX_DV(GMII_RX_DV),
    .GMII_RX_ER(GMII_RX_ER),
    .GMII_RX_CLK(GMII_RX_CLK),
    .MII_TX_CLK(MII_TX_CLK),
    .GMII_COL(GMII_COL),
    .GMII_CRS(GMII_CRS),
    .REFCLK(REFCLK),
    .RESET(RESET_eth),
	 .clk_ext(clk_ext),
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
    .ethData(ethData_l),
    .ethData_we(ethData_we_l),
    .ethLength(ethLength_l),
    .ethHdrData(ethHdrData),
    .ethHdrAddr(ethHdrAddr),
    .ethHdrWE(ethHdrWE),
	 .rawPacketFlag(rawPacketFlag),
	 .fftSize(fftSize),
    .packetBusy(packetBusy),
    .packetReady(packetReady_l),
	 .packetValid(packetValid)
    );

smm smm_i (
(*BOX_TYPE="black_box"*)
  .debug_uart_rx(USB_RX),
  .debug_uart_tx(USB_TX),
  .clk_100MHz(clk_ext),
  .reset(rst_ext),
  .din(ublaze_din_rev),
  .dout(ublaze_dout_rev),
  .be(),
  .rnw(ublaze_rnw),
  .addr(ublaze_addr_rev),
  .cs(ublaze_cs)
);

//================================================================================
// Bit reverse uBlaze addr and data. (uBlaze is big-endian, bit reversed)
//================================================================================
integer i,j;
parameter UBLAZE_DATA_WIDTH = 32;
parameter UBLAZE_ADDR_WIDTH = 16;
always@(*)
	for (i=0;i<UBLAZE_DATA_WIDTH;i=i+1) begin
		ublaze_dout[i] = ublaze_dout_rev[i]; //[(UBLAZE_DATA_WIDTH-1)-i];
		ublaze_din_rev[i] = ublaze_din[i]; //[(UBLAZE_DATA_WIDTH-1)-i];
	end

always@(*)
	for (j=0;j<UBLAZE_ADDR_WIDTH;j=j+1) begin
	ublaze_addr[j] = ublaze_addr_rev[j]; //[(UBLAZE_ADDR_WIDTH-1)-j];
	end

//================================================================================
// uBlaze read cycle address decoding
//================================================================================
always @(*) begin

	case ({ublaze_addr[6],ublaze_addr[5], ublaze_addr[4], ublaze_addr[3], ublaze_addr[2]} )

		5'd0 : begin //0
			ublaze_din <= FIRMWARE_ID;
		end
		5'd1 : begin //4
			ublaze_din <= {FIRMWARE_MAJOR, FIRMWARE_MINOR};
		end
		5'd2 : begin //8
			ublaze_din <= {28'b0,DIP};
		end
		5'd3 : begin //data through the fifo //C
			ublaze_din <= {2'b0,adc_dataQ,2'b0,adc_dataI};
		end
		5'd4 : begin //data skipping the fifo //10
			ublaze_din <= {adc_q_test,adc_i_test};
		end
		5'd5 : begin //internal data //14
			ublaze_din <= {2'b0,ADC_Q[13:0],2'b0,ADC_I[13:0]};
		end
		5'd6 : begin //output of the FFT //18
			ublaze_din <= {freqData};
		end
		5'd7 : begin //timer 0 //1C
			ublaze_din <= timer[0];
		end
		5'd8 : begin //timer 1 //20
			ublaze_din <= timer[1];
		end
		5'd9 : begin //timer 2 //24
			ublaze_din <= timer[2];
		end
		5'd10 : begin //timer 3 //28
			ublaze_din <= timer[3];
		end
		5'd11 : begin //timer 4 //2c
			ublaze_din <= timer[4];
		end
		5'd12 : begin //timer 5 //30
			ublaze_din <= timer[5];
		end
		5'd13 : begin //timer 6 //34
			ublaze_din <= timer[6];
		end
		5'd14 : begin //timer 7 //38
			ublaze_din <= timer[7];
		end
		5'd15 : begin //data through the fifo and smoother //3c
			ublaze_din <= {adc_dataQ3,adc_dataI3};
		end
		5'd16: begin //threshold data //40
			ublaze_din <= threshData;
		end
		default : begin
			ublaze_din <= 32'hABADBABE;
		end

	endcase
end

//flag generation
reg ublaze_rnw_s1;
always@(posedge clk_ext) begin
	if(rst_ext == 1'b1) begin
		readFlag <= 1'b0;
		ublaze_rnw_s1 <= 1'b0;
	end
	else begin
		readFlag <= 1'b0;
		ublaze_rnw_s1 <= ublaze_rnw;
		if(~ublaze_rnw_s1 & ublaze_rnw & (ublaze_addr[5:2]==4'd3)) readFlag <= 1'b1;
		if(~ublaze_rnw_s1 & ublaze_rnw & (ublaze_addr[5:2]==4'd15)) readFlag <= 1'b1;
	end
end

always@(posedge clk_ext) begin
	if(rst_ext == 1'b1) begin
		ethHdrWE <= 1'b0;
		packetFlag <= 1'b0;
	end
	else begin
		ethHdrWE <= 1'b0;
		packetFlag <= 1'b0;
		if((ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd17))) begin
			ethHdrWE <= 1'b1;
		end
		if((ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd18))) begin
			packetFlag <= 1'b1;
		end
	end
end

reg testFlag_s1;
always@(posedge clk_ext) begin
	if(rst_ext == 1'b1) begin
		bus_startFlag <= 1'b0;
		testFlag_s1 <= 1'b0;
	end
	else begin
		bus_startFlag <= 1'b0;
		testFlag_s1 <= testFlag;
		if(~testFlag_s1& testFlag) bus_startFlag <= 1'b1;
	end
end


//================================================================================
//	uBlaze write access -- SW controlled registers
//================================================================================
always @(posedge clk_ext) begin
	if(rst_ext == 1'b1) begin
		leds_int 			<= 4'b1010;
		testFlag <= 1'b0;
		usrp_data <= 18'd0;
		bus_freqAddr <= 16'd0;
		ublaze_threshAddr <= 16'd0;
		ublaze_threshold <= 32'd0;
		threshold_scale <= 32'd0;
		bus_transformWidth <= 5'd10; //default to 1024
		timer6Flag_reg <= 1'b0;
		timer7Flag_reg <= 1'b0;
		timer7Start_reg <= 1'b0;
		bus_mode <= 8'd0;
		bus_freq <= 16'd0;
		bus_echo <= 32'd0;
		bus_testLengthLog <= 8'd0;
		fftScale <= 16'b1010101010101011;
		ethHdrData <= 8'd0;
		ethHdrAddr <= 11'd0;
		unused <= 32'd0;
	end
	else begin
		leds_int        <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd1)) ? ublaze_dout[3:0] : leds_int; //4
		testFlag        <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd2)) ? ublaze_dout[3:0] : testFlag; //8
		usrp_data[16]   <= 1'b0;
		usrp_data[15:0] <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd3)) ? ublaze_dout[15:0] : usrp_data; //C //[1:0] mode + [14:0] remoteFreqCmd
		LED_test			 <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd4)) ? ublaze_dout[0] : LED_test; //10
		bus_freqAddr			 <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd5)) ? ublaze_dout[15:0] : bus_freqAddr; //14
		threshold_scale <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd6)) ? ublaze_dout[31:0] : threshold_scale; //18
		bus_transformWidth	 <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd7)) ? ublaze_dout[4:0] : bus_transformWidth; //1C
		ublaze_threshold		 <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd8)) ? ublaze_dout[31:0] : ublaze_threshold; //20
		timer6Flag_reg       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd9)) ? ublaze_dout[0] : timer6Flag_reg; //24
		timer7Flag_reg       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd10)) ? ublaze_dout[0] : timer7Flag_reg; //28
		timer7Start_reg       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 4'd11)) ? ublaze_dout[0] : timer7Start_reg; //2C
		bus_mode       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd12)) ? ublaze_dout[7:0] : bus_mode; //30
		bus_freq       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd13)) ? ublaze_dout[15:0] : bus_freq; //34
		bus_echo       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd14)) ? ublaze_dout[31:0] : bus_echo; //38
		bus_testLengthLog       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd15)) ? ublaze_dout[7:0] : bus_testLengthLog; //3C
		fftScale       <= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd16)) ? ublaze_dout[15:0] : fftScale; //40
		ethHdrData		<= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd17)) ? ublaze_dout[7:0] : ethHdrData; //44
		ethHdrAddr		<= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd17)) ? ublaze_dout[26:16] : ethHdrAddr; //44
		unused		<= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd18)) ? ublaze_dout[31:0] : unused; //48 //place holder for send packet flag
		ublaze_threshAddr	<= (ublaze_cs & ~ublaze_rnw & (ublaze_addr[15:2] == 14'd19)) ? ublaze_dout[15:0] : ublaze_threshAddr; //4c //bus threshold addr
	end
end

//fake data generator
always@(posedge clk_ext) begin
	if(rst_ext == 1'b1) begin
		ADC_I<=16'd0;
		ADC_Q<=16'd32767;
	end
	else begin
		if(ublaze_cs==1'b1 && ublaze_rnw==1'b1) begin
			ADC_I <= ADC_I+1'b1;
			ADC_Q <= ADC_Q+1'b1;
		end
		if(testFlag == 1'b1) begin
			ADC_I<=16'd0;
			ADC_Q<=16'd32767;
		end
	end
end



/*
adc_int readFifo (
    .clk(clk),
    .rst(rst),
    .clk_ext(clk_ext),
    .adc_data_in(debug_in),
	 .readFlag(readFlag),
	 .startFlag(startFlag),
    .adc_dataI(adc_dataI),
	 .adc_dataQ(adc_dataQ)
    );


adc_int_stream readFifo2 (
    .clk(clk),
    .rst(rst),
    .clk_ext(clk_ext),
    .adc_data_in(debug_in),
    .adc_dataI(adc_dataI2),
	 .adc_dataQ(adc_dataQ2)
    );
*/
wire dvalid;
wire [15:0] i_out,q_out;

/*
smooth_rf rf_smoother (
    .clk(clk),
    .rst(rst),
    .i_in(adc_dataI2),
    .q_in(adc_dataQ2),
    .i_out(i_out),
    .q_out(q_out),
    .dvalid(dvalid)
    );
 */
adc_int_smooth readFifo3 (
    .clk(clk_ext),
    .rst(rst_ext),
    .iq_we(1'b1),
    .i_in(adc_i_test),
    .q_in(adc_q_test),
    .readFlag(readFlag),
    .startFlag(bus_startFlag),
    .adc_dataI(adc_dataI3),
    .adc_dataQ(adc_dataQ3)
    );

wire  timer3Flag , timer4Flag, timer5Flag;

assign threshold	= (ethCtrl)?ch0_threshold:ublaze_threshold;
assign startFlag	= (ethCtrl)?ch0_startFlag:bus_startFlag;
assign freqAddr 	= (ethCtrl)?ch0_freqAddr:bus_freqAddr;
assign threshAddr = (ethCtrl)?ch0_threshAddr:ublaze_threshAddr;
assign transformWidth 	= (ethCtrl)?(ch0_fftSize):bus_transformWidth;



user_block UB (
    .clk(clk_ext),
    .rst(rst_ext),
	 .startFlag(startFlag),
	 .mode(usrp_data[16:15]),
	 .adc_dataI(adc_dataI),
    .adc_dataQ(adc_dataQ),
	 .transform_width_log2(transformWidth), //set transform to 1024
    .threshold(threshold),  //set threshold to software defined value
	 .threshold_scale(threshold_scale),  //set threshold_scale to software defined value
    .freqAddr(freqAddr), //requested frequency value
	 .threshAddr(threshAddr),
	 .fftScale(fftScale), //scale schedule for the FFT
	 .initFFT(timer3Flag),
    .fftDone(timer4Flag),
	 .fftInProgress(fftInProgress),
	 .fftMemFull(fftMemFull),
    .thresholdingDone(thesholdingDone),
    .freqData(freqData), //data cooreseponding to the request
	 .threshData(threshData)
    );

	 assign timer5Flag=thresholdingDone;

	 reg  timer0Flag_ext;
	 reg [13:0] debug_in_s1,debug_in_s2,debug_in_s3,debug_in_s4;
	 /*
	 //end timer 0 when the data first enters the FPGA fifo
	 always@(posedge clk_ext) begin
		timer0Flag_ext <= 1'b0;
		debug_in_s1 <= debug_in[13:0];
		debug_in_s2 <= debug_in_s1;
		debug_in_s3 <= debug_in_s2;
		debug_in_s4 <= debug_in_s3;
		if(debug_in[13:0] == 14'h1FFF && debug_in_s1 == 14'h1FFF&& debug_in_s2 != 14'h1FFF&& debug_in_s3 != 14'h1FFF) begin
			timer0Flag_ext <= 1'b1;
		end
	 end
	 */
	 //resolve any metastability / clock crossing issues
	 reg  timer0Flag_s1,timer0Flag_s2,timer0Flag;
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			timer0Flag_s1 <= 1'b0;
			timer0Flag_s2 <= 1'b0;
			timer0Flag <= 1'b0;
		end
		else begin
			timer0Flag_s1 <= timer0Flag_ext;
			timer0Flag_s2 <= timer0Flag_s1;
			timer0Flag <= timer0Flag_s2;
		end
	 end

	 reg  timer1Flag,timer2Flag;
	 reg [13:0] adc_dataI2_s1,adc_dataI2_s2,adc_dataI2_s3;
	 //end timer 1 when the data first enters the FPGA clock domain
	 //end timer 2 when the last part of the data enters the FPGA clock domain
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			timer1Flag <= 1'b0;
			timer2Flag <= 1'b0;
			adc_dataI2_s1 <= 14'd0;
			adc_dataI2_s2 <= 14'd0;
			adc_dataI2_s3 <= 14'd0;
		end
		else begin
			timer1Flag <= 1'b0;
			timer2Flag <= 1'b0;
			adc_dataI2_s1 <= adc_dataI2;
			adc_dataI2_s2 <= adc_dataI2_s1;
			adc_dataI2_s3 <= adc_dataI2_s2;
			if(adc_dataI2 == 14'h1FFF && adc_dataI2_s1 == 14'h1FFF && adc_dataI2_s2 == 14'h1FFF && adc_dataI2_s3 != 14'h1FFF) begin
				timer1Flag <= 1'b1;
			end
			if(adc_dataI2 != 14'h1FFF && adc_dataI2_s1 != 14'h1FFF && adc_dataI2_s2 == 14'h1FFF && adc_dataI2_s3 == 14'h1FFF) begin
				timer2Flag <= 1'b1;
			end
		end
	 end

	 reg testStart;
	 reg [1:0] mode_s1;
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			testStart <= 1'b0;
			mode_s1 <= 2'b0;
		end
		else begin
			testStart <= 1'b0;
			mode_s1 <= usrp_data[16:15];
			if(usrp_data[16:15] == 2'd2 && mode_s1 != 2'd2) begin
				testStart <= 1'b1;
			end
		end
	 end


	 //find rising edge of timer 6 flag reg
	 reg timer6Flag,timer6Flag_s1;;
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			timer6Flag <= 1'b0;
			timer6Flag_s1 <= 1'b0;
		end
		else begin
			timer6Flag <= 1'b0;
			timer6Flag_s1 <= timer6Flag_reg;
			if(timer6Flag_s1 == 1'b0 && timer6Flag_reg == 1'b1) begin
				timer6Flag <= 1'b1;
			end
		end
	 end

	 //find rising edge of timer 7 flag reg
	 reg timer7Flag,timer7Flag_s1;;
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			timer7Flag <= 1'b0;
			timer7Flag_s1 <= 1'b0;
		end
		else begin
			timer7Flag <= 1'b0;
			timer7Flag_s1 <= timer7Flag_reg;
			if(timer7Flag_s1 == 1'b0 && timer7Flag_reg == 1'b1) begin
				timer7Flag <= 1'b1;
			end
		end
	 end

	 //find rising edge of timer 7 Start reg
	 reg timer7Start,timer7Start_s1;;
	 always@(posedge clk_ext) begin
		if(rst_ext == 1'b1) begin
			timer7Start <= 1'b0;
			timer7Start_s1 <= 1'b0;
		end
		else begin
			timer7Start <= 1'b0;
			timer7Start_s1 <= timer7Start_reg;
			if(timer7Start_s1 == 1'b0 && timer7Start_reg == 1'b1) begin
				timer7Start <= 1'b1;
			end
		end
	 end

	 timer timer0(.clk(clk_ext),.rst(rst_ext),.timer(timer[0]),.start(testStart),.stop(timer0Flag)); //data enters FPGA fifo from USRP
	 timer timer1(.clk(clk_ext),.rst(rst_ext),.timer(timer[1]),.start(testStart),.stop(timer1Flag)); //data enters FPGA clock domain
	 timer timer2(.clk(clk_ext),.rst(rst_ext),.timer(timer[2]),.start(testStart),.stop(timer2Flag)); //last bit of data enters clock domain
	 timer timer3(.clk(clk_ext),.rst(rst_ext),.timer(timer[3]),.start(testStart),.stop(timer3Flag)); //the start of the FFT
	 timer timer4(.clk(clk_ext),.rst(rst_ext),.timer(timer[4]),.start(testStart),.stop(timer4Flag)); //fft done
	 timer timer5(.clk(clk_ext),.rst(rst_ext),.timer(timer[5]),.start(testStart),.stop(timer5Flag)); //thresholding done (not used yet)
	 timer timer6(.clk(clk_ext),.rst(rst_ext),.timer(timer[6]),.start(testStart),.stop(timer6Flag));
	 timer timer7(.clk(clk_ext),.rst(rst_ext),.timer(timer[7]),.start(timer7Start),.stop(timer7Flag));



assign LEDs[2:0]	= leds_int[2:0];
assign LEDs[3]		= rst_ext_n;
assign LED2[3:0]	= DIP[3:0];
assign LED2[7:4]	= leds_int[3:0];
//assign LED2[7] 	= |errors;
//assign Mic1DE[15] = DIP[0];
//assign Mic1DO[6:0] = DIP[7:1];
//assign debug_out = usrp_data;


endmodule

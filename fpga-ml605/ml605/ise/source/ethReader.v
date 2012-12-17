`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:59 11/04/2011 
// Design Name: 
// Module Name:    ethReader 
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
module ethReader(
    input clk,
    input rst,
    input [7:0] dataIn,
    input sof_n,
    input eof_n,
    input src_rdy_n,
    output dst_rdy_n,
	 
	 //general data
	 output reg [7:0]	gen_numChannels,
	 output reg [7:0]	gen_spare0,
	 output reg [7:0]	gen_spare1,
	 output reg [7:0]	gen_spare2,
	 
	 //channel 0 data
	 output reg [31:0] ch0_threshold,
	 output reg [7:0]	ch0_mode,
	 output reg [7:0]	ch0_fftSize,
	 output reg [31:0]	ch0_frequency,
	 output reg [7:0]	ch0_spare0,
	 output reg [7:0]	ch0_spare1,
	  
	 //channel 1 data
	 output reg [31:0] ch1_threshold,
	 output reg [7:0]	ch1_mode,
	 output reg [7:0]	ch1_fftSize,
	 output reg [31:0]	ch1_frequency,
	 output reg [7:0]	ch1_spare0,
	 output reg [7:0]	ch1_spare1,
	 
	 //channel 2 data
	 output reg [31:0] ch2_threshold,
	 output reg [7:0]	ch2_mode,
	 output reg [7:0]	ch2_fftSize,
	 output reg [31:0]	ch2_frequency,
	 output reg [7:0]	ch2_spare0,
	 output reg [7:0]	ch2_spare1,
	 
	 //channel 3 data
	 output reg [31:0] ch3_threshold,
	 output reg [7:0]	ch3_mode,
	 output reg [7:0]	ch3_fftSize,
	 output reg [31:0]	ch3_frequency,
	 output reg [7:0]	ch3_spare0,
	 output reg [7:0]	ch3_spare1,
	 
    output reg packetValid
    );
	 
	 //signals for negative logic
	 wire sof;
	 wire eof;
	 wire src_rdy;
	 reg dst_rdy;
	 
	 //assigns for active low logic
	 assign sof=~sof_n;
	 assign eof=~eof_n;
	 assign src_rdy=~src_rdy_n;
	 assign dst_rdy_n = 0;
	 
	 localparam genBase = 13'd42;
	 localparam ch0Base = genBase + 8;
	 localparam ch1Base = ch0Base + 12;
	 localparam ch2Base = ch1Base + 12;
	 localparam ch3Base = ch2Base + 12;
	 
	 
	 	reg [16:0] watchCounter;
	reg watchFlag;
	(* KEEP = "TRUE" *)reg watchReadTrigger;
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			watchCounter <= 16'd26;
		end
		else begin
			if(watchCounter > 16'd0) watchCounter <= watchCounter-1;
			if(watchFlag == 1'b1) watchCounter <= 16'd16000;
		end
	end
	 
	(* KEEP = "TRUE" *)reg [4:0] state;
	 reg [12:0] byteCounter;
	 reg [31:0] identWord;
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			state <= 5'd0;
			byteCounter <= 13'd0;
			//TODO: init all variables to 0
			identWord <= 0;
			gen_numChannels <= 0;
			gen_spare0 <=0;
			gen_spare1 <=0;
			gen_spare2 <=0;
			ch0_threshold <= 0;
			ch0_fftSize	<= 0;
			ch0_frequency	<= 0;
			ch0_spare0<=0;
			ch0_spare1<=0;
			ch1_threshold <= 0;
			ch1_fftSize	<= 0;
			ch1_frequency	<= 0;
			ch1_spare0<=0;
			ch1_spare1<=0;
			ch2_threshold <= 0;
			ch2_fftSize	<= 0;
			ch2_frequency	<= 0;
			ch2_spare0<=0;
			ch2_spare1<=0;
			ch3_threshold <= 0;
			ch3_fftSize	<= 0;
			ch3_frequency	<= 0;
			ch3_spare0<=0;
			ch3_spare1<=0;
			watchFlag <= 1'b1;
			watchReadTrigger <= 0;
		end
		else begin
			case(state)
				5'd0: begin
					identWord <= 32'd0;
					watchFlag <= 1'b1;
					if(sof==1'b1&&src_rdy==1'b1) begin //start of frame
						state <= 5'd1;
						byteCounter <= 13'd1;
						watchFlag <= 1'b0;
					end
				end
				5'd1: begin
          packetValid <= 1'b0;
					watchFlag <= 1'b0;
					byteCounter <= byteCounter + 1'b1;
					case(byteCounter)
						//general packet information
						(genBase + 13'd0): identWord[31:24]<=dataIn;
						(genBase + 13'd1): identWord[23:16]<=dataIn;
						(genBase + 13'd2): identWord[15:8]<=dataIn;
						(genBase + 13'd3): identWord[7:0]<=dataIn;
						(genBase + 13'd4): gen_numChannels[7:0]<=dataIn;
						(genBase + 13'd5): gen_spare0[7:0]<=dataIn;
						(genBase + 13'd6): gen_spare1[7:0]<=dataIn;
						(genBase + 13'd7): gen_spare2[7:0]<=dataIn;
						//channel 0 information
						(ch0Base + 13'd0): ch0_threshold[31:24]<=dataIn;
						(ch0Base + 13'd1): ch0_threshold[23:16]<=dataIn;
						(ch0Base + 13'd2): ch0_threshold[15:8]<=dataIn;
						(ch0Base + 13'd3): ch0_threshold[7:0]<=dataIn;
						(ch0Base + 13'd4): ch0_fftSize[7:0]<=dataIn;
						(ch0Base + 13'd5): ch0_mode[7:0]<=dataIn;
						(ch0Base + 13'd6): ch0_frequency[31:24]<=dataIn;
						(ch0Base + 13'd7): ch0_frequency[23:16]<=dataIn;
						(ch0Base + 13'd8): ch0_frequency[15:8]<=dataIn;
						(ch0Base + 13'd9): ch0_frequency[7:0]<=dataIn;
						(ch0Base + 13'd10): ch0_spare0[7:0]<=dataIn;
						(ch0Base + 13'd11): ch0_spare1[7:0]<=dataIn;
						//channel 1 information
						(ch1Base + 13'd0): ch1_threshold[31:24]<=dataIn;
						(ch1Base + 13'd1): ch1_threshold[23:16]<=dataIn;
						(ch1Base + 13'd2): ch1_threshold[15:8]<=dataIn;
						(ch1Base + 13'd3): ch1_threshold[7:0]<=dataIn;
						(ch1Base + 13'd4): ch1_fftSize[7:0]<=dataIn;
						(ch1Base + 13'd5): ch1_mode[7:0]<=dataIn;
						(ch1Base + 13'd6): ch1_frequency[31:24]<=dataIn;
						(ch1Base + 13'd7): ch1_frequency[23:16]<=dataIn;
						(ch1Base + 13'd8): ch1_frequency[15:8]<=dataIn;
						(ch1Base + 13'd9): ch1_frequency[7:0]<=dataIn;
						(ch1Base + 13'd10): ch1_spare0[7:0]<=dataIn;
						(ch1Base + 13'd11): ch1_spare1[7:0]<=dataIn;
						//channel 2 information
						(ch2Base + 13'd0): ch2_threshold[31:24]<=dataIn;
						(ch2Base + 13'd1): ch2_threshold[23:16]<=dataIn;
						(ch2Base + 13'd2): ch2_threshold[15:8]<=dataIn;
						(ch2Base + 13'd3): ch2_threshold[7:0]<=dataIn;
						(ch2Base + 13'd4): ch2_fftSize[7:0]<=dataIn;
						(ch2Base + 13'd5): ch2_mode[7:0]<=dataIn;
						(ch2Base + 13'd6): ch2_frequency[31:24]<=dataIn;
						(ch2Base + 13'd7): ch2_frequency[23:16]<=dataIn;
						(ch2Base + 13'd8): ch2_frequency[15:8]<=dataIn;
						(ch2Base + 13'd9): ch2_frequency[7:0]<=dataIn;
						(ch2Base + 13'd10): ch2_spare0[7:0]<=dataIn;
						(ch2Base + 13'd11): ch2_spare1[7:0]<=dataIn;
						//channel 3 information
						(ch3Base + 13'd0): ch3_threshold[31:24]<=dataIn;
						(ch3Base + 13'd1): ch3_threshold[23:16]<=dataIn;
						(ch3Base + 13'd2): ch3_threshold[15:8]<=dataIn;
						(ch3Base + 13'd3): ch3_threshold[7:0]<=dataIn;
						(ch3Base + 13'd4): ch3_fftSize[7:0]<=dataIn;
						(ch3Base + 13'd5): ch3_mode[7:0]<=dataIn;
						(ch3Base + 13'd6): ch3_frequency[31:24]<=dataIn;
						(ch3Base + 13'd7): ch3_frequency[23:16]<=dataIn;
						(ch3Base + 13'd8): ch3_frequency[15:8]<=dataIn;
						(ch3Base + 13'd9): ch3_frequency[7:0]<=dataIn;
						(ch3Base + 13'd10): ch3_spare0[7:0]<=dataIn;
						(ch3Base + 13'd11): ch3_spare1[7:0]<=dataIn;
						default: begin
							
						end
					endcase
					if(eof==1'b1) begin //end of frame
						state <= 5'd2;
					end
					if(src_rdy == 1'b0) begin //data not coming out anymore
						state <= 5'd2;
					end
				end
				5'd2: begin //could be a problem cause this is blocking the flow, we'd miss sof.
					watchFlag <= 1'b0;
					state <= 5'd0;
					packetValid <= 1'b0;
					if(identWord == 32'hdeadbeef) begin //TODO: Add better checking than this
						packetValid <= 1'b1;
					end
				end
				default: begin
					state <= 5'd0;
				end
			endcase
			watchReadTrigger <= 0;
			if(watchCounter == 0) begin
				state <= 0;
				watchReadTrigger <= 1;
			end
		end
	 end


endmodule

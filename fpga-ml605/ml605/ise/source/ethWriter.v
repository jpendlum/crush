`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:54 11/01/2011 
// Design Name: 
// Module Name:    ethWriter 
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



module ethWriter(
    input					clk,			//clock, on the transmitter domain
    input 					rst,			//reset on the transmitter domain
	 input					clk_ext,		
	 input		[31:0]	ethData,		//data to write out ethernet port
	 input					ethData_we, //enable line to check data into fifo
	 input		[10:0]	ethLength,	//amount of data, reported in words
	 input		[7:0]		ethHdrData_e,	//data for the header
	 input		[10:0]	ethHdrAddr_e, //address for the header
	 input					ethHdrWE_e,	//write enable for the ethernet header
	 input		[7:0]		fftSize,		//so we set the correct packet size
	 input					rawPacket,	//indicates that this is a raw packet, so 1k in length
    output reg [7:0]		data_out,			//output data
	 output 					sof_n,		//start of frame
	 output 					eof_n,		//end of frame
	 output 					src_rdy_n,	//source ready
	 input					dst_rdy_n,	//destination ready
	 output reg				packetBusy,	//signal that the packet was sent
	 input					packetReady //incoming signal that a packet is ready
    );
	 
	 localparam init		= 10'd0,
					start		= 10'd1,
					finish	= 10'd2,
					header	= 10'd3,
					data		= 10'd4,
					fetch		= 10'd5,
					last		= 10'd6,
					waitHdr	= 10'd7;
	 
	 reg [9:0]	state;
	 reg 			sof,eof,src_rdy;
	 wire 		dst_rdy;
	 reg [11:0] hdr_int_addr;
	 wire [7:0] hdr_dout;
	 reg [10:0] dataCounter;
	 wire [7:0] ethDataOut;
	 reg			ethDataRE;
	 wire			ethDataFull;
	 wire			ethDataEmpty;
	 reg			ethHdrFlag;
	 wire		[7:0]		ethHdrData;	//data for the header
	 wire		[10:0]	ethHdrAddr; //address for the header
	 wire					ethHdrWE;	//write enable for the ethernet header
	 reg		[7:0]		ethHdrData_l;	//data for the header
	 reg		[10:0]	ethHdrAddr_l; //address for the header
	 reg					ethHdrWE_l;	//write enable for the ethernet header
   
	 
	 //assigns for active low logic
	 assign 		dst_rdy = ~dst_rdy_n;
	 assign 		sof_n = ~sof;
	 assign 		eof_n = ~eof;
	 assign 		src_rdy_n = ~src_rdy;
	 
	 //assigns for internal / external blockRAM writing.  This is so we can write the length into the header
	 assign ethHdrData=(ethHdrFlag)?ethHdrData_l:ethHdrData_e;
	 assign ethHdrAddr=(ethHdrFlag)?ethHdrAddr_l:ethHdrAddr_e;
	 assign ethHdrWE=(ethHdrFlag)?ethHdrWE_l:ethHdrWE_e;
	 
	 //block ram to store the header
	 //this is wired to the microblaze processor so it can be modified in software without
	 //changing the FPGA
	 ethHeader ethHeader_inst	 (
		.clka(clk_ext),
		.wea(ethHdrWE), // Bus [0 : 0] 
		.addra(ethHdrAddr), // Bus [10 : 0] 
		.dina(ethHdrData), // Bus [7 : 0] 
		.clkb(clk),
		.addrb(hdr_int_addr), // Bus [10 : 0] 
		.doutb(hdr_dout) // Bus [7 : 0] 
		 );
	
	 //fifo to store the data portion of the message.  This takes in 32 bit words and
	 //outputs 8 bit bytes.
	 ethFifo ethFifo_inst (
		.rst(rst),
		.wr_clk(clk_ext),
		.rd_clk(clk),
		.din(ethData), // Bus [31 : 0] 
		.wr_en(ethData_we),
		.rd_en(ethDataRE),
		.dout(ethDataOut), // Bus [7 : 0] 
		.full(ethDataFull),
		.empty(ethDataEmpty)
		);
		
		
		//TODO: I've settled on two packet sizes, one for fast, processed data, one for raw data.
		// the issue is that inorder for packets to not be thrown out, the IP length, IP checksum and UDP length
		// have to be correct.  If this were calculated everytime a packet was sent, it would take too long.
		// so we'll have two fixed packet sizes. The long packet will always have a payload of 1024 which results in
		// a udp length of 1038 and an IP length of 1058.  The checksum is then 14e2.  The short packet will be of length
	/*
	reg [1:0] lenState;
	always@(posedge clk_ext) begin
		if(rst == 1'b1) begin
			ethHdrAddr_l <= 11'd0;
			ethHdrData_l <= 8'd0;
			ethHdrWE_l <= 1'b0;
			lenState <= 2'd0;
			ethHdrFlag <= 1'b0;
		end
		else begin
			case(lenState)
				2'd0: begin
					ethHdrFlag <= 1'b0;
					if(packetReady == 1'b1) begin
						lenState <= 2'd1;
						ethHdrFlag <= 1'b1;
					end
				end
				2'd1: begin
					ethHdrData_l <= ((ethLength<<2)+10)&8'hff; //the length, multiplied by 4 for words to bytes, but the lower 8 bits
					ethHdrAddr_l <= 11'h27;
					ethHdrWE_l <= 1'b1;
					lenState<= 2'd2;
				end
				2'd2: begin
					ethHdrData_l <= (((ethLength<<2)+10)>>8)&8'hff; //the length, multiplied by 4 for words to bytes, but the upper 8 bits
					ethHdrAddr_l <= 11'h26;
					ethHdrWE_l <= 1'b1;
					lenState<= 2'd0;
				end
				default: begin
					ethHdrAddr_l <= 11'd0;
					ethHdrData_l <= 8'd0;
					ethHdrWE_l <= 1'b0;
					lenState <= 2'd0;
					ethHdrFlag <= 1'b0;
				end
			endcase
		end	
	end
	*/
	//TODO: matlab checksums were wrong, manually editted them.
	reg [4:0] lenState;
	reg [7:0] hdrData[0:5];
	reg [7:0] hdrAddr[0:5];
	always@(posedge clk_ext) begin
		if(rst == 1'b1) begin
			ethHdrAddr_l <= 11'd0;
			ethHdrData_l <= 8'd0;
			ethHdrWE_l <= 1'b0;
			lenState <= 5'd0;
			ethHdrFlag <= 1'b0;
		end
		else begin
			case(lenState)
				5'd0: begin
					ethHdrFlag <= 1'b0;
					if(packetReady == 1'b1) begin
						lenState <= 5'd1;
						ethHdrFlag <= 1'b1;
					end
					ethHdrWE_l <= 1'b0;
				end
				5'd1: begin
					lenState <= 5'd2;
					case(fftSize) //note this state machine was generated in Matlab for all the possible packet sizes
						8'd3: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=46;
							hdrAddr[2]=24;
							hdrData[2]=8'he6;
							hdrAddr[3]=25;
							hdrData[3]=8'h08;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=26;
						end
						8'd4: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=46;
							hdrAddr[2]=24;
							hdrData[2]=8'he6;
							hdrAddr[3]=25;
							hdrData[3]=8'h08;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=26;
						end
						8'd5: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=46;
							hdrAddr[2]=24;
							hdrData[2]=8'he6;
							hdrAddr[3]=25;
							hdrData[3]=8'h08;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=26;
						end
						8'd6: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=46;
							hdrAddr[2]=24;
							hdrData[2]=8'he6;
							hdrAddr[3]=25;
							hdrData[3]=8'h08;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=26;
						end
						8'd7: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=50;
							hdrAddr[2]=24;
							hdrData[2]=8'he6;
							hdrAddr[3]=25;
							hdrData[3]=8'h04;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=30;
						end
						8'd8: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=66;
							hdrAddr[2]=24;
							hdrData[2]=8'he5;
							hdrAddr[3]=25;
							hdrData[3]=8'hf4;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=46;
						end
						8'd9: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=98;
							hdrAddr[2]=24;
							hdrData[2]=8'he5;
							hdrAddr[3]=25;
							hdrData[3]=8'hd4;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=78;
						end
						8'd10: begin
							hdrAddr[0]=16;
							hdrData[0]=0;
							hdrAddr[1]=17;
							hdrData[1]=162;
							hdrAddr[2]=24;
							hdrData[2]=8'he5;
							hdrAddr[3]=25;
							hdrData[3]=8'h94;
							hdrAddr[4]=38;
							hdrData[4]=0;
							hdrAddr[5]=39;
							hdrData[5]=142;
						end
						8'd11: begin
							hdrAddr[0]=16;
							hdrData[0]=1;
							hdrAddr[1]=17;
							hdrData[1]=34;
							hdrAddr[2]=24;
							hdrData[2]=8'he5;
							hdrAddr[3]=25;
							hdrData[3]=8'h14;
							hdrAddr[4]=38;
							hdrData[4]=1;
							hdrAddr[5]=39;
							hdrData[5]=14;
						end
						8'd12: begin
							hdrAddr[0]=16;
							hdrData[0]=2;
							hdrAddr[1]=17;
							hdrData[1]=34;
							hdrAddr[2]=24;
							hdrData[2]=8'he4;
							hdrAddr[3]=25;
							hdrData[3]=8'h14;
							hdrAddr[4]=38;
							hdrData[4]=2;
							hdrAddr[5]=39;
							hdrData[5]=14;
						end
						8'd13: begin
							hdrAddr[0]=16;
							hdrData[0]=4;
							hdrAddr[1]=17;
							hdrData[1]=34;
							hdrAddr[2]=24;
							hdrData[2]=8'he2;
							hdrAddr[3]=25;
							hdrData[3]=8'h14;
							hdrAddr[4]=38;
							hdrData[4]=4;
							hdrAddr[5]=39;
							hdrData[5]=14;
						end
						8'd0: begin //for raw packets
							hdrAddr[0]=16;
							hdrData[0]=8'h4;
							hdrAddr[1]=17;
							hdrData[1]=8'h22;
							hdrAddr[2]=24;
							hdrData[2]=8'he2;
							hdrAddr[3]=25;
							hdrData[3]=8'h14;
							hdrAddr[4]=38;
							hdrData[4]=8'h4;
							hdrAddr[5]=39;
							hdrData[5]=8'h0a;
						end
						default: begin
							hdrAddr[0]=16;
							hdrData[0]=8'h4;
							hdrAddr[1]=17;
							hdrData[1]=8'h22;
							hdrAddr[2]=24;
							hdrData[2]=8'he2;
							hdrAddr[3]=25;
							hdrData[3]=8'h14;
							hdrAddr[4]=38;
							hdrData[4]=8'h4;
							hdrAddr[5]=39;
							hdrData[5]=8'h0a;
						end
					endcase
				end
				5'd2: begin
					ethHdrData_l <= hdrData[0];
					ethHdrAddr_l <= hdrAddr[0];
					ethHdrWE_l <= 1'b1;
					lenState<= lenState + 1'b1;
				end
				5'd3: begin
					ethHdrData_l <= hdrData[1];
					ethHdrAddr_l <= hdrAddr[1];
					ethHdrWE_l <= 1'b1;
					lenState<= lenState + 1'b1;
				end
				5'd4: begin
					ethHdrData_l <= hdrData[2];
					ethHdrAddr_l <= hdrAddr[2];
					ethHdrWE_l <= 1'b1;
					lenState<= lenState + 1'b1;
				end
				5'd5: begin
					ethHdrData_l <= hdrData[3];
					ethHdrAddr_l <= hdrAddr[3];
					ethHdrWE_l <= 1'b1;
					lenState<= lenState + 1'b1;
				end
				5'd6: begin
					ethHdrData_l <= hdrData[4];
					ethHdrAddr_l <= hdrAddr[4];
					ethHdrWE_l <= 1'b1;
					lenState<= lenState + 1'b1;
				end
				5'd7: begin
					ethHdrData_l <= hdrData[5];
					ethHdrAddr_l <= hdrAddr[5];
					ethHdrWE_l <= 1'b1;
					lenState<= 5'd0;
				end
				default: begin
					ethHdrAddr_l <= 11'd0;
					ethHdrData_l <= 8'd0;
					ethHdrWE_l <= 1'b0;
					lenState <= 2'd0;
					ethHdrFlag <= 1'b0;
				end
			endcase
		end	
	end
	 
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			data_out		<= 8'd0;
			sof		<= 1'b0;
			eof		<= 1'b0;
			src_rdy	<= 1'd0;
			state 	<= init;
			hdr_int_addr <= 11'd0;
			packetBusy <= 1'b0;
			ethDataRE <= 1'b0;
			dataCounter <= 11'd0;
		end
		else begin
			sof		<= 1'b0;
			eof		<= 1'b0;
			case(state)
				init: begin
					packetBusy <= 1'b0;
					sof		<= 1'b0;
					eof		<= 1'b0;
					src_rdy	<= 1'd0;
					ethDataRE <= 1'b0;
					if(dst_rdy == 1'b1&& packetReady == 1'b1) begin //if the ethernet stack is ready and there is a packet waiting
						packetBusy <= 1'b1;
						state <= fetch;
						hdr_int_addr <= 11'd0; //request first part of header
						dataCounter <= (ethLength<<2); //ethLength is in words, multiply by 4 for bytes
					end
				end
				fetch: begin
					hdr_int_addr <=hdr_int_addr+1'b1; //increment address for header
					state <= start;
				end
				start: begin
					src_rdy <= 1'b1;	//enable writing to the ethernet fifo
					sof<= 1'b1;			//start of frame
					data_out <= hdr_dout;	//data from header block ram
					hdr_int_addr <=hdr_int_addr+1'b1; //increment address for header
					state <= header;
				end
				header: begin
					data_out <= hdr_dout;	//data from header block ram
					hdr_int_addr <=hdr_int_addr+1'b1; //increment address for header
					if(hdr_int_addr == 11'd43) begin //ethernet + IP + UDP header is 42 bytes long + 2 filler bytes to make it aligned
						state <= waitHdr;
						ethDataRE <= 1'b1;
					end
				end
				//TODO: for some reason we're not getting the packet structure we desire
				waitHdr: begin			
					data_out <= hdr_dout;	//data from header block ram
					ethDataRE <= 1'b1;
					state <= data; 
				end
				data: begin
					ethDataRE <= 1'b1;
					dataCounter <= dataCounter-1;
					data_out <= ethDataOut;
					if(dataCounter == 11'd1) begin
						state <= finish;
						eof		<= 1'b1;
						ethDataRE <= 1'b0;
					end
				end
				last: begin
					data_out <= ethDataOut;
					state <= finish;
				end
				finish: begin
					sof		<= 1'b0;
					eof		<= 1'b0;
					src_rdy	<= 1'd0;
					state		<= init;
				end
				default: begin
					sof		<= 1'b0;
					eof		<= 1'b0;
					src_rdy	<= 1'd0;
					packetBusy <= 1'b0;
					state <= init;
				end
			endcase
		end
	 end
	
endmodule

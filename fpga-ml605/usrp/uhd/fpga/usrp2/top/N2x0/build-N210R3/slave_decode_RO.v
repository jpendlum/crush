`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:09:33 01/08/2012 
// Design Name: 
// Module Name:    slave_decode_RO 
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
module slave_decode_RO(
    input clk,
    input rst,
    input clk_ext,
    input REQ,
    output reg ACK,
    input [5:0] addr,
    input [7:0] data,
	 //output data
    output reg [7:0] mode,
    output reg 			mode_stb,
    output reg [31:0] echo,
	 output reg			echo_stb,
    output reg [15:0] freq,
	 output reg			freq_stb,
	 output reg	[7:0]		testLengthLog,
	 output reg				testLengthLog_stb
    );
	 
	 //clock signals
	 wire clk_bus;
	 wire lock_bus;
	 reg rstToggle;
	 reg [2:0] rst_s;
	 wire rst_bus;
	 
	 //fifo in signals
	 reg bus_in_re;
	 reg bus_in_we;
	 //wire [13:0] bus_in_din;
	 wire[13:0] bus_in_dout;
	 (* KEEP = "TRUE" *) wire bus_in_full;
	 (* KEEP = "TRUE" *) wire bus_in_empty;
	 (* KEEP = "TRUE" *) wire[9:0] bus_in_rd_data_count;
	 (* KEEP = "TRUE" *) wire[9:0] bus_in_wr_data_count;
	 
	 //incoming state machine signals
	 reg dataRdy;
	reg[17:0] bus_in_dout_reg;
	reg [1:0] incomingState;
	
	//dcm for the bus clock
	 dcm_bus_clk dcm (
		 .CLKIN_IN(clk_ext), 
		 .RST_IN(rst), 
		 .CLK0_OUT(clk_bus), 
		 .LOCKED_OUT(lock_bus)
		 );
		 
	//transfer the rst to the new clock domain	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			rstToggle <= ~rstToggle;
		end
	end
	always@(posedge clk_bus) begin
		rst_s <= {rst_s[1:0],rstToggle};
	end
	assign rst_bus = (rst_s[2] ^ rst_s[1]);
	
		 
	//Data from the ML605 to the USRP
	// this data from the bus is on the remote clock, so it needs to be transfered to the local clock
	bus_fifo_slave bus_fifo_input (
		.rst(rst_bus),
		.wr_clk(clk_bus),
		.rd_clk(clk),
		.din({4'd0,addr,data}), // Bus [17 : 0] 
		.wr_en(bus_in_we),
		.rd_en(bus_in_re),
		.dout(bus_in_dout), // Bus [17 : 0] 
		.full(bus_in_full),
		.empty(bus_in_empty),
		.rd_data_count(bus_in_rd_data_count), // Bus [9 : 0] 
		.wr_data_count(bus_in_wr_data_count)  // Bus [9 : 0]
		);
		
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			dataRdy <= 1'b0;
			bus_in_re <= 1'b0;
			bus_in_dout_reg <= 18'd0;
			incomingState <= 2'b0;
		end
		else begin
			case(incomingState)
				2'd0: begin
					dataRdy <= 1'b0;
					bus_in_re <= 1'b0;
					if(bus_in_empty == 1'b0) begin //data in fifo
						incomingState <= 2'd1;
						bus_in_re <= 1'b1;
					end
				end
				2'd1: begin
					bus_in_re <= 1'b0;
					incomingState <= 2'd2;
				end
				2'd2: begin
					bus_in_dout_reg <= bus_in_dout;
					incomingState <= 2'd0;
					dataRdy <= 1'b1;
				end
				default: begin
					incomingState <= 1'b0;
				end
			endcase
		end
	end
	
	
	//state machine to process input values.  Add more as needed up to 64 addresses.
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			mode <= 8'd8; //default to 8 which is I and Q.
			mode_stb <= 1'd0;
			echo <= 32'd0;
			echo_stb <= 1'd0;
			freq <= 16'd0;
			freq_stb <= 1'd0;
			testLengthLog <= 8'b0;
			testLengthLog_stb <= 1'b0;
		end
		else begin
			mode_stb <= 1'd0;
			echo_stb <= 1'd0;
			freq_stb <= 1'd0;
			testLengthLog_stb <= 1'b0;
			if(dataRdy == 1'b1) begin
				case(bus_in_dout_reg[13:8])
					6'd0: begin
						mode <= bus_in_dout_reg[7:0];
						mode_stb <= 1'b1;
					end
					6'd1: begin
						freq[7:0] <= bus_in_dout_reg[7:0];
					end
					6'd2: begin
						freq[15:8] <= bus_in_dout_reg[7:0];
						freq_stb <= 1'b1;
					end
					6'd3: begin
						echo[7:0] <= bus_in_dout_reg[7:0];
					end
					6'd4: begin
						echo[15:8] <= bus_in_dout_reg[7:0];
					end
					6'd5: begin
						echo[23:16] <= bus_in_dout_reg[7:0];
					end
					6'd6: begin
						echo[31:24] <= bus_in_dout_reg[7:0];
						echo_stb <= 1'b1;
					end
					6'd7: begin
						testLengthLog[7:0] <= bus_in_dout_reg[7:0];
						testLengthLog_stb <= 1'b1;
					end
					default: begin
					
					end
				endcase
			end
		end
	end
	
	//bus signals
	 wire REQ_bus,ACK_bus;
	 reg bus_rnw; //read=1,write=0;
	 reg [13:0] writeData;
	reg REQflag;	 
	reg ACKflag;
	reg REQVal,ACKVal;
	reg [3:0] state;
	localparam	waiting		= 4'd0,
					wait_for_ack = 4'd1,
					get_data		= 4'd2,
					set_data		= 4'd3,
					hold	= 4'd4,
					ack_wait		= 4'd5,
					ack_wait2	= 4'd6,
					receive_data = 4'd7,
					wait_for_req = 4'd8,
					ack_wait3 = 4'd9;
					
	reg [16:0] watchCounter;
	reg watchFlag;
	
	always@(posedge clk_bus) begin
		if(rst_bus == 1'b1) begin
			watchCounter <= 16'd30;
		end
		else begin
			if(watchCounter > 16'd0) watchCounter <= watchCounter-1;
			if(watchFlag == 1'b1) watchCounter <= 16'd30;
		end
	end
	
	always@(posedge clk_bus) begin
		if(rst == 1'b1) begin
			state <= waiting;
			writeData <= 14'd0;
			//REQflag <= 1'b0;
			//REQVal <= 1'b1;
			//bus_out_re <= 1'b0;
			//bus_rnw <= 1'b1;
			//ACKflag <= 1'b0;
			//ACKVal <= 1'b1;
			ACK <= 1'b0;
			bus_in_we <= 1'b0;
			watchFlag <= 1'b0;
		end
		else begin
			//bus_out_re <= 1'b0;
			//bus_rnw <= 1'b1;
			bus_in_we <= 1'b0;
			watchFlag <= 1'b0;
			case(state)
				waiting: begin
					//REQflag <= 1'b0;
					//ACKflag <= 1'b0;
					//REQVal <= 1'b1;
					//ACKVal <= 1'b1;
					ACK <= 1'b0;
					watchFlag <= 1'b1;
					if(REQ == 1'b1) begin //bus wants to write
						state <=ack_wait;
						//ACKflag <= 1'b1;
						ACK <= 1'b1;
					end
				end
				/*
				wait_for_ack: begin
					if(ACK_bus == 1'b0) begin
						bus_out_re <= 1'b1; //tell outgoing fifo we want data
						state <= get_data;
					end
				end
				get_data: begin
					state <= set_data;
				end
				set_data: begin
					writeData[13:0] <= bus_out_dout[13:0]; //send the data from the fifo to the bus
					bus_rnw <= 1'b0; //write data
					REQVal <= 1'b1; //pull up
					state <= hold;
					//state <=waiting;
				end
				hold: begin
					bus_rnw <= 1'b1; //switch back to reading
					if(ACK_bus == 1'b1) begin //ack off
						REQflag <= 1'b0; //release bus
						state <=waiting;
					end
				end
				*/
				ack_wait: begin
					state <= ack_wait2;
				end
				ack_wait2: begin
					state <= ack_wait3;
				end
				ack_wait3: begin
					state <= receive_data;
				end
				receive_data: begin
					//ACKflag <= 1'b1; //keep bus
					ACK <= 1'b1; //pullup
					bus_in_we <= 1'b1;
					state <= wait_for_req;
				end
				wait_for_req: begin
					if(REQ == 1'b0) begin
						ACK <= 1'b0; //release bus
						state <= waiting;
					end
				end
				default: begin
					state <= waiting;
				end
			endcase
			if(watchCounter == 0) begin
				state <= waiting;
			end
		end
	end

	//assignments
	//assign REQ_bus = bus[15];
	//assign ACK_bus = bus[14];

	//bidirectional bus assignment statements
	//assign bus[13:0] = (bus_rnw)?14'bz:writeData; //if bus_rnw is 1, we read, if it is 0, we write
	//assign bus[15] = (REQflag)?((REQVal)?1'b1:1'b0) :1'bz;
	//assign bus[14] = (ACKflag)?((ACKVal)?1'b1:1'b0) :1'bz;
	//assign bus_in_din[13:0] = (bus_rnw)?bus[13:0]:14'd0;
	 
	 


endmodule

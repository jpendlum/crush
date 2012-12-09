`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:35:25 03/02/2011 
// Design Name: 
// Module Name:    addr_decode 
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
module addr_decode(
    input clk,
    input rst,
    input clk_ext,
    input [15:0] data_in,
    output reg [1:0] addr_out,
    output reg [14:0] data_out
    );
	 
	 wire [16:0] fifo_out;
	 //fifo to cross clock boundary
	 fifo_clk_cross clk_cross (
		.rst(rst),
		.wr_clk(clk_ext),
		.rd_clk(clk),
		.din({2'b0,data_in}), // Bus [17 : 0] 
		.wr_en(1'b1),
		.rd_en(1'b1),
		.dout(fifo_out), // Bus [17 : 0] 
		.full(),
		.empty()
		);
		
		reg [15:0] testCounter,testCounter_s1;
		reg clkFlag;
		always@(posedge clk_ext) begin
			testCounter = testCounter + 1'b1;
		end
		
		
		reg [3:0] count16;
		//check to see if the clock is running or not.  If not, set output to 0
		always@(posedge clk) begin
			if(rst == 1'b1) begin
				clkFlag <= 1'b1;
				count16 <= 4'b0;
			end
			else begin
				count16 <= count16 + 1'b1;
				if(count16 == 0) begin
					if(testCounter == testCounter_s1) begin
						clkFlag <= 1'b0;
					end
					else begin
						clkFlag <= 1'b1;
					end
					testCounter_s1 <= testCounter;
				end
			end
		end
		
		
		always@(posedge clk) begin
			if(rst == 1'b1) begin
				addr_out <= 15'd0;
				data_out <= 2'd0;
			end
			else begin
				case (clkFlag)
					1'b0: begin
						addr_out <= 15'd0;
						data_out <= 2'd0;
					end
					1'b1: begin
						addr_out <= fifo_out[15:14];
						data_out <= fifo_out[13:0];
					end
					default: begin
						addr_out <= 15'd0;
						data_out <= 2'd0;
					end
				endcase
			end
		end
		
		//assign addr_out = fifo_out[16:15];
		//assign data_out = fifo_out[14:0];

endmodule

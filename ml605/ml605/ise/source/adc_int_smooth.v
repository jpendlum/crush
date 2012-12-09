					`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:48:52 03/02/2011 
// Design Name: 
// Module Name:    adc_int 
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
module adc_int_smooth(
    input clk,
    input rst,
	 input iq_we,
    input [15:0] i_in,
    input [15:0] q_in,
	 input readFlag,
	 input startFlag,
    output reg [15:0] adc_dataI,
	 output reg [15:0] adc_dataQ
    );
	 
	 reg wr_en;
	 wire [17:0] doutI,doutQ;
	 reg readFlag_s1;
	 wire full;
	 wire emtpy;
	 reg rd_en;
	 reg intRst;
	 
	smooth_fifo sFifoI (
	.clk(clk),
	.rst(intRst),
	.din({2'd0,i_in}), // Bus [17 : 0] 
	.wr_en(iq_we&wr_en),
	.rd_en(rd_en),
	.dout(doutI), // Bus [17 : 0] 
	.full(fullI),
	.empty(emptyI));
		
	smooth_fifo sFifoQ(
		.rst(intRst),
		.clk(clk),
		.din({2'd0,q_in}), // Bus [13 : 0] 
		.wr_en(iq_we&wr_en),
		.rd_en(rd_en),
		.dout(doutQ), // Bus [13 : 0] 
		.full(fullQ),
		.empty(emptyQ)
		);

	localparam 	waiting	= 4'd0,
					loading	= 4'd1,
					preread	= 4'd2,
					reading	= 4'd3,
					resetting = 4'd4,
					filling = 4'd5;
	
	reg [3:0] state;
	reg [3:0] count;
	
	always@(posedge clk) begin
		if( rst == 1'b1) begin
			state <= waiting;
			wr_en <= 1'b0;
			rd_en <= 1'b0;
			adc_dataI <= {4'b0,12'hBAD};
			adc_dataQ <= {4'b0,12'hBAD};
			intRst <=1'b1;
			count <= 4'd0;
		end
		else begin
			case (state)
				waiting: begin
					intRst <= 1'b0;
					if(startFlag == 1'b1) begin
						intRst <= 1'b1;
						count<= 4'd10;
						state <= resetting;
					end
					else if(readFlag == 1'b1) begin
						if(emptyI == 1'b1||emptyQ == 1'b1) begin
							adc_dataI <= {4'b0,12'hBAD};
							adc_dataQ <= {4'b0,12'hBAD};
							state <= waiting;
						end
						else begin
							rd_en <= 1'b1;
							adc_dataI <= {4'b0,12'hBEF};
							adc_dataQ <= {4'b0,12'hBEF};
							state <= reading;
						end
					end
				end
				resetting: begin
					if(count >0) begin
						count <= count -1;
						intRst <=1'b1;
					end
					else begin
						intRst <=1'b0;
						if(emptyI == 1'b1 && emptyI == 1'b1) begin
							wr_en <= 1'b1;
							state <= filling;
							count <=8;
						end
					end					
				end
				filling: begin
					if(count >0) begin
						count <= count -1;
					end
					else begin
						state <= loading;
					end
				end
				loading: begin
					intRst <= 1'b0;
					if(fullI == 1'b1||fullQ == 1'b1) begin
						wr_en <= 1'd0;
						state <= waiting;
					end
				end
				reading: begin
					rd_en <= 1'b0;
					adc_dataI <= doutI[15:0];
					adc_dataQ <= doutQ[15:0];
					state <= waiting;
				end
				default: begin
					state <= waiting;
				end
			endcase
		end
	end

endmodule

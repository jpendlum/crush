`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:01:02 07/23/2011 
// Design Name: 
// Module Name:    timer 
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
module timer(
    input clk,
    input rst,
    output reg [31:0] timer, //timer rolls in 42 seconds, should be more than enough
    input start,
    input stop
    );
	 
	 reg [3:0] state;
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			timer <= 32'hDEADBEEF;
			state <= 4'd0;
		end
		else begin
			case(state)
				4'd0: begin
					if(start == 1'b1) begin
						state <= 4'd1;
						timer <= 32'd0;
					end
				end
				4'd1: begin
					timer <= timer + 1'b1;
					if (stop == 1'b1) begin
						state <= 4'd0;
					end
					if (start == 1'b1) begin
						timer <= 32'd0;
					end
				end
				default: begin
					state <= 4'd0;
					timer <= 32'hDEADBEEF;
				end
			endcase
		end
	 end


endmodule

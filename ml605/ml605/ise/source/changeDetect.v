`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:48:24 10/03/2011 
// Design Name: 
// Module Name:    changeDetect 
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
module changeDetect
	#(parameter WIDTH = 32)
	(
    input clk,
    input rst,
    input [WIDTH-1:0] register,
    output reg chg,
    input ack
    );


	reg state;
	reg [WIDTH-1:0] register_s1;
	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			register_s1 <= 0;
		end
		else begin
			register_s1 <= register;
		end
	end
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			chg <= 1'b0;
		end
		else begin
			case(state)
				1'b0: begin
					if(register != register_s1) begin
						chg <= 1'b1;
						state <= 1'b1;
					end
				end
				1'b1: begin
					if(ack == 1'b1) begin
						chg <= 1'b0;
						state <= 1'b0;
					end
				end
				default: begin
					state <= 1'b0;
					chg <= 1'b0;
				end
			endcase
		end
	end
endmodule

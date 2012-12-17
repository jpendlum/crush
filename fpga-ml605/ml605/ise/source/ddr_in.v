`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:36:24 09/28/2011 
// Design Name: 
// Module Name:    ddr_in 
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
module ddr_in(
    input clk,
    input rst,
    input clk_ext,
    input [14:0] data_in,
    output reg [15:0] adc_i_out,
	 output reg [15:0] adc_q_out
	 
    );
	 
	 wire [14:0] adc_i,adc_q;
	/*
	// IDDR: Input Double Data Rate Input Register with Set, Reset
	// and Clock Enable.
	// Virtex-6
	// Xilinx HDL Libraries Guide, version 12.1
	IDDR #(
	.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE"
	// or "SAME_EDGE_PIPELINED"
	.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
	.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
	) IDDR_inst (
	.Q1(Q1), // 1-bit output for positive edge of clock
	.Q2(Q2), // 1-bit output for negative edge of clock
	.C(C), // 1-bit clock input
	.CE(CE), // 1-bit clock enable input
	.D(D), // 1-bit DDR data input
	.R(R), // 1-bit reset
	.S(S) // 1-bit set
	);
	// End of IDDR_inst instantiation
	 */
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_0( .Q1(adc_i[0]),.Q2(adc_q[0]),.C(clk_ext),.CE(1'b1),.D(data_in[0]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_1( .Q1(adc_i[1]),.Q2(adc_q[1]),.C(clk_ext),.CE(1'b1),.D(data_in[1]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_2( .Q1(adc_i[2]),.Q2(adc_q[2]),.C(clk_ext),.CE(1'b1),.D(data_in[2]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_3( .Q1(adc_i[3]),.Q2(adc_q[3]),.C(clk_ext),.CE(1'b1),.D(data_in[3]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_4( .Q1(adc_i[4]),.Q2(adc_q[4]),.C(clk_ext),.CE(1'b1),.D(data_in[4]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_5( .Q1(adc_i[5]),.Q2(adc_q[5]),.C(clk_ext),.CE(1'b1),.D(data_in[5]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_6( .Q1(adc_i[6]),.Q2(adc_q[6]),.C(clk_ext),.CE(1'b1),.D(data_in[6]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_7( .Q1(adc_i[7]),.Q2(adc_q[7]),.C(clk_ext),.CE(1'b1),.D(data_in[7]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_8( .Q1(adc_i[8]),.Q2(adc_q[8]),.C(clk_ext),.CE(1'b1),.D(data_in[8]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_9( .Q1(adc_i[9]),.Q2(adc_q[9]),.C(clk_ext),.CE(1'b1),.D(data_in[9]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_10( .Q1(adc_i[10]),.Q2(adc_q[10]),.C(clk_ext),.CE(1'b1),.D(data_in[10]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_11( .Q1(adc_i[11]),.Q2(adc_q[11]),.C(clk_ext),.CE(1'b1),.D(data_in[11]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_12( .Q1(adc_i[12]),.Q2(adc_q[12]),.C(clk_ext),.CE(1'b1),.D(data_in[12]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_13( .Q1(adc_i[13]),.Q2(adc_q[13]),.C(clk_ext),.CE(1'b1),.D(data_in[13]),.R(1'b0),.S(1'b0) );
	 IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_14( .Q1(adc_i[14]),.Q2(adc_q[14]),.C(clk_ext),.CE(1'b1),.D(data_in[14]),.R(1'b0),.S(1'b0) );
	 //IDDR#(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) IDDR_15( .Q1(adc_i[15]),.Q2(adc_q[15]),.C(clk_ext),.CE(1'b1),.D(data_in[15]),.R(1'b0),.S(1'b0) );
	 

	always@(posedge clk_ext) begin
		adc_i_out <= {adc_i[14],adc_i[14:0]};
		adc_q_out <= {adc_q[14],adc_q[14:0]};
	end

endmodule

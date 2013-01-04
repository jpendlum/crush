`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:59 03/27/2011 
// Design Name: 
// Module Name:    ddr_data_out 
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
module ddr_data_out(
    input clk,
	 input rst,
    input [15:0] dataI,
    input [15:0] dataQ,
    output clkOut,
    output [15:0] dataOut
    );
/*	 
	// ODDR2: Output Double Data Rate Output Register with Set, Reset
	// and Clock Enable.
	// Spartan-3E/3A
	// Xilinx HDL Libraries Guide, Version 9.1.3i
	ODDR2 #(
			.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1"
			.INIT(1'b0), // Sets initial state of the Q output to 1'b0 or 1'b1
			.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
			) ODDR2_inst (
				.Q(Q), // 1-bit DDR output data
				.C0(C0), // 1-bit clock input
				.C1(C1), // 1-bit clock input
				.CE(CE), // 1-bit clock enable input
				.D0(D0), // 1-bit data input (associated with C0)
				.D1(D1), // 1-bit data input (associated with C1)
				.R(R), // 1-bit reset input
				.S(S) // 1-bit set input
				);
	// End of ODDR2_inst instantiation
	*/ 
	
	ODDR2 ODDR_0(.D1(dataI[0]),.D0(dataQ[0]),.C1(clk),.C0(~clk),.Q(dataOut[0]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_1(.D1(dataI[1]),.D0(dataQ[1]),.C1(clk),.C0(~clk),.Q(dataOut[1]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_2(.D1(dataI[2]),.D0(dataQ[2]),.C1(clk),.C0(~clk),.Q(dataOut[2]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_3(.D1(dataI[3]),.D0(dataQ[3]),.C1(clk),.C0(~clk),.Q(dataOut[3]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_4(.D1(dataI[4]),.D0(dataQ[4]),.C1(clk),.C0(~clk),.Q(dataOut[4]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_5(.D1(dataI[5]),.D0(dataQ[5]),.C1(clk),.C0(~clk),.Q(dataOut[5]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_6(.D1(dataI[6]),.D0(dataQ[6]),.C1(clk),.C0(~clk),.Q(dataOut[6]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_7(.D1(dataI[7]),.D0(dataQ[7]),.C1(clk),.C0(~clk),.Q(dataOut[7]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_8(.D1(dataI[8]),.D0(dataQ[8]),.C1(clk),.C0(~clk),.Q(dataOut[8]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_9(.D1(dataI[9]),.D0(dataQ[9]),.C1(clk),.C0(~clk),.Q(dataOut[9]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_10(.D1(dataI[10]),.D0(dataQ[10]),.C1(clk),.C0(~clk),.Q(dataOut[10]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_11(.D1(dataI[11]),.D0(dataQ[11]),.C1(clk),.C0(~clk),.Q(dataOut[11]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_12(.D1(dataI[12]),.D0(dataQ[12]),.C1(clk),.C0(~clk),.Q(dataOut[12]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_13(.D1(dataI[13]),.D0(dataQ[13]),.C1(clk),.C0(~clk),.Q(dataOut[13]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_14(.D1(dataI[14]),.D0(dataQ[14]),.C1(clk),.C0(~clk),.Q(dataOut[14]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_15(.D1(dataI[15]),.D0(dataQ[15]),.C1(clk),.C0(~clk),.Q(dataOut[15]),.CE(1'b1),.S(1'b0),.R(1'b0));
	ODDR2 ODDR_clk(.D1(1'b1),.D0(1'b0),.C1(clk),.C0(~clk),.Q(clkOut),.CE(1'b1),.S(1'b0),.R(1'b0));
	
	 
	 
	 /*
	 //create 200MHz clock
	 clk2x dcm (
    .CLKIN_IN(clk), 
    .RST_IN(rst), 
    .CLKFX_OUT(clkOut), 
    .CLK0_OUT(), 
    .LOCKED_OUT()
    );
	 
	 always@(posedge clkOut) begin
		if(rst == 1'b1) begin
			dataOut <= 14'd0;
		end
		else begin
			if(clk == 1'b0) begin
				dataOut <= {clk,dataI};
			end
			else begin
				dataOut <= {clk,dataQ};
			end
		end
	 end
	*/

endmodule

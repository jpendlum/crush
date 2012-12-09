`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT Lincoln Laboratory
// Engineer:       Scott Bailie
// 
// Create Date:   
// Module Name:    
// Project Name:   
// Target Devices: 
// Description:   
//                 
//
//////////////////////////////////////////////////////////////////////////////////

module smm(
					
			//==================================
			// CLOCK AND RESET 
			//==================================
				SIN,
				SOUT,
				CLK,
				RESET,
				DIN,
				DOUT,
				BE,
				RNW,
				ADDR,
				CS,
				INTERRUPT,
				INTERRUPT_ACK  

			)/* synthesis syn_black_box */;
		


input              CLK;					  	
input              RESET;            

input        		 SIN;        	 
output        		 SOUT;  
  
output [3:0] BE;
output 					 RNW;
output        [15:0] ADDR;
input         [31:0] DIN;
output        [31:0] DOUT;
output               CS;

input INTERRUPT;
output INTERRUPT_ACK;
 
endmodule
						`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:57 03/02/2011 
// Design Name: 
// Module Name:    user_block 
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
module user_block(
    input clk,
    input rst,
	 input startFlag,
	 input [1:0] mode,
    input [15:0] adc_dataI,
	 input [15:0] adc_dataQ,
	 input [4:0] transform_width_log2,
	 input [31:0] threshold,
	 input [31:0] threshold_scale,
	 input [15:0] freqAddr,
	 input [15:0] threshAddr,
	 input [15:0] fftScale,
	 output reg		initFFT,
	 output reg		fftDone,
	 output reg    fftInProgress,
	 output reg    fftMemFull,
	 output reg		thresholdingDone,
    output [31:0] freqData,
    output [31:0] threshData
	// output reg [1023:0] freqPosition
    );
	 
	 reg [4:0] nfft_s1;
	 reg nfft_we_change;
	 reg nfft_we_test;
	 wire nfft_we;
	 reg scale_sch_we;
	 reg [15:0] scale_sch;
	 reg start;
	 //wire [15:0] xk_index_fft;
	 reg [4:0] nfft;
	 wire edone;
	 reg [31:0] dina;
	 reg [3:0] state;
	 reg wea;
	 wire [29:0] iSquare,qSquare;
	 wire [30:0] iqMag;
	 reg [30:0] iqMagT;
	 reg [15:0] adc_dataI_s1, adc_dataQ_s1;
	 reg [15:0] adc_dataI_s2, adc_dataQ_s2;
	 reg [15:0] adc_dataI_s3, adc_dataQ_s3;
	 
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			adc_dataI_s1 <= 15'd0;
			adc_dataI_s2 <= 15'd0;
			adc_dataI_s3 <= 15'd0;
			adc_dataQ_s1 <= 15'd0;
			adc_dataQ_s2 <= 15'd0;
			adc_dataQ_s3 <= 15'd0;
		end
		else begin
			adc_dataI_s1 <= adc_dataI;
			adc_dataI_s2 <= adc_dataI_s1;
			adc_dataI_s3 <= adc_dataI_s2;
			adc_dataQ_s1 <= adc_dataQ;
			adc_dataQ_s2 <= adc_dataQ_s1;
			adc_dataQ_s3 <= adc_dataQ_s2;
		end
	 end
	 
	 //trigger value for the write enable for the FFT scale
	 //16'b1010101010101011; //conservative initial scaling
	 reg [15:0] scale_sch_s1;
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			scale_sch		<= 16'd0;
			scale_sch_s1	<= 16'd0;
			scale_sch_we	<= 1'b0;
		end
		else begin
			scale_sch <= fftScale;
			scale_sch_s1 <= fftScale;
			scale_sch_we <= 1'b0;
			if(scale_sch_s1 != fftScale) begin
				scale_sch_we <= 1'b1;
			end
		end
	 end
	 
	 
	 //trigger value for the write enable for the FFT size
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			nfft <= 5'd0;
			nfft_s1 <= 5'b0;
			nfft_we_change <= 1'b0;
		end
		else begin
			nfft <= transform_width_log2;
			nfft_s1 <= nfft;
			nfft_we_change <= 1'b0;
			if(nfft_s1 != nfft) begin
				nfft_we_change <= 1'b1;
			end
		end
	 end
	 
	 assign nfft_we = (mode[1:0]==2'd2)?nfft_we_test:nfft_we_change; //if we are in test mode, take the nfft_we signal from the test flag
	 
	reg [2:0] initState;
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			nfft_we_test <= 1'b0;
			initState <= 3'b0;
			initFFT <= 1'b0;
		end
		else begin
			initFFT <= 1'b0;
			case(initState)
				3'd0: begin
					nfft_we_test <= 1'b0;
					if(mode == 2'd2) begin
						initState <= 3'd1;
					end
				end
				3'd1: begin
					nfft_we_test <= 1'b1; //hold FFT in reset
					if(adc_dataI == 14'h1FFF && adc_dataI_s1 == 14'h1FFF && adc_dataI_s2 == 14'h1FFF) begin
						nfft_we_test <= 1'b0; //release
						initState <= 3'd2;
						initFFT <= 1'b1;
					end
				end
				3'd2: begin
					nfft_we_test <= 1'b0;
					if(mode != 2'd2) begin
						initState <= 3'd0;
					end
				end
				default: begin
					initState <= 3'd0;
				end
			endcase
			if(mode != 2'd2) begin
				initState <= 3'd0;
			end
		end
	end
	 
	 
	 
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			start <= 1'b0;
		end
		else begin
			start <= 1'b1;
		end
	 end
	 
	 
	 wire [15:0] xk_re, xk_im;
	 wire [15:0] xk_index;
	 
	init_fft fft (
	.clk(clk),
	.nfft(nfft), // Bus [4 : 0] 
	.nfft_we(nfft_we),
	.start(start),
	.xn_re(adc_dataI_s3), // Bus [15 : 0]  //I sign extended this to make sim work, if the real thing stops, change this back
	.xn_im(adc_dataQ_s3), // Bus [15 : 0] 
	.fwd_inv(1'b0),
	.fwd_inv_we(1'b0),
	.scale_sch(scale_sch), // Bus [15 : 0] 
	.scale_sch_we(scale_sch_we),
	.rfd(),
	.xn_index(), // Bus [14 : 0] 
	.busy(busy),
	.edone(edone),
	.done(),
	.dv(),
	.xk_index(xk_index[14:0]), // Bus [14 : 0] 
	.xk_re(xk_re), // Bus [15 : 0] 
	.xk_im(xk_im) // Bus [15 : 0] 
	);

	//square the outputs of the FFT, the input is signed and the output is unsigned (square operator)
	square i2(
	.clk(clk),
	.a(xk_re),  // Bus [15 : 0] 
	.b(xk_re),  // Bus [15 : 0] 
	.p(iSquare)); // Bus [29 : 0] 

	square q2(
	.clk(clk),
	.a(xk_im), // Bus [15 : 0] 
	.b(xk_im), // Bus [15 : 0] 
	.p(qSquare)); // Bus [29 : 0]	
	
	adder iqAdd (
	.a(iSquare), // Bus [29 : 0] 
	.b(qSquare), // Bus [29 : 0] 
	.clk(clk),
	.s(iqMag)); // Bus [30 : 0]
	
	/*
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			dina		<= 32'd0;
			iqMagT 	<= 51'd0;
		end
		else begin
			iqMagT[51:0] <=iqMag>>threshold_scale;
			dina[31:0] <= iqMagT[31:0];
		end
	end
	*/
	//assign dina[15:0] = (iqMag>>threshold)&15'hFFFF;
	/*
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			freqPosition <= 1024'd0;
		end
		else begin
			if(iqMagT >= threshold) begin
				freqPosition[xk_index_s4] = 1'b1;
			end
			else begin
				freqPosition[xk_index_s4] = 1'b0;
			end
		end
	end
	*/
	
	 
	 reg [14:0]	xk_index_s1,xk_index_s2,xk_index_s3,xk_index_s4;
	 
	 //pipeline the index to match the above thresholding operation
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			xk_index_s1 <= 15'd0;
			xk_index_s2 <= 15'd0;
			xk_index_s3 <= 15'd0;
			xk_index_s4 <= 15'd0;
		end
		else begin
			xk_index_s1 <= xk_index;
			xk_index_s2 <= xk_index_s1;
			xk_index_s3 <= xk_index_s2;
			xk_index_s4 <= xk_index_s3;
		end
	 end
	
	reg [8:0] threshAddrIn;
	reg [31:0] threshDataIn;
	reg		threshWE;
	
	threshMem mem2 (
	.clka(clk),
	.wea(threshWE), // Bus [0 : 0] 
	.addra(threshAddrIn), // Bus [8 : 0] 
	.dina(threshDataIn), // Bus [31 : 0] 
	.clkb(clk),
	.addrb(threshAddr), // Bus [8 : 0] 
	.doutb(threshData) // Bus [31 : 0] 
	);
	
	freq_mem mem1 (
	.clka(clk),
	.ena(1'b1),
	.wea(wea), // Bus [0 : 0] 
	.addra(xk_index_s2), // Bus [14 : 0]  
	.dina({1'b0,iqMag}), // Bus [31 : 0] 
	.clkb(clk),
	.addrb(freqAddr[14:0]), // Bus [14 : 0] 
	.doutb(freqData)); // Bus [31 : 0]	
	
	//check the threshold
	reg [3:0] threshState;
	reg threshNext;
	reg fftComplete;
	
	//just for debugging
	wire bit32flag_s1,bit32flag_s2,bit32flag_s3,bit32flag_s5;
	wire [15:0] bitflag_s4;
	assign bit32flag_s1 = (xk_index_s3[14:0]>0) && ((xk_index_s3[14:0]%32)==0);
	assign bit32flag_s2 = (xk_index_s3[14:0]>0);
	assign bit32flag_s3 = ((xk_index_s3[14:0]%32)==0);
	assign bit32flag_s4 = xk_index_s3[4:0];
	assign bit32flag_s5 = (iqMag>threshold)?1'b1:1'b0;
	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			threshState <= 4'd0;
			threshAddrIn <= 9'd0;
			threshDataIn <= 32'd0;
			threshWE <= 1'b0;
			threshNext <= 1'b0;
			thresholdingDone <= 1'b0;
		end
		else begin
			case(threshState)
				4'd0: begin
					thresholdingDone <= 1'b0;
					threshWE <= 1'b0;
					threshAddrIn <= 9'd0;
					threshDataIn <= 0;
					if(startFlag == 1'b1) begin
						threshState <= 4'd1;
					end
				end
				4'd1: begin
					thresholdingDone <= 1'b0;
					threshWE <= 1'b0;
					threshAddrIn <= 9'd0;
					threshDataIn <= 0;
					if(xk_index_s1 == 15'd1) begin
						threshState <= 4'd2;
					end
				end
				4'd2: begin
					thresholdingDone <= 1'b0;
					threshWE <= 1'b0;
					threshDataIn[xk_index_s2[4:0]]<=(iqMag>threshold)?1'b1:1'b0; //set the threshold result
					if((xk_index_s2[14:0]>0) && ((xk_index_s2[4:0])==5'd31)) begin //if we are done with a 32 bit result
						threshWE <= 1'b1;
						threshNext <= 1'b1;
					end
					if(threshNext == 1'b1) begin //if we just wrote
						threshDataIn[31:1] <= 31'd0; //reset the top bits
						threshWE <= 1'b0;
						threshNext <= 1'b0;
						threshAddrIn <= threshAddrIn + 1;
					end
					if(fftComplete == 1'b1) begin //if we are done with an entire thresholding operation
						if(threshNext==1'b1) begin
							threshWE <= 1'b0;
						end
						else begin
							threshWE <= 1'b1;
						end
						//threshAddrIn <= 9'd0;
						thresholdingDone <= 1'b1;
						threshState <= 4'd0;
					end
				end
				default: begin
					threshState <= 4'd0;
				end
			endcase
		end
	end
	
	/*
		wire [27:0] fft_out;
		wire [9:0] fft_position;
		//threshold detector
		always@(posedge clk) begin
			if(rst == 1'b1) begin
				freq_vector <= 1024'd0;
			end
			else begin
				if(fft_out >= threshold) begin
					freq_vector[fft_position] <= 1'b1;
				end
				else begin
					freq_vector[fft_position] <= 1'b0;
				end
			end
		end //always

	assign vector_out = freq_vector;
	*/
	
	reg oneShot;
	reg [3:0] fftState;
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			fftDone <= 1'b0;
			oneShot <= 1'b0;
			fftState <= 4'd0;
		end
		else begin
			fftDone <= 1'b0;
			case(fftState)
				4'd0: begin
					if(mode == 2'd2) begin
						fftState <= 4'd1;
					end
				end
				4'd1: begin
					if(nfft_we_test == 1'b1) begin
						fftState <= 4'd2;
					end
				end
				4'd2: begin
					if(nfft_we_test == 1'b0) begin
						fftState <= 4'd3;
					end
				end
				4'd3: begin
					if(xk_index_s2 == ((1 << transform_width_log2) -1) && xk_index_s3 == ((1 << transform_width_log2) -2)) begin //if we are done with the transform
						fftDone <= 1'b1;
						fftState <= 4'd0;
					end
				end
				default: begin
					fftState <= 4'd0;
				end
			endcase
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			state <= 4'd0;
			wea <= 1'b0;
			fftInProgress <= 1'b0;
			fftMemFull <= 1'b0;
			fftComplete <= 1'b0;
		end
		else begin
			fftComplete <= 1'b0;
			case (state)
				4'd0: begin //waiting for read flag
					fftMemFull <= 1'b0;
					fftInProgress <= 1'b0;
					if(startFlag == 1'b1) begin
						state <= 4'd1;
					end
				end
				4'd1: begin //waiting for zero on the index s2, which is 1 on s1
					if(xk_index_s1 == 15'd1) begin
						wea <= 1'b1;
						state <= 4'd2;
						fftInProgress <= 1'b1;
					end
				end
				4'd2: begin //waiting for zero on the index
					if(xk_index_s2 == 15'd0) begin
						wea <= 1'b0;
						state <= 4'd0;
						fftMemFull <= 1'b1;
						fftComplete <= 1'b1;
					end
				end
				default: begin
					wea <= 1'd0;
					state <= 4'd0;
				end			
			endcase
		end
	end
	
	
endmodule

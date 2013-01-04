		`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:52:43 09/29/2011 
// Design Name: 
// Module Name:    master_data_bus 
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

//bus structure:
// this node is the master.  It will provide the clock for the bus.
// bus[15] = REQ line.  Always high unless someone requests the line 
// bus[14] = ACK line.  The master will ack that the request line has been received
// bus[13:8] = address lines. There are 6 addresses, so 2^6=64 different locations for addresses;
// bus[7:0] = data lines

//bus operation: All lines are bidirectional except for the clock.  The clock is 100 MHz and provided by the master.  All data transfers should be synced
//		to the master's clock.  The ACK and REQ lines are pulled high in hardware on the master.  When either party wants to talk, they should first read
//		the REQ line to see if it is high or low.  If it is high, they should pull it low.  The other party should constantly monitor the REQ line.  If it goes low
//		and they are ready, they should pull the ACK line low.  When the sender receives an ACK line low, it should send the data.  The receiver will receive this data
//		and then drop the ACK.  The sender will then drop the ACK and the bus is free again.

/*
Write addresses:
	Addr 0: remote mode
		Data for Addr 0:
		0: default	- output standard ADC_i,ADC_q, these have been through the RX front end block
		1: NCO		- output data from the internal sine wave generator for testing
		2: timing test - outputs a special packet for timing purposes
		3: counter	- outputs a timer for testing purposes
		4: all off 	- outputs all 1's
		5: all on	- outputs all 0's
		6: I/Q on/off - outputs 0 on I, 1 on Q
		7:	echo		- echos the next four words back over the bus
	
	Addr 1: remote_freq 1 - sets the NCO
		Data for Addr 1:
		7:0 - lower 8 bits of freq word
	Addr 2: remote_freq 2 - finishes setting the NCO
		Data for Addr 2:
		7:0 - upper 8 bits of freq word
	Addr 3: - echo 1
		Data for Addr 3:
		7:0 - I_lower
	Addr 4: - echo 2
		Data for Addr 4:
		7:0 - I_upper
	Addr 5: - echo 3
		Data for Addr 5:
		7:0 - Q_lower
	Addr 6: - echo 4
		Data for Addr 6:
		7:0 - Q_upper

*/
module master_data_bus(
    //clocking signals
	 input 					clk,
    input 					rst,
	 //bus signals
    inout		 [15:0]	bus,
    output					clk_out,
	 //input signals
	 input		 [7:0]	mode,
	 input		 [31:0]	echo,
	 input		 [15:0]	freq,
	 input		 [7:0]	testLengthLog,
	 //output signals
	 output	reg [31:0] threshold,
	 output	reg			threshold_stb,
	 output	reg [7:0]	fftLengthLog,
	 output	reg			fftLengthLog_stb,
	 output	reg [7:0]	fftAvg,
	 output	reg			fftAvg_stb
    );
	 
	 // incoming state machine variables
	 reg dataRdy;
	 reg [17:0] bus_in_dout_reg;
	 reg [1:0] incomingState;
	 
	 //fifo incoming signals
	 
	 reg 				bus_in_we;
	 reg 				bus_in_re;
	 wire  [17:0]	bus_in_din;
	 wire [17:0]	bus_in_dout;
	 (* KEEP = "TRUE" *) wire 			bus_in_full;
	 (* KEEP = "TRUE" *) wire 			bus_in_empty;
	 (* KEEP = "TRUE" *) wire [9:0] 	bus_in_data_count;
	 
	 //fifo outgoing signals
	 reg  [17:0]	bus_out_din;
	 reg 				bus_out_we;
	 reg 				bus_out_re;
	 wire [17:0]	bus_out_dout;
	 (* KEEP = "TRUE" *) wire 			bus_out_full;
	 (* KEEP = "TRUE" *) wire 			bus_out_empty;
	 (* KEEP = "TRUE" *) wire [9:0] 	bus_out_data_count;
	 
	 //change detection signals
	 reg mode_ack,echo_ack,freq_ack,testLengthLog_ack;
	 wire mode_chg,echo_chg,freq_chg,testLengthLog_chg;

	//generate the output clock for the bus.  100 MHz
	ODDR ODDR1 (
		.Q(clk_out),   // 1-bit DDR output
		.C(clk),   // 1-bit clock input
		.CE(1'b1), // 1-bit clock enable input
		.D1(1'b1), // 1-bit data input (positive edge)
		.D2(1'b0), // 1-bit data input (negative edge)
		.R(1'b0),   // 1-bit reset
		.S(1'b0)    // 1-bit set
		);

	//data going from the USRP to the ML605
	 bus_fifo incomingFifo (
		.clk(clk),
		.rst(rst),
		.din(bus_in_din), // Bus [17 : 0] 
		.wr_en(bus_in_we),
		.rd_en(bus_in_re),
		.dout(bus_in_dout), // Bus [17 : 0] 
		.full(bus_in_full),
		.empty(bus_in_empty),
		.data_count(bus_in_data_count) // Bus [9 : 0]	 
		);
		
	//data going from the ML605 to the USRP
	 bus_fifo outgoingFifo (
		.clk(clk),
		.rst(rst),
		.din(bus_out_din), // Bus [17 : 0] 
		.wr_en(bus_out_we),
		.rd_en(bus_out_re),
		.dout(bus_out_dout), // Bus [17 : 0] 
		.full(bus_out_full),
		.empty(bus_out_empty),
		.data_count(bus_out_data_count) // Bus [9 : 0]	 
		);
		
	changeDetect #(.WIDTH(8)) CD_mode(.clk(clk),.rst(rst),.register(mode),.chg(mode_chg),.ack(mode_ack));
	changeDetect #(.WIDTH(16)) CD_freq(.clk(clk),.rst(rst),.register(freq),.chg(freq_chg),.ack(freq_ack));
	changeDetect #(.WIDTH(32)) CD_echo(.clk(clk),.rst(rst),.register(echo),.chg(echo_chg),.ack(echo_ack));
	changeDetect #(.WIDTH(8)) CD_testLengthLog(.clk(clk),.rst(rst),.register(testLengthLog),.chg(testLengthLog_chg),.ack(testLengthLog_ack));

	reg [5:0] outgoingState;
	//enter data into the outgoing fifo
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			bus_out_din <= 18'd0;
			bus_out_we	<= 1'b0;
			outgoingState <= 6'd0;
			mode_ack <= 1'b0;
			echo_ack <= 1'b0;
			freq_ack <= 1'b0;
			testLengthLog_ack <= 1'b0;
		end
		else begin
			mode_ack <= 1'b0;
			echo_ack <= 1'b0;
			freq_ack <= 1'b0;
			testLengthLog_ack <= 1'b0;
			bus_out_we	<= 1'b0;
			case (outgoingState)
				6'd0: begin
					outgoingState <= outgoingState + 1'b1;
					if(mode_chg == 1'b1) begin
						bus_out_din <= {4'd0,6'd0,mode};
						mode_ack <= 1'b1;
						bus_out_we	<= 1'b1;
					end
				end
				6'd1: begin //freq is of length 2
					outgoingState <= outgoingState + 6'd2;
					if(freq_chg == 1'b1) begin
						bus_out_din <= {4'd0,6'd1,freq[7:0]};
						outgoingState <= outgoingState + 1'b1;
						bus_out_we	<= 1'b1;
					end
				end
				6'd2: begin
					outgoingState <= outgoingState + 1'b1;
					bus_out_din <= {4'd0,6'd2,freq[15:8]};
					bus_out_we	<= 1'b1;
					freq_ack <= 1'b1;					
				end
				6'd3: begin //echo is of length 4
					outgoingState <= outgoingState + 6'd4;
					if(echo_chg == 1'b1) begin
						bus_out_din <= {4'd0,6'd3,echo[7:0]};
						bus_out_we	<= 1'b1;
						outgoingState <= outgoingState + 1'b1;
					end
				end
				6'd4: begin
					outgoingState <= outgoingState + 1'b1;
					bus_out_din <= {4'd0,6'd4,echo[15:8]};
					bus_out_we	<= 1'b1;
				end
				6'd5: begin
					outgoingState <= outgoingState + 1'b1;
					bus_out_din <= {4'd0,6'd5,echo[23:16]};
					bus_out_we	<= 1'b1;
				end
				6'd6: begin
					outgoingState <= outgoingState + 1'b1;
					bus_out_din <= {4'd0,6'd6,echo[31:24]};
					bus_out_we	<= 1'b1;
					echo_ack <= 1'b1;
				end
				6'd7: begin
					outgoingState <= outgoingState + 1'b1;
					if(testLengthLog_chg == 1'b1) begin
						bus_out_din <= {4'd0,6'd7,testLengthLog[7:0]};
						bus_out_we	<= 1'b1;
						testLengthLog_ack <= 1'b1;
					end
				end
				6'd8: begin
					outgoingState <= 6'd0;
				end
				default: begin
					outgoingState <= 6'd0;
				end
			endcase
		end
	end
	
	//grab data from the incoming fifo
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
			//init incoming registers and strobes here
			threshold			<= 32'd0;
			threshold_stb		<= 1'b0;
			fftLengthLog		<= 8'd0;
			fftLengthLog_stb	<= 1'b0;
			fftAvg				<=	8'd0;
			fftAvg_stb			<= 1'b0;
		end
		else begin
			threshold_stb		<= 1'b0;
			fftLengthLog_stb	<= 1'b0;
			fftAvg_stb			<= 1'b0;
			if(dataRdy == 1'b1) begin
				case(bus_in_dout_reg[13:8])
					6'd0: begin
						threshold[7:0]		<= bus_in_dout_reg[7:0];
					end
					6'd1: begin
						threshold[15:8]	<= bus_in_dout_reg[7:0];
					end
					6'd2: begin
						threshold[23:16]	<= bus_in_dout_reg[7:0];
					end
					6'd3: begin
						threshold[31:24]	<= bus_in_dout_reg[7:0];
						threshold_stb		<= 1'b1;
					end
					6'd4: begin
						fftLengthLog[7:0] <= bus_in_dout_reg[7:0];
						fftLengthLog_stb	<= 1'b1;
					end
					6'd5: begin
						fftAvg[7:0]			<= bus_in_dout_reg[7:0];
						fftAvg_stb			<= 1'b1;
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
					hold			= 4'd4,
					ack_wait		= 4'd5,
					ack_wait2	= 4'd6,
					receive_data = 4'd7,
					wait_for_req = 4'd8;
	
	reg [16:0] watchCounter;
	reg watchFlag;
	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			watchCounter <= 16'd26;
		end
		else begin
			if(watchCounter > 16'd0) watchCounter <= watchCounter-1;
			if(watchFlag == 1'b1) watchCounter <= 16'd26;
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1'b1) begin
			state <= waiting;
			writeData <= 14'd0;
			REQflag <= 1'b0;
			REQVal <= 1'b1;
			bus_out_re <= 1'b0;
			bus_rnw <= 1'b1;
			ACKflag <= 1'b0;
			ACKVal <= 1'b1;
			bus_in_we <= 1'b0;
			watchFlag <= 1'b0;
		end
		else begin
			bus_out_re <= 1'b0;
			bus_rnw <= 1'b1;
			bus_in_we <= 1'b0;
			watchFlag <= 1'b0;
			case(state)
				waiting: begin
					REQflag <= 1'b0;
					ACKflag <= 1'b0;
					REQVal <= 1'b1;
					ACKVal <= 1'b1;
					watchFlag <= 1'b1;
					if(REQ_bus == 1'b0) begin //bus wants to write
						state <=ack_wait;
						ACKflag <= 1'b1;
						ACKVal <= 1'b0;
					end
					else begin //bus is available
						if(bus_out_empty == 1'b0) begin //data available for writing
							REQflag <= 1'b1;
							REQVal <= 1'b0; //pull down
							state <= wait_for_ack;
						end
					end
				end
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
				ack_wait: begin
					state <= ack_wait2;
				end
				ack_wait2: begin
					state <= receive_data;
				end
				receive_data: begin
					ACKflag <= 1'b1; //keep bus
					ACKVal <= 1'b1; //pullup
					bus_in_we <= 1'b1;
					state <= wait_for_req;
				end
				wait_for_req: begin
					if(REQ_bus == 1'b1) begin
						ACKflag <= 1'b0; //release bus
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
	assign REQ_bus = bus[15];
	assign ACK_bus = bus[14];

	//bidirectional bus assignment statements
	assign bus[13:0] = (bus_rnw)?14'bz:writeData; //if bus_rnw is 1, we read, if it is 0, we write
	assign bus[15] = (REQflag)?((REQVal)?1'b1:1'b0) :1'bz;
	assign bus[14] = (ACKflag)?((ACKVal)?1'b1:1'b0) :1'bz;
	assign bus_in_din[13:0] = (bus_rnw)?bus[13:0]:14'd0;

endmodule

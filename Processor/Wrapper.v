`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (
	input clk_100mhz,
	input BTNU,
	input JA3, input JA2, input JA1,
	output JA9, output JA8, output JA7, output JA4,
	output reg [1:0] LED,
	output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output [3:0] AN
	);

	wire clock, reset;
	assign clock = clk_30mhzActual;
	assign reset = BTNU;

	wire clk_30mhzActual;
	wire locked;
	clk_wiz_0 pll(
		.clk_out1(clk_30mhzActual),
		.reset(reset),
		.locked(locked),
		.clk_in1(clk_100mhz)
	);

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, memDataFinal;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "keypad_testing";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataFinal)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));



	//MMIO Registers that can be read by CPU:
									// for keypad
	wire [3:0] buttonPressed;	    // address 0

	wire [31:0] IOReadFinal;
	mux_16 #(32) IORead(.out(IOReadFinal), //read registers of IO devices
					.select(memAddr[3:0]), //memory addresses 0-15 are MMIO read
					.in0(buttonPressed), 
					.in1(32'b0), 
					.in2(32'b0), 
					.in3(32'b0), 
					.in4(32'b0),
					.in5(32'b0),
					.in6(32'b0),
					.in7(32'b0),
					.in8(32'b0),
					.in9(32'b0),
					.in10(32'b0),
					.in11(32'b0),
					.in12(32'b0),
					.in13(32'b0),
					.in14(32'b0),
					.in15(32'b0));
	assign memDataFinal = (memAddr > 15) ? memDataOut : IOReadFinal;



	//MMIO Registers that can be written by CPU:
	reg [31:0] sevenSegment0 = 0; 	  // address 18
	reg [31:0] sevenSegment1 = 0; 	  // address 19
	reg [31:0] sevenSegment2 = 0; 	  // address 20
	reg [31:0] sevenSegment3 = 0; 	  // address 21
	reg [31:0] defaultWrite = 0; 	  // address default

	always @(posedge clock) begin //write registers of IO devices
		if (memAddr < 32) begin //memory addresses 16-31 are MMIO write
			if (mwe) begin 
				case(memAddr[4:0])
					5'b10000: LED[0] <= memDataIn[0];
					5'b10001: LED[1] <= memDataIn[0];
					5'b10010: sevenSegment0 <= memDataIn;
					5'b10011: sevenSegment1 <= memDataIn;
					5'b10100: sevenSegment2 <= memDataIn;
					5'b10101: sevenSegment3 <= memDataIn;
					default: defaultWrite <= 0;
				endcase
			end 
		end
	end


	//KEYPAD STUFF
	reg [2:0] cols = 0;
	always @(negedge clock) begin
		cols <= {JA3, JA2, JA1};
	end

	wire [3:0] rows;
	assign {JA9, JA8, JA7, JA4} = rows;

	keypad KEYPAD(
		.cols(cols),
		.rows(rows),
		.clock(clock),
		.buttonPressed(buttonPressed));

	
	//SEVEN SEGMENT STUFF
	sevenSegment SEVENSEG(
		.number(sevenSegment0),
    	.CA(CA),
    	.CB(CB),
    	.CC(CC),
    	.CD(CD),
    	.CE(CE),
    	.CF(CF),
    	.CG(CG),
    	.DP(DP),
    	.AN(AN));



endmodule

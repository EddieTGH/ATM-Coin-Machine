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
	input JA3, input JA2, input JA1, //keypad pins
	output JA9, output JA8, output JA7, output JA4,
	input JB1, input JB2, input JB3, input JB4, //beam break pins
	//output reg [1:0] LED, //LED reg MAPPING
	output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output [7:0] AN,
    output [13:0] LED, //LED reg MAPPING
    output reg LED14,
    output reg LED15,
    input  SW0, //switches as SERVO input
    output JC1, JC2, JC3, JC4, //Servo PWM signal 
	output JD1, JD2, JD3, JD4 //LEDs for state
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
	localparam INSTR_FILE = "ATM_main";
	
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
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB)); // LED Reg MAPPING
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));



	//MMIO Registers that can be read by CPU:
									// for keypad
	wire [3:0] buttonPressed;	    // address 0
	wire beamBroken1, beamBroken5, beamBroken10, beamBroken25; //address 1,2,3,4
	wire servo1BackDone, servo5BackDone, servo10BackDone, servo25BackDone; //address 5, 6, 7, 8 DEFAULT = 1
	wire servo1FrontDone, servo5FrontDone, servo10FrontDone, servo25FrontDone; //address 9, 10, 11, 12 DEFAULT = 1

	wire [31:0] IOReadFinal;
	mux_16 #(32) IORead(.out(IOReadFinal), //read registers of IO devices
					.select(memAddr[3:0]), //memory addresses 0-15 are MMIO read
					.in0(buttonPressed), //lw from memory 0
					.in1(beamBroken1),   //lw from memory 1
					.in2(beamBroken5),   //lw from memory 2
					.in3(beamBroken10),  //lw from memory 3
					.in4(beamBroken25),  //lw from memory 4
					.in5(servo1BackDone), //lw from memory 5
					.in6(servo5BackDone), //lw from memory 6
					.in7(servo10BackDone), //lw from memory 7
					.in8(servo25BackDone), //lw from memory 8
					.in9(servo1FrontDone), //lw from memory 9
					.in10(servo5FrontDone), //lw from memory 10
					.in11(servo10FrontDone), //lw from memory 11
					.in12(servo25FrontDone), //lw from memory 12
					.in13(32'b0),
					.in14(32'b0),
					.in15(32'b0)); 
	assign memDataFinal = (memAddr > 15) ? memDataOut : IOReadFinal;



	//MMIO Registers that can be written by CPU:
	reg [31:0] sevenSegment0 = 0; 	  // address 18
	reg [31:0] sevenSegment1 = 0; 	  // address 19
	reg [31:0] sevenSegment2 = 0; 	  // address 20
	reg [31:0] sevenSegment3 = 0; 	  // address 21
	reg [31:0] acknowledgeKey = 0;    // address 22
	reg [31:0] servoControl_1 = 0;    // address 23
	reg [31:0] servoControl_5 = 0;    // address 24
	reg [31:0] servoControl_10 = 0;    // address 25
	reg [31:0] servoControl_25 = 0;    // address 26
	reg [31:0] acknowledgeBeam = 0;   // address 27
	reg LEDState1EnterPin = 0;		  //address 28
	reg LEDState2ChooseDepWith = 0;		  //address 29
	reg LEDState3DepCoins = 0;		  //address 30
	reg LEDState4EnterWithAmt = 0;		  //address 31

	reg [31:0] defaultWrite = 0; 	  // address default

	assign JD1 = LEDState1EnterPin;
	assign JD2 = LEDState2ChooseDepWith;
	assign JD3 = LEDState3DepCoins;
	assign JD4 = LEDState4EnterWithAmt;

	always @(posedge clock) begin //write registers of IO devices
		if (memAddr < 64) begin //memory addresses 16-64 are MMIO write
			if (mwe) begin 
				case(memAddr[5:0])
					6'b010000: LED14 <= memDataIn[0];                 //LED reg MAPPING sw LED val to memory 16
					6'b010001: LED15 <= memDataIn[0];                 //LED reg MAPPING sw LED val to memory 17
					6'b010010: sevenSegment0 <= memDataIn;              //1st digit sw digit val to memory 18
					6'b010011: sevenSegment1 <= memDataIn;              //2nd digit sw digit val to memory 19
					6'b010100: sevenSegment2 <= memDataIn;              //3rd digit sw digit val to memory 20
					6'b010101: sevenSegment3 <= memDataIn;              //4th digit sw digit val to memory 21
					6'b010110: acknowledgeKey <= memDataIn;              //acknowlege keypad press memory 22
					6'b010111: servoControl_1 <= memDataIn;              //1st servo control sw ctrl val to memory 23
					6'b011000: servoControl_5 <= memDataIn;              //1st servo control sw ctrl val to memory 24
					6'b011001: servoControl_10 <= memDataIn;              //1st servo control sw ctrl val to memory 25
					6'b011010: servoControl_25 <= memDataIn;              //1st servo control sw ctrl val to memory 26
					6'b011011: acknowledgeBeam <= memDataIn;              //acknowledge beam break sensor memory 27
					6'b011100: LEDState1EnterPin <= memDataIn[0];              //memory 28
					6'b011101: LEDState2ChooseDepWith <= memDataIn[0];         //memory 29
					6'b011110: LEDState3DepCoins <= memDataIn[0];              //memory 30
					6'b011111: LEDState4EnterWithAmt <= memDataIn[0];          //memory 31
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
		.buttonPressed(buttonPressed),
		.acknowledgeKey(acknowledgeKey),
		.LED(LED[9:0]));

	
	//SEVEN SEGMENT STUFF
	sevenSegment SEVENSEG(
		.seg0(sevenSegment0),
		.seg1(sevenSegment1),
		.seg2(sevenSegment2),
    	.seg3(sevenSegment3),
    	.CA(CA),
    	.CB(CB),
    	.CC(CC),
    	.CD(CD),
    	.CE(CE),
    	.CF(CF),
    	.CG(CG),
    	.DP(DP),
    	.AN(AN),
		.clock(clock));
    
    //SERVO STUFF
    wire clear;
    assign clear = 1'b0;
    Servo_interface servo1 (.servoCtrl(servoControl_1), .clr(clear), .clk(clock), .JC_Signal(JC1), .servoBackDone(servo1BackDone), .servoFrontDone(servo1FrontDone) );
    Servo_interface_2 servo5 (.servoCtrl(servoControl_5), .clr(clear), .clk(clock), .JC_Signal(JC2), .servoBackDone(servo5BackDone), .servoFrontDone(servo5FrontDone) );
    Servo_interface servo10 (.servoCtrl(servoControl_10), .clr(clear), .clk(clock), .JC_Signal(JC3), .servoBackDone(servo10BackDone), .servoFrontDone(servo10FrontDone) );
    Servo_interface servo25 (.servoCtrl(servoControl_25), .clr(clear), .clk(clock), .JC_Signal(JC4), .servoBackDone(servo25BackDone), .servoFrontDone(servo25FrontDone) );
    //Servo_interface servo1 (.SW(SW0), .clr(clear), .clk(clock), .JC_Signal(JC1) );


	//BEAM BREAK STUFF
	
	beamBreak BEAMBREAK0(
		.beamBroken1(beamBroken1),
		.reading1(JB1), //penny
		.beamBroken2(beamBroken5),
		.reading2(JB2), //nickel
		.beamBroken3(beamBroken10),
		.reading3(JB3), //dime
		.beamBroken4(beamBroken25),
		.reading4(JB4), //quarter
		.clock(clock),
		.acknowledgeBeam(acknowledgeBeam),
		.LED(LED[13:10]));



endmodule


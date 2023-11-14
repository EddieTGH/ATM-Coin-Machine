/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    //Fetch Variables
    wire [31:0] IR_Fetch_Final;
    wire [31:0] PC_incremented;
    wire [31:0] PC_out;
    wire [31:0] PC_Next_Final;
    wire stallPC;
    wire stallFD;

    //Decode Variables
    wire [31:0] PC_Decode;
    wire [31:0] IR_Decode_Initial;
    wire [31:0] IR_Decode_Final;
    wire [9:0] dC_Decode;
    wire [10:0] xC_Decode;
    wire mC_Decode;
    wire [4:0] wC_Decode;

    wire shouldFlush;

    wire stallDX;
    wire nopDX;

    //Execute variables
    wire [31:0] PC_Execute;
    wire [31:0] IR_Execute;
    wire [10:0] xC_Execute;
    wire mC_Execute;
    wire [4:0] wC_Execute;
    wire [4:0] wC_Execute_Final;
    wire [31:0] O_Execute;
    wire [31:0] B_Execute_Initial;
    wire [31:0] A_Execute_Initial;

    wire [31:0] signExtendedImm;
    wire [31:0] A_Execute_Bypassed, B_Execute_Bypassed, B_Execute_Bypassed1;
    wire weirdCond;

    wire [31:0] ALU_A_Final, ALU_B_Final;
    wire [31:0] ALU_out;
    wire ALU_overflow;
    wire ALU_isNotEqual, ALU_isLessThan;
    wire [31:0] exception_rstatus;
    wire [31:0] exception_rstatusOrALUout;
    wire [31:0] rstatus_orALUout;

    wire [31:0] branch_Next_PC;
    wire [31:0] execute_Next_PC;
    wire select_execute_Next_PC;

    wire isMult, isDiv, isMultDffe, isDivDffe;
    wire ctrl_MULT, ctrl_DIV;
    wire [31:0] multdivResult;
    wire multdivException, multdivResultRDY;
    wire [31:0] P_Final, P_Final_Almost;

    wire [1:0] A_Bypass_Selector, B_Bypass_Selector;

    //Memory variables
    wire [31:0] IR_Memory;
    wire mC_Memory;
    wire [4:0] wC_Memory;
    wire [31:0] O_Memory;
    wire [31:0] B_Memory;
    wire data_dmem_bypass;

    //Writeback variables
    wire [31:0] IR_Writeback;
    wire [31:0] IR_Writeback_Multdiv;
    wire [4:0] wC_Writeback;
    wire [31:0] O_Writeback;
    wire [31:0] D_Writeback;
    wire [31:0] P_Writeback_Multdiv;
    wire multdivException_Writeback;

    wire [4:0] final_ctrlWriteReg1;
    wire [4:0] final_ctrlWriteReg2;
    wire [4:0] final_ctrlWriteReg3;
    wire [4:0] final_ctrlWriteRegMultdiv;
    wire [31:0] final_dataWriteReg;
    wire [31:0] final_dataWriteReg1;


    //CPU with pipelining
    assign PC_Next_Final = select_execute_Next_PC ? execute_Next_PC : PC_incremented; //determine next PC (regular, branch, jump, etc)
    register_32_falling ProgramCounter(.data_writeReg(PC_Next_Final), .data_readReg(PC_out), .clk(clock), .write_enable(~stallPC), .reset(reset));
    pcPlus1 PCPLUS1(.pc(PC_out), .pcIncremented(PC_incremented));

    assign address_imem = PC_out;
    assign IR_Fetch_Final = shouldFlush ? 32'b0 : q_imem;

    FDLatch FDLATCH(.PC_in(PC_incremented), .PC_out(PC_Decode), .IR_in(IR_Fetch_Final), .IR_out(IR_Decode_Initial), .clk(clock), .write_enable(~stallFD), .reset(reset));

    control CONTROLUNIT(.instruction(IR_Decode_Final), .decode_Control(dC_Decode), .execute_Control(xC_Decode), .memory_Control(mC_Decode), .writeback_Control(wC_Decode));
    assign ctrl_writeReg = final_ctrlWriteReg3;
    assign data_writeReg = final_dataWriteReg;
    assign ctrl_writeEnable = wC_Writeback[0] | multdivResultRDY; //write enable regfile based on bit 0 of writeback stage wC
    assign ctrl_readRegA = dC_Decode[9:5];
    assign ctrl_readRegB = dC_Decode[4:0];

    assign shouldFlush = select_execute_Next_PC;
    assign IR_Decode_Final = (shouldFlush | nopDX) ? 32'b0 : IR_Decode_Initial; 

    stallUnit STALLUNIT(.IR_Decode(IR_Decode_Initial), .IR_Execute(IR_Execute), .wC_Execute(wC_Execute), .xC_Decode(xC_Decode), .isMult(isMult), .isDiv(isDiv), .multdivReady(multdivResultRDY), .stallPC(stallPC), .stallFD(stallFD), .stallDX(stallDX), .nopDX(nopDX));

    DXLatch DXLATCH(.PC_in(PC_Decode), .PC_out(PC_Execute), .IR_in(IR_Decode_Final), .IR_out(IR_Execute), .A_in(data_readRegA), .A_out(A_Execute_Initial), .B_in(data_readRegB), .B_out(B_Execute_Initial), .xC_in(xC_Decode), .xC_out(xC_Execute), .mC_in(mC_Decode), .mC_out(mC_Execute), .wC_in(wC_Decode), .wC_out(wC_Execute), .clk(clock), .write_enable(~stallDX), .reset(reset));

    A_execute_bypass ABYPASSUNIT(.IR_Execute(IR_Execute), .IR_Memory(IR_Memory), .IR_Writeback(IR_Writeback), .wC_Memory(wC_Memory), .ctrl_writeEnable(ctrl_writeEnable), .final_ctrlWriteReg(final_ctrlWriteReg3), .out(A_Bypass_Selector));
    mux_4 #(32) ABYPASSMUX(.out(A_Execute_Bypassed), .select(A_Bypass_Selector), .in0(A_Execute_Initial), .in1(O_Memory), .in2(final_dataWriteReg), .in3(O_Memory));
    
    B_execute_bypass BBYPASSUNIT(.IR_Execute(IR_Execute), .IR_Memory(IR_Memory), .IR_Writeback(IR_Writeback), .xC_Execute(xC_Execute), .mC_Execute(mC_Execute), .wC_Memory(wC_Memory), .ctrl_writeEnable(ctrl_writeEnable), .final_ctrlWriteReg(final_ctrlWriteReg3), .out(B_Bypass_Selector));
    mux_4 #(32) BBYPASSMUX(.out(B_Execute_Bypassed1), .select(B_Bypass_Selector), .in0(B_Execute_Initial), .in1(O_Memory), .in2(final_dataWriteReg), .in3(O_Memory));
    assign weirdCond = (((xC_Execute[5] & (IR_Memory[26:22] === 5'b11110)) | (xC_Execute[4] & (IR_Memory[26:22] === IR_Execute[26:22]))) & (wC_Memory[1]) & ((~B_Bypass_Selector[1] & B_Bypass_Selector[0]) | (B_Bypass_Selector[1] & B_Bypass_Selector[0])));
    assign B_Execute_Bypassed = weirdCond ? q_dmem : B_Execute_Bypassed1;


    assign signExtendedImm = {{15{IR_Execute[16]}}, IR_Execute[16:0]}; //sign extend potential immediate bits

    assign ALU_A_Final = A_Execute_Bypassed; 
    assign ALU_B_Final = xC_Execute[0] ? signExtendedImm : B_Execute_Bypassed; //choose sign extended immediate or B register (bypassed if needed)
    alu ALU(.data_operandA(ALU_A_Final), .data_operandB(ALU_B_Final), .ctrl_ALUopcode(xC_Execute[10:6]), .ctrl_shiftamt(IR_Execute[11:7]), .data_result(ALU_out), .isNotEqual(ALU_isNotEqual), .isLessThan(ALU_isLessThan), .overflow(ALU_overflow));

    get_Exception_rstatus potential_rstatus(.instruction(IR_Execute), .exception_rstatus(exception_rstatus));
    assign exception_rstatusOrALUout = ALU_overflow ? exception_rstatus : ALU_out;
    assign wC_Execute_Final[3:0] = wC_Execute[3:0]; //necessary because in the line below we may have to change wC_Execute bit 4
    assign wC_Execute_Final[4] = ALU_overflow ? ~wC_Execute[4] : wC_Execute[4]; //if ALU Overflow, set exception during execute stage bit high

    assign rstatus_orALUout = wC_Execute[2] ? {5'b0, IR_Execute[26:0]} : exception_rstatusOrALUout; //if setx = 1, assign T of J1 type
    assign O_Execute = xC_Execute[3] ? PC_Execute : rstatus_orALUout; //if jal (or j, but dont care if j), assign PC + 1 to move forward as O
    
    pcPlus1PlusN PCPLUS1PLUSN(.pc(PC_Execute), .N(signExtendedImm), .pcIncrementedPlusN(branch_Next_PC));
    executeDetNextPC EXECUTEDETNEXTPC(.xC_Execute(xC_Execute), .branch_Next_PC(branch_Next_PC), .ALU_isLessThan(ALU_isLessThan), .ALU_isNotEqual(ALU_isNotEqual), .target(IR_Execute[26:0]), .rd_rstatus(B_Execute_Bypassed), .execute_Next_PC(execute_Next_PC), .select_execute_Next_PC(select_execute_Next_PC));

    XMLatch XMLATCH(.IR_in(IR_Execute), .IR_out(IR_Memory), .O_in(O_Execute), .O_out(O_Memory), .B_in(B_Execute_Bypassed), .B_out(B_Memory), .mC_in(mC_Execute), .mC_out(mC_Memory), .wC_in(wC_Execute_Final), .wC_out(wC_Memory), .clk(clock), .write_enable(1'b1), .reset(reset));
    assign wren = mC_Memory; //write enable for data memory
    assign address_dmem = O_Memory; //address to write to dmem

    data_mem_d_bypass MWBYPASSUNIT(.IR_Memory(IR_Memory), .ctrl_writeEnable(ctrl_writeEnable), .final_ctrlWriteReg(final_ctrlWriteReg3), .wC_Writeback(wC_Writeback), .out(data_dmem_bypass)); //MW bypassing for data input to data mem
    assign data = data_dmem_bypass ? final_dataWriteReg : B_Memory; //data to write to dmem

    MWLatch MWLATCH(.IR_in(IR_Memory), .IR_out(IR_Writeback), .O_in(O_Memory), .O_out(O_Writeback), .D_in(q_dmem), .D_out(D_Writeback), .wC_in(wC_Memory), .wC_out(wC_Writeback), .clk(clock), .write_enable(1'b1), .reset(reset));
    
    assign final_ctrlWriteRegMultdiv = multdivException_Writeback ? 5'b11110 : IR_Writeback_Multdiv[26:22]; //rstatus or rd
    assign final_ctrlWriteReg1 = (wC_Writeback[4] | wC_Writeback[2]) ? 5'b11110 : IR_Writeback[26:22];  //rstatus or rd
	assign final_ctrlWriteReg2 = wC_Writeback[3] ? 5'b11111 : final_ctrlWriteReg1; //r31 or rstatus/rd
    assign final_ctrlWriteReg3 = multdivResultRDY ? final_ctrlWriteRegMultdiv : final_ctrlWriteReg2; //multdiv or not multdiv
    
    assign final_dataWriteReg1 = wC_Writeback[1] ? D_Writeback : O_Writeback; //1 if choose data mem for writeback
    assign final_dataWriteReg = (multdivResultRDY | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (~IR_Writeback[2])) | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (IR_Writeback[2]))) ? P_Writeback_Multdiv : final_dataWriteReg1;


    //Multiplier stuff below
    assign isMult = (~(|IR_Execute[31:27])) & (~IR_Execute[6]) & (~IR_Execute[5]) & (IR_Execute[4]) & (IR_Execute[3]) & (~IR_Execute[2]);
    assign isDiv = (~(|IR_Execute[31:27])) & (~IR_Execute[6]) & (~IR_Execute[5]) & (IR_Execute[4]) & (IR_Execute[3]) & (IR_Execute[2]);

    dffe_ref_falling MULTDFFE(.q(isMultDffe), .d(isMult), .clk(clock), .en(1'b1), .clr(multdivResultRDY));
    assign ctrl_MULT = (~isMultDffe) & isMult;
    dffe_ref_falling DIVDFFE(.q(isDivDffe), .d(isDiv), .clk(clock), .en(1'b1), .clr(multdivResultRDY));
    assign ctrl_DIV = (~isDivDffe) & isDiv;

    multdiv MULTDIVUNIT(.data_operandA(A_Execute_Bypassed), .data_operandB(B_Execute_Bypassed), .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), .clock(clock), .data_result(multdivResult), .data_exception(multdivException), .data_resultRDY(multdivResultRDY));

    assign P_Final_Almost = (multdivException & isMult) ? 32'b100 : multdivResult;
    assign P_Final = (multdivException & isDiv) ? 32'b101 : P_Final_Almost;
    PWLatch PWLATCH(.IR_in(IR_Execute), .IR_out(IR_Writeback_Multdiv), .P_in(P_Final), .P_out(P_Writeback_Multdiv), .multdivException_in(multdivException), .multdivException_out(multdivException_Writeback), .clk(clock), .write_enable(multdivResultRDY), .reset(reset));
    
	/* END CODE */

endmodule

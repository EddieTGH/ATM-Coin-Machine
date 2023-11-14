module control(instruction, decode_Control, execute_Control, memory_Control, writeback_Control);
    input [31:0] instruction;
    output [9:0] decode_Control;
    output [10:0] execute_Control;
    output memory_Control;
    output [4:0] writeback_Control;

    //If Instruction is NOP, set control signals to all be 0

    //dC, xC, mC, and wC bit structures:
    //dC: Bit 9-5 = ctrl_readRegA; Bit 4-0 = ctrl_readRegB;
    //xC: Bit 10-6 = ALUOP; Bit 5 = bex jump; Bit 4 = jr jump; Bit 3 = j or jal jump; Bit 2 = bne jump; Bit 1 = blt jump; Bit 0 = choose sx immediate as ALU input;
    //mC: Bit 0 = data memory write enable;
    //wC: Bit 4 = exception during execute; Bit 3 = jal; Bit 2 = setx; Bit 1 = select data mem for writeback; Bit 0 = regfile write enable;

    wire [31:0] opcode_Decode;
    decoder_32 OPCODEDECODE(.select(instruction[31:27]), .enable(1'b1), .out(opcode_Decode));

    wire isMult, isDiv;
    assign isMult = (~instruction[6]) & (~instruction[5]) & (instruction[4]) & (instruction[3]) & (~instruction[2]);
    assign isDiv = (~instruction[6]) & (~instruction[5]) & (instruction[4]) & (instruction[3]) & (instruction[2]);

    //dC Control assignment
    wire funcIsALUOP;
    assign funcIsALUOP = opcode_Decode[0];

    wire [4:0] rtOrRd;
    assign decode_Control[9:5] = instruction[21:17]; //always assign ctrl_readRegA to be rs when relevant
    assign rtOrRd = funcIsALUOP ? instruction[16:12] : instruction[26:22]; //choose if R type (need rt) or I/J type (need rd) for ctrl_readRegB
    assign decode_Control[4:0] = opcode_Decode[22] ? 5'b11110 : rtOrRd; //if bex, ctrl_readRegB should be $rstatus. Else, either rt or rd.


    //xC control assignment
    wire chooseSubALUOP; //Non zero opcode but still want subtraction ALUOP. If zero, will have addition ALUOP.
    assign chooseSubALUOP = opcode_Decode[2] | opcode_Decode[6]; //BNE or BLT

    assign execute_Control[10:6] = funcIsALUOP ? instruction[6:2] : {4'b0, chooseSubALUOP}; //ALUOP, if not in func and don't want sub it defaults to add ALUOP
    assign execute_Control[5] = opcode_Decode[22]; //bex
    assign execute_Control[4] = opcode_Decode[4]; //jr
    assign execute_Control[3] = opcode_Decode[1] | opcode_Decode[3]; //j or jal
    assign execute_Control[2] = opcode_Decode[2]; //BNE
    assign execute_Control[1] = opcode_Decode[6]; //BLT
    assign execute_Control[0] = opcode_Decode[5] | opcode_Decode[7] | opcode_Decode[8]; //choose sx immediate as ALU input, addi or sw or lw


    //mC control assignment
    assign memory_Control = opcode_Decode[7]; //data memory write enable, sw

    //wC control assignment
    assign writeback_Control[4] = 1'b0; //exception during execute stage, initialize as 0
    assign writeback_Control[3] = opcode_Decode[3]; //jal
    assign writeback_Control[2] = opcode_Decode[21]; //setx
    assign writeback_Control[1] = opcode_Decode[8]; //select data mem for writeback, lw
    assign writeback_Control[0] = (opcode_Decode[0] & (~isMult) & (~isDiv)) | opcode_Decode[5]| opcode_Decode[8] | opcode_Decode[21] | opcode_Decode[3]; //regfile write enable, ALUOP, addi, lw, setx, jal
endmodule
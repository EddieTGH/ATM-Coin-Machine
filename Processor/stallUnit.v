module stallUnit(IR_Decode, IR_Execute, wC_Execute, xC_Decode, isMult, isDiv, multdivReady, stallPC, stallFD, stallDX, nopDX);
    input [31:0] IR_Decode, IR_Execute;
    input isMult, isDiv, multdivReady;
    input [4:0] wC_Execute;
    input [10:0] xC_Decode;
    output stallPC, stallFD, stallDX, nopDX;

    wire stallCond;
    assign stallCond = wC_Execute[1] & ((IR_Decode[21:17] === IR_Execute[26:22]) | ((IR_Decode[26:22] === IR_Execute[26:22])) | ((IR_Decode[16:12] === IR_Execute[26:22])));
    //assign stallCond = wC_Execute[1] & ((IR_Decode[21:17] === IR_Execute[26:22]) | ((IR_Decode[26:22] === IR_Execute[26:22]) & (xC_Decode[2] | xC_Decode[1])) | ((IR_Decode[16:12] === IR_Execute[26:22]) & ~(|IR_Decode[31:27])));
    //| (xC_Decode[5] & (IR_Execute[26:22] === 5'b11110)) | (xC_Decode[4] & (IR_Execute[26:22] === IR_Decode[26:22]))
    //assign stallCond = 1'b0;
    assign stallPC = (((isMult | isDiv) & (~multdivReady)) | stallCond) ? 1'b1 : 1'b0;
    assign stallFD = (((isMult | isDiv) & (~multdivReady)) | stallCond) ? 1'b1 : 1'b0;
    assign stallDX = ((isMult | isDiv) & (~multdivReady)) ? 1'b1 : 1'b0;
    assign nopDX = stallCond; //should we insert nop to dx latch if stall due to load output to ALU input

endmodule
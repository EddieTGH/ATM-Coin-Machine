module B_execute_bypass(IR_Execute, IR_Memory, IR_Writeback, xC_Execute, mC_Execute, wC_Memory, ctrl_writeEnable, final_ctrlWriteReg, out);
input [31:0] IR_Execute, IR_Memory, IR_Writeback;
input [10:0] xC_Execute;
input [4:0] wC_Memory, wC_Writeback, final_ctrlWriteReg;
input ctrl_writeEnable, mC_Execute;
output [1:0] out;

wire out1, out2, i1;
assign i1 = mC_Execute | xC_Execute[4] | xC_Execute[2] | xC_Execute[1] | xC_Execute[5]; //sw or jr or bne or blt or bext
assign out2 = ((IR_Execute[26:22] === final_ctrlWriteReg) & (|final_ctrlWriteReg) & (i1)) ? 1'b1 : 1'b0; 
assign out1 = ((IR_Execute[16:12] === final_ctrlWriteReg) & (|final_ctrlWriteReg) & (~i1)) ? 1'b1 : out2; //also making sure not reg 0
assign out[1] = (ctrl_writeEnable | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (~IR_Writeback[2])) | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (IR_Writeback[2]))) ? out1 : 1'b0; //bypass from writeback stage

wire out1a, out2a;
assign out2a = (~wC_Memory[4] & (((IR_Execute[16:12] === IR_Memory[26:22]) & (|IR_Execute[16:12]) & ~i1) | ((IR_Execute[26:22] === IR_Memory[26:22]) & (|IR_Execute[26:22]) & i1))) ? 1'b1 : 1'b0; //also making sure not reg 0
assign out1a = (wC_Memory[4] & (((IR_Execute[16:12] === 5'b11110) & ~i1) | ((IR_Execute[26:22] === 5'b11110) & i1))) ? 1'b1 : out2a;
assign out[0] = wC_Memory[0] ? out1a : 1'b0; //bypass from memory stage

//if both out[1] and out[0] are on, memory stage bypass should take precedence (4th mux input)
endmodule
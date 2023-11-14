module A_execute_bypass(IR_Execute, IR_Memory, IR_Writeback, wC_Memory, ctrl_writeEnable, final_ctrlWriteReg, out);
input [31:0] IR_Execute, IR_Memory, IR_Writeback;
input [4:0] wC_Memory, wC_Writeback, final_ctrlWriteReg;
input ctrl_writeEnable;
output [1:0] out;

wire out1;

assign out1 = ((IR_Execute[21:17] === final_ctrlWriteReg) & (|final_ctrlWriteReg)) ? 1'b1 : 1'b0; //also making sure not reg 0
assign out[1] = (ctrl_writeEnable | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (~IR_Writeback[2])) | (~(|IR_Writeback[31:27]) & (~IR_Writeback[6]) & (~IR_Writeback[5]) & (IR_Writeback[4]) & (IR_Writeback[3]) & (IR_Writeback[2]))) ? out1 : 1'b0; //bypass from writeback stage

wire out1a, out2a;
assign out2a = (~wC_Memory[4] & (IR_Execute[21:17] === IR_Memory[26:22]) & (|IR_Execute[21:17])) ? 1'b1 : 1'b0; //also making sure not reg 0
assign out1a = (wC_Memory[4] & (IR_Execute[21:17] === 5'b11110)) ? 1'b1 : out2a;
assign out[0] = wC_Memory[0] ? out1a : 1'b0; //bypass from memory stage

//if both out[1] and out[0] are on, memory stage bypass should take precedence (4th mux input)
endmodule
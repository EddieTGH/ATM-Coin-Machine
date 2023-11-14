module data_mem_d_bypass(IR_Memory, ctrl_writeEnable, final_ctrlWriteReg, wC_Writeback, out);
    input [31:0] IR_Memory;
    input [4:0] final_ctrlWriteReg, wC_Writeback;
    input ctrl_writeEnable;
    output out;

    //if lw in writeback and sw in memory (rd = rd), or if some add type in writeback and sw in memory (rd = rd)
    //ultimately: if rd in writeback and write enable in writeback, and rd_writeback = rd_memory and sw
    //2 edge cases: Jal and setx both have write enable and are j1. also exceptions
        //Dont want for jal. 
        //
    wire out1, out2;

    assign out2 = (IR_Memory[26:22] === final_ctrlWriteReg) ? 1'b1 : 1'b0;
    assign out1 = ctrl_writeEnable ? out2 : 1'b0; //regfile write enable is on
    assign out = wC_Writeback[3] ? 1'b0 : out1; //if jal don't want mw bypass

endmodule
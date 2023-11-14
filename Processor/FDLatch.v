module FDLatch(PC_in, PC_out, IR_in, IR_out, clk, write_enable, reset);
    input clk, write_enable, reset;
    input [31:0] PC_in, IR_in;
    output [31:0] PC_out, IR_out;
    
    register_32_falling PC(.data_writeReg(PC_in), .data_readReg(PC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling instruction(.data_writeReg(IR_in), .data_readReg(IR_out), .clk(clk), .write_enable(write_enable), .reset(reset));
endmodule
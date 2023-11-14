module DXLatch(PC_in, PC_out, IR_in, IR_out, A_in, A_out, B_in, B_out, xC_in, xC_out, mC_in, mC_out, wC_in, wC_out, clk, write_enable, reset);
    input clk, write_enable, reset;
    input [31:0] PC_in, IR_in, A_in, B_in;
    output [31:0] PC_out, IR_out, A_out, B_out;

    input [10:0] xC_in;
    input mC_in;
    input [4:0] wC_in;
    output [10:0] xC_out;
    output mC_out;
    output [4:0] wC_out;
    
    register_32_falling PC(.data_writeReg(PC_in), .data_readReg(PC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling instruction(.data_writeReg(IR_in), .data_readReg(IR_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling A(.data_writeReg(A_in), .data_readReg(A_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling B(.data_writeReg(B_in), .data_readReg(B_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(11) xC(.data_writeReg(xC_in), .data_readReg(xC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(1) mC(.data_writeReg(mC_in), .data_readReg(mC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(5) wC(.data_writeReg(wC_in), .data_readReg(wC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
endmodule
module XMLatch(IR_in, IR_out, O_in, O_out, B_in, B_out, mC_in, mC_out, wC_in, wC_out, clk, write_enable, reset);
    input clk, write_enable, reset;
    input [31:0] IR_in, O_in, B_in;
    output [31:0] IR_out, O_out, B_out;

    input mC_in;
    input [4:0] wC_in;
    output mC_out;
    output [4:0] wC_out;
    
    register_32_falling instruction(.data_writeReg(IR_in), .data_readReg(IR_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling O(.data_writeReg(O_in), .data_readReg(O_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling B(.data_writeReg(B_in), .data_readReg(B_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(1) mC(.data_writeReg(mC_in), .data_readReg(mC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(5) wC(.data_writeReg(wC_in), .data_readReg(wC_out), .clk(clk), .write_enable(write_enable), .reset(reset));
endmodule
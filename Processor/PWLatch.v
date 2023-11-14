module PWLatch(IR_in, IR_out, P_in, P_out, multdivException_in, multdivException_out, clk, write_enable, reset);
    input clk, write_enable, reset;
    input [31:0] IR_in, P_in;
    input multdivException_in;
    output [31:0] IR_out, P_out;
    output multdivException_out;

    register_32_falling instruction(.data_writeReg(IR_in), .data_readReg(IR_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_32_falling P(.data_writeReg(P_in), .data_readReg(P_out), .clk(clk), .write_enable(write_enable), .reset(reset));
    register_variable_falling #(1) exception(.data_writeReg(multdivException_in), .data_readReg(multdivException_out), .clk(clk), .write_enable(write_enable), .reset(reset));

endmodule
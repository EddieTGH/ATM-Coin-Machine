module register_32_falling(data_writeReg, data_readReg, clk, write_enable, reset);
    input clk, reset, write_enable;
    input [31:0] data_writeReg;
    output [31:0] data_readReg;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            dffe_ref_falling DFF(.q(data_readReg[i]), .d(data_writeReg[i]), .clk(clk), .en(write_enable), .clr(reset));
        end
    endgenerate
endmodule
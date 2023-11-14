module register_regfile(data_writeReg, data_readReg, clk, write_enable, decode_result, reset);
    input clk, reset, write_enable, decode_result;
    input [31:0] data_writeReg;
    output [31:0] data_readReg;

    wire en;
    and AND1(en, write_enable, decode_result);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            dffe_ref DFF(.q(data_readReg[i]), .d(data_writeReg[i]), .clk(clk), .en(en), .clr(reset));
        end
    endgenerate
endmodule
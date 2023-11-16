module register_variable_falling #(parameter WIDTH=1)(data_writeReg, data_readReg, clk, write_enable, reset);
    input clk, reset, write_enable;
    input [WIDTH-1:0] data_writeReg;
    output [WIDTH-1:0] data_readReg;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            dffe_ref_falling DFF(.q(data_readReg[i]), .d(data_writeReg[i]), .clk(clk), .en(write_enable), .clr(reset));
        end
    endgenerate
endmodule
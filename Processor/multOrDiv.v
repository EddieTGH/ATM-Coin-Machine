module multOrDiv(ctrl_MULT, ctrl_DIV, out, clock, enable, clear);
    input ctrl_MULT, ctrl_DIV, clock, enable, clear;
    output [1:0] out;

    dffe_ref_sync DFF1(.q(out[0]), .d(ctrl_MULT), .clk(clock), .en(enable), .clr(clear));
    dffe_ref_sync DFF2(.q(out[1]), .d(ctrl_DIV), .clk(clock), .en(enable), .clr(clear));
endmodule
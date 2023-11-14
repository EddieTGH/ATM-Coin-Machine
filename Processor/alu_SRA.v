module alu_SRA(A, out, ctrl_shiftamt);
    input [31:0] A;
    input [4:0] ctrl_shiftamt;
    output [31:0] out;

    wire [31:0] w1, w2;
    alu_SRA_Bit #(16) RIGHT1(.A(A), .out(w1));
    mux_2 #(32) DORIGHT1(.out(w2), .select(ctrl_shiftamt[4]), .in0(A), .in1(w1));

    wire [31:0] w3, w4;
    alu_SRA_Bit #(8) RIGHT2(.A(w2), .out(w3));
    mux_2 #(32) DORIGHT2(.out(w4), .select(ctrl_shiftamt[3]), .in0(w2), .in1(w3));

    wire [31:0] w5, w6;
    alu_SRA_Bit #(4) RIGHT3(.A(w4), .out(w5));
    mux_2 #(32) DORIGHT3(.out(w6), .select(ctrl_shiftamt[2]), .in0(w4), .in1(w5));

    wire [31:0] w7, w8;
    alu_SRA_Bit #(2) RIGHT4(.A(w6), .out(w7));
    mux_2 #(32) DORIGHT4(.out(w8), .select(ctrl_shiftamt[1]), .in0(w6), .in1(w7));

    wire [31:0] w9;
    alu_SRA_Bit #(1) RIGHT5(.A(w8), .out(w9));
    mux_2 #(32) DORIGHT5(.out(out), .select(ctrl_shiftamt[0]), .in0(w8), .in1(w9));

endmodule
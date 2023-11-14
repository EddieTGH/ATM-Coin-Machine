module alu_IsNotEqual(A, B, out);
    input [31:0] A, B;
    output out;

    wire [31:0] w1;
    bitwise_xor #(32) get_XOR(.A(A), .B(B), .out(w1));
    wire w2, w3, w4, w5;
    or OR1(w2, w1[7], w1[6], w1[5], w1[4], w1[3], w1[2], w1[1], w1[0]);
    or OR2(w3, w1[15], w1[14], w1[13], w1[12], w1[11], w1[10], w1[9], w1[8]);
    or OR3(w4, w1[23], w1[22], w1[21], w1[20], w1[19], w1[18], w1[17], w1[16]);
    or OR4(w5, w1[31], w1[30], w1[29], w1[28], w1[27], w1[26], w1[25], w1[24]);
    or OR5(out, w2, w3, w4, w5);

endmodule
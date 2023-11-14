module CLA(A, B, Cin, S, P_in, G_in, overflow);
    input [31:0] A, B, P_in, G_in;
    input Cin;

    output [31:0] S;
    output overflow;

    wire [3:0] P_Values, G_Values;
    wire [3:0] carries;

    wire w1;
    and B1(w1, P_Values[0], Cin);
    or CARRY1A(carries[0], G_Values[0], w1);

    wire w2, w3;
    and B2(w2, P_Values[1], G_Values[0]);
    and B3(w3, P_Values[1], P_Values[0], Cin);
    or CARRY2A(carries[1], G_Values[1], w2, w3);

    wire w4, w5, w6;
    and B4(w4, P_Values[2], G_Values[1]);
    and B5(w5, P_Values[2], P_Values[1], G_Values[0]);
    and B6(w6, P_Values[2], P_Values[1], P_Values[0], Cin);
    or CARRY3A(carries[2], G_Values[2], w4, w5, w6);

    wire w7, w8, w9, w10;
    and B7(w7, P_Values[3], G_Values[2]);
    and B8(w8, P_Values[3], P_Values[2], G_Values[1]);
    and B9(w9, P_Values[3], P_Values[2], P_Values[1], G_Values[0]);
    and B10(w10, P_Values[3], P_Values[2], P_Values[1], P_Values[0], Cin);
    or CARRY4A(carries[3], G_Values[3], w7, w8, w9, w10);
    
    CLA_8 CLA_Block_0(.A(A[7:0]), .B(B[7:0]), .C0(Cin), .S(S[7:0]), .P_in(P_in[7:0]), .G_in(G_in[7:0]), .P_out(P_Values[0]), .G_out(G_Values[0]));
    CLA_8 CLA_Block_1(.A(A[15:8]), .B(B[15:8]), .C0(carries[0]), .S(S[15:8]), .P_in(P_in[15:8]), .G_in(G_in[15:8]), .P_out(P_Values[1]), .G_out(G_Values[1]));
    CLA_8 CLA_Block_2(.A(A[23:16]), .B(B[23:16]), .C0(carries[1]), .S(S[23:16]), .P_in(P_in[23:16]), .G_in(G_in[23:16]), .P_out(P_Values[2]), .G_out(G_Values[2]));
    CLA_8 CLA_Block_3(.A(A[31:24]), .B(B[31:24]), .C0(carries[2]), .S(S[31:24]), .P_in(P_in[31:24]), .G_in(G_in[31:24]), .P_out(P_Values[3]), .G_out(G_Values[3]));

    //overflow detection
    wire high_Bit_Same, potential_Overflow;

    xnor same_High(high_Bit_Same, A[31], B[31]);
    xor overflow_Detection(potential_Overflow, S[31], A[31]);
    and overflow_Valid(overflow, potential_Overflow, high_Bit_Same);


endmodule
module CLA_8(A, B, C0, S, P_in, G_in, P_out, G_out);
    input [7:0] A, B, P_in, G_in;
    input C0;
    output[7:0] S;
    output P_out, G_out;
    wire [7:0] carry;

    assign carry[0] = C0;

    wire w1;
    and A1(w1, P_in[0], C0);
    or CARRY1(carry[1], G_in[0], w1);

    wire w2, w3;
    and A2(w2, P_in[1], G_in[0]);
    and A3(w3, P_in[1], P_in[0], C0);
    or CARRY2(carry[2], G_in[1], w2, w3);

    wire w4, w5, w6;
    and A4(w4, P_in[2], G_in[1]);
    and A5(w5, P_in[2], P_in[1], G_in[0]);
    and A6(w6, P_in[2], P_in[1], P_in[0], C0);
    or CARRY3(carry[3], G_in[2], w4, w5, w6);

    wire w7, w8, w9, w10;
    and A7(w7, P_in[3], G_in[2]);
    and A8(w8, P_in[3], P_in[2], G_in[1]);
    and A9(w9, P_in[3], P_in[2], P_in[1], G_in[0]);
    and A10(w10, P_in[3], P_in[2], P_in[1], P_in[0], C0);
    or CARRY4(carry[4], G_in[3], w7, w8, w9, w10);

    wire w11, w12, w13, w14, w15;
    and A11(w11, P_in[4], G_in[3]);
    and A12(w12, P_in[4], P_in[3], G_in[2]);
    and A13(w13, P_in[4], P_in[3], P_in[2], G_in[1]);
    and A14(w14, P_in[4], P_in[3], P_in[2], P_in[1], G_in[0]);
    and A15(w15, P_in[4], P_in[3], P_in[2], P_in[1], P_in[0], C0);
    or CARRY5(carry[5], G_in[4], w11, w12, w13, w14, w15);

    wire w16, w17, w18, w19, w20, w21;
    and A16(w16, P_in[5], G_in[4]);
    and A17(w17, P_in[5], P_in[4], G_in[3]);
    and A18(w18, P_in[5], P_in[4], P_in[3], G_in[2]);
    and A19(w19, P_in[5], P_in[4], P_in[3], P_in[2], G_in[1]);
    and A20(w20, P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], G_in[0]);
    and A21(w21, P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], P_in[0], C0);
    or CARRY6(carry[6], G_in[5], w16, w17, w18, w19, w20, w21);

    wire w22, w23, w24, w25, w26, w27, w28;
    and A22(w22, P_in[6], G_in[5]);
    and A23(w23, P_in[6], P_in[5], G_in[4]);
    and A24(w24, P_in[6], P_in[5], P_in[4], G_in[3]);
    and A25(w25, P_in[6], P_in[5], P_in[4], P_in[3], G_in[2]);
    and A26(w26, P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], G_in[1]);
    and A27(w27, P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], G_in[0]);
    and A28(w28, P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], P_in[0], C0);
    or CARRY7(carry[7], G_in[6], w22, w23, w24, w25, w26, w27, w28);
    
    and Get_P_out(P_out, P_in[7], P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], P_in[0]); //get P_out for block
    wire w29, w30, w31, w32, w33, w34, w35;
    and A29(w29, P_in[7], G_in[6]);
    and A30(w30, P_in[7], P_in[6], G_in[5]);
    and A31(w31, P_in[7], P_in[6], P_in[5], G_in[4]);
    and A32(w32, P_in[7], P_in[6], P_in[5], P_in[4], G_in[3]);
    and A33(w33, P_in[7], P_in[6], P_in[5], P_in[4], P_in[3], G_in[2]);
    and A34(w34, P_in[7], P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], G_in[1]);
    and A35(w35, P_in[7], P_in[6], P_in[5], P_in[4], P_in[3], P_in[2], P_in[1], G_in[0]);
    or Get_G_out(G_out, G_in[7], w29, w30, w31, w32, w33, w34, w35); //get G_out for block


    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            xor XOR1(S[i], A[i], B[i], carry[i]);
        end
    endgenerate
endmodule
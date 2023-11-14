module alu_IsLessThan(A_MSB, B_MSB, S_MSB, out);
    input A_MSB, B_MSB, S_MSB;
    output out;

    wire A_MSB_Not, B_MSB_Not;
    not NOT1(A_MSB_Not, A_MSB);
    not NOT2(B_MSB_Not, B_MSB);

    wire w1, w2, w3;
    and AND1(w1, A_MSB_Not, B_MSB_Not, S_MSB);
    and AND2(w2, A_MSB, B_MSB, S_MSB);
    and AND3(w3, A_MSB, B_MSB_Not);
    or OR1(out, w1, w2, w3);
endmodule
module TFF(T, q, clk, en, clr);
    input T, clk, en, clr;
    output q;

    wire T_not, q_not;
    not NOT1(T_not, T);
    not NOT2(q_not, q);
    wire w1, w2;
    and AND1(w1, T_not, q);
    and AND2(w2, T, q_not);
    wire w3;
    or OR1(w3, w1, w2);

    dffe_ref DFF(.q(q), .d(w3), .clk(clk), .en(en), .clr(clr));
endmodule
module counter_32(q, en, clk, clr);

    input clk, en, clr;
    output [4:0] q;
    wire [4:0] T;

    assign T[0] = en;
    and AND1(T[1], en, q[0]);
    and AND2(T[2], T[1], q[1]);
    and AND3(T[3], T[2], q[2]);
    and AND4(T[4], T[3], q[3]);

    genvar i;
    generate
        for (i = 0 ; i < 5 ; i = i + 1) begin
            TFF TFF1(.T(T[i]), .q(q[i]), .clk(clk), .en(en), .clr(clr));
        end
    endgenerate

endmodule;
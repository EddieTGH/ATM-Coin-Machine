module pcPlus1PlusN(pc, N, pcIncrementedPlusN);
    input [31:0] pc, N;
    output [31:0] pcIncrementedPlusN;

    wire PCPlus1PlusNOvf;
    wire [31:0] G_inFin, P_inFin;

    bitwise_and #(32) FinPCG(.A(pc), .B(N), .out(G_inFin));
    bitwise_or #(32) FinPCP(.A(pc), .B(N), .out(P_inFin));

    CLA incrementPC(.A(pc), .B(N), .Cin(1'b0), .S(pcIncrementedPlusN), .P_in(P_inFin), .G_in(G_inFin), .overflow(PCPlus1PlusNOvf));

endmodule
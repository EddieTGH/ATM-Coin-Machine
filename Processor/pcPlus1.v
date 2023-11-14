module pcPlus1(pc, pcIncremented);
    input [31:0] pc;
    output [31:0] pcIncremented;

    wire incrementPCOvf;
    wire [31:0] G_inInc, P_inInc;

    bitwise_and #(32) IncrementPCG(.A(pc), .B(32'b1), .out(G_inInc));
    bitwise_or #(32) IncrementPCP(.A(pc), .B(32'b1), .out(P_inInc));

    CLA incrementPC(.A(pc), .B(32'b1), .Cin(1'b0), .S(pcIncremented), .P_in(P_inInc), .G_in(G_inInc), .overflow(incrementPCOvf));
endmodule
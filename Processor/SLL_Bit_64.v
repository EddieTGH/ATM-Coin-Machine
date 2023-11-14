module SLL_Bit_64 #(parameter WIDTH = 1)(A, out);
    input [63:0] A;
    output [63:0] out;

    assign out[WIDTH-1:0] = 0;
    assign out[63:WIDTH] = A[63-WIDTH:0];
endmodule
module SRA_Bit_64 #(parameter WIDTH=1)(A, out);
    input [63:0] A;
    output [63:0] out;

    assign out[63:63-WIDTH+1] = {WIDTH{A[63]}};
    assign out[63-WIDTH:0] = A[63:WIDTH];
endmodule
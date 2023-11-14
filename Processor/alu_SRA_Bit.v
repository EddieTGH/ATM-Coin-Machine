module alu_SRA_Bit #(parameter WIDTH=1)(A, out);
    input [31:0] A;
    output [31:0] out;

    assign out[31:31-WIDTH+1] = {WIDTH{A[31]}};
    assign out[31-WIDTH:0] = A[31:WIDTH];
endmodule
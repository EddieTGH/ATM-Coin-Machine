module alu_SLL_Bit #(parameter WIDTH = 1)(A, out);
    input [31:0] A;
    output [31:0] out;

    assign out[WIDTH-1:0] = 0;
    assign out[31:WIDTH] = A[31-WIDTH:0];
endmodule
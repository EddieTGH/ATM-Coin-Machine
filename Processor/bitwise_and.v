module bitwise_and #(parameter WIDTH=1)(A, B, out);
    input [WIDTH-1:0] A, B;
    output [WIDTH-1:0] out;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            and AND1(out[i], A[i], B[i]);
        end
    endgenerate
endmodule
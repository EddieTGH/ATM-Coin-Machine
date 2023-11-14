module bitwise_not #(parameter WIDTH=1)(A, out);
    input [WIDTH-1:0] A;
    output [WIDTH-1:0] out;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            not NOT1(out[i], A[i]);
        end
    endgenerate
endmodule
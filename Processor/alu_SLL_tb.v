`timescale 1 ns / 100 ps
module alu_SLL_tb;
    reg [31:0] A;
    wire [31:0] out;
    wire [4:0] shift;
    integer i;

    alu_SLL alu_SLL_Tester(.A(A), .out(out), .ctrl_shiftamt(shift));

    assign shift = i[4:0];

    initial begin
        A = 32'b1;

        for (i = 0; i < 32; i = i + 1) begin
            #20;
            $display("A:%b, shift:%b => out:%b", A, shift, out);

        end
        $finish;
    end
endmodule
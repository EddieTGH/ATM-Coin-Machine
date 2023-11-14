module get_Exception_rstatus(instruction, exception_rstatus);
    input [31:0] instruction;
    output [31:0] exception_rstatus;

    wire [31:0] w1;
    assign w1 = instruction[2] ? 32'b11 : 32'b1; //ALUOP bit 0, either sub (rstatus = 3) or add (rstatus = 1)
    assign exception_rstatus = ((!instruction[31]) & (!instruction[30]) & (!instruction[29]) & (!instruction[28]) & (!instruction[27])) ? w1 : 32'b10; //either an add/sub (rstatus = 1/3) or addi (rstatus = 2)

endmodule
module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // add your code here:
    wire [4:0] ALUopcode_not;
    bitwise_not #(5) NOTALUOP(.A(ctrl_ALUopcode), .out(ALUopcode_not));

    wire [31:0] B_Not;
    bitwise_not #(32) NOTB(.A(data_operandB), .out(B_Not));

    wire sub; //this is used as the carry in bit for CLA and mux selector for if we want B or B not
    wire [31:0] B_Final;
    and AND1(sub, ALUopcode_not[4], ALUopcode_not[3], ALUopcode_not[2], ALUopcode_not[1], ctrl_ALUopcode[0]);
    mux_2 #(32) B_Selector(.out(B_Final), .select(sub), .in0(data_operandB), .in1(B_Not));

    wire [31:0] P_in, G_in;
    bitwise_and #(32) Get_G(.A(data_operandA), .B(B_Final), .out(G_in));
    bitwise_or #(32) Get_P(.A(data_operandA), .B(B_Final), .out(P_in));

    wire [31:0] CLA_Out;
    CLA CLA(.A(data_operandA), .B(B_Final), .Cin(sub), .S(CLA_Out), .P_in(P_in), .G_in(G_in), .overflow(overflow));

    alu_IsLessThan Get_IsLessThan(.A_MSB(data_operandA[31]), .B_MSB(data_operandB[31]), .S_MSB(CLA_Out[31]), .out(isLessThan));
    alu_IsNotEqual Get_IsNotEqual(.A(data_operandA), .B(data_operandB), .out(isNotEqual));

    wire [31:0] SLL_Out, SRA_Out;
    alu_SLL SLL(.A(data_operandA), .out(SLL_Out), .ctrl_shiftamt(ctrl_shiftamt));
    alu_SRA SRA(.A(data_operandA), .out(SRA_Out), .ctrl_shiftamt(ctrl_shiftamt));

    mux_8 #(32) ALUOP_Selector(.out(data_result), .select(ctrl_ALUopcode[2:0]), .in0(CLA_Out), .in1(CLA_Out), .in2(G_in), .in3(P_in), .in4(SLL_Out), .in5(SRA_Out), .in6(0), .in7(0));

endmodule
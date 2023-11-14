module executeDetNextPC(xC_Execute, branch_Next_PC, ALU_isLessThan, ALU_isNotEqual, target, rd_rstatus, execute_Next_PC, select_execute_Next_PC);
    input [31:0] branch_Next_PC, rd_rstatus;
    input [26:0] target;
    input [10:0] xC_Execute;
    input ALU_isLessThan, ALU_isNotEqual;
    output [31:0] execute_Next_PC;
    output select_execute_Next_PC;

    wire [31:0] extended_target;
    assign extended_target = {5'b0, target}; //32-bit extend target

    wire [1:0] next_PC_Selector; //4 input mux selector

    wire yesBLT, yesBNE, selectBranchingPC;
    assign yesBLT = (xC_Execute[1]) & ((!ALU_isLessThan) & ALU_isNotEqual); //blt
    assign yesBNE = (xC_Execute[2]) & (ALU_isNotEqual); //bne 
    assign selectBranchingPC = yesBLT | yesBNE;

    wire selectJorJalPC;
    assign selectJorJalPC = xC_Execute[3];

    wire selectJrPC;
    assign selectJrPC = xC_Execute[4];

    wire selectBexPC;
    assign selectBexPC = (xC_Execute[5]) & (|rd_rstatus); //bex

    assign next_PC_Selector[1] = selectJrPC;
    assign next_PC_Selector[0] = selectJorJalPC | selectBexPC;
    assign select_execute_Next_PC = selectBranchingPC | selectJorJalPC | selectJrPC | selectBexPC;
    mux_4 #(32) SELECTPC(.out(execute_Next_PC), .select(next_PC_Selector), .in0(branch_Next_PC), .in1(extended_target), .in2(rd_rstatus), .in3(32'b0));
endmodule
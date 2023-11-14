module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    wire shouldStore;
    wire storeNegativeDividend;
    wire storeNegativeDivisor;
    wire negativeDividendOp; //shows if this is a div and we negated dividend
    wire negativeDivisorOp; //shows if this is a div and we negated divisor
    wire shouldNegateQuotient; //if we need to negate our final answer
    wire isMult; //1 if we are doing mult 0 if div
    wire isDiv; //1 if we are doing div 0 if mult
    wire [1:0] multOrDivOut; //bit 1 is high if we are doing div, bit 0 is high if we are doing mult. Neither high if not doing any operation.
    wire clearMultOrDiv; //used to clear multOrDiv register when we are done with operation
    
    assign shouldStore = ctrl_MULT | ctrl_DIV;
    assign storeNegativeDividend = ctrl_DIV & data_operandA[31]; //negative dividend
    assign storeNegativeDivisor = ctrl_DIV & data_operandB[31]; //negative divisor
    assign isMult = multOrDivOut[0];
    assign isDiv = multOrDivOut[1];
    assign clearMultOrDiv = data_resultRDY & !shouldStore; 
    multOrDiv multOrDiv(.ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), .out(multOrDivOut), .clock(clock), .enable(shouldStore), .clear(clearMultOrDiv)); //clear when data ready (operation finished) has been asserted for 1 cycle
    dffe_ref negatedDividend(.q(negativeDividendOp), .d(storeNegativeDividend), .clk(clock), .en(shouldStore), .clr(1'b0));
    dffe_ref negatedDivisor(.q(negativeDivisorOp), .d(storeNegativeDivisor), .clk(clock), .en(shouldStore), .clr(1'b0));
    xor negateQuotient(shouldNegateQuotient, negativeDividendOp, negativeDivisorOp); //if D and V are of different signs we must negate our quotient at end

    wire [31:0] data_operandANot;
    wire [31:0] data_operandBNot;
    assign data_operandANot = ~data_operandA;
    assign data_operandBNot = ~data_operandB;
    wire negateDividendOverflow;
    wire [31:0] negativeDividend;
    wire [31:0] P_inDividend, G_inDividend;
    bitwise_and #(32) Get_G1(.A(data_operandANot), .B(32'b1), .out(G_inDividend)); //REPLACE WITH & AND |
    bitwise_or #(32) Get_P1(.A(data_operandANot), .B(32'b1), .out(P_inDividend));
    CLA GetNegatedDividend(.A(data_operandANot), .B(32'b1), .Cin(1'b0), .S(negativeDividend), .P_in(P_inDividend), .G_in(G_inDividend), .overflow(negateDividendOverflow));
    wire negateDivisorOverflow;
    wire [31:0] negativeDivisor;
    wire [31:0] P_inDivisor, G_inDivisor;
    bitwise_and #(32) Get_G2(.A(data_operandBNot), .B(32'b1), .out(G_inDivisor)); //REPLACE WITH & AND |
    bitwise_or #(32) Get_P2(.A(data_operandBNot), .B(32'b1), .out(P_inDivisor));
    CLA GetNegatedDivisor(.A(data_operandBNot), .B(32'b1), .Cin(1'b0), .S(negativeDivisor), .P_in(P_inDivisor), .G_in(G_inDivisor), .overflow(negateDivisorOverflow));

    wire [31:0] MultiplicandDivisorBits;
    wire [31:0] writeMultiplicandDivisor;
    wire [31:0] finDivisor;
    assign finDivisor = data_operandB[31] ? negativeDivisor : data_operandB;
    assign writeMultiplicandDivisor = ctrl_MULT ? data_operandA : finDivisor;
    register_32 multiplicandDivisor(.data_writeReg(writeMultiplicandDivisor), .data_readReg(MultiplicandDivisorBits), .clk(clock), .write_enable(shouldStore), .reset(1'b0));

    wire [63:0] currProductRQBits;
    wire [63:0] initProductRQ; //stored when we initialzing the productRQ register to start a mult or div operation
    wire [31:0] finDividend;
    assign finDividend = data_operandA[31] ? negativeDividend : data_operandA;
    assign initProductRQ = ctrl_MULT ? {32'b0, data_operandB} : {32'b0, finDividend};

    wire [63:0] w5; 
    mux_2 #(64) MUX1(.out(w5), .select(isMult), .in0(nextProductRQBitsDiv), .in1(nextProductRQBitsMult)); //choose between nextProductRQBitsMult or nextProductRQBitsDiv
    wire [63:0] finalWriteProductRQ; //this is the final value we write to the productRQ register, either the initProductRQ or the nextProductRQBitsMult or nextProductRQBitsDiv
    mux_2 #(64) MUX2(.out(finalWriteProductRQ), .select(shouldStore), .in0(w5), .in1(initProductRQ)); //choose between initProductRQ or nextProductRQBitsMult or nextProductRQBitsDiv
    register_64 productRQ(.data_writeReg(finalWriteProductRQ), .data_readReg(currProductRQBits), .clk(clock), .write_enable(1'b1), .reset(1'b0));
    //MAYBE CHANGE .WRITE_ENABLE() ABOVE

    wire [2:0] BoothsBits; //used for booths multiplication
    assign BoothsBits[2:1] = currProductRQBits[1:0];
    wire syncClear;
    assign syncClear = shouldStore & clock; //need to make sure synchronous clear so we don't clear and then latch currProductRQBits[1] at the rising edge of clock when we reinitialize productRQ regsiter to start a mult
    dffe_ref booths_right_bit(.q(BoothsBits[0]), .d(currProductRQBits[1]), .clk(clock), .en(1'b1), .clr(syncClear)); //clear when we starting a mult/div operation so it restarts as implicit 0 being the rightmost bit
    //MAYBE CHANGE .EN(1'B1) ABOVE

    wire multiplierHighBit;
    dffe_ref MSBMultiplier(.q(multiplierHighBit), .d(data_operandB[31]), .clk(clock), .en(shouldStore), .clr(1'b0));

    wire [31:0] w1, w2;
    SLL_Bit #(1) SLL1(.A(MultiplicandDivisorBits), .out(w1));
    wire shiftOne;
    assign shiftOne = ((BoothsBits[2] & ~BoothsBits[1] & ~BoothsBits[0]) | (~BoothsBits[2] & BoothsBits[1] & BoothsBits[0])) & isMult; //shift if in one of booths cases when we need 2M and if multiplication operation
    mux_2 #(32) ShiftOrNot(.out(w2), .select(shiftOne), .in0(MultiplicandDivisorBits), .in1(w1));


    wire [31:0] MultiplicandDivisor_Not;
    assign MultiplicandDivisor_Not = ~w2;


    wire subMult; //this is used as the carry in bit for CLA and mux selector for if we want B or B not for multiplication
    wire [31:0] B_Final_Mult;
    assign subMult = (BoothsBits[2] & ~BoothsBits[1] & ~BoothsBits[0]) | (BoothsBits[2] & BoothsBits[1] & ~BoothsBits[0]) | (BoothsBits[2] & ~BoothsBits[1] & BoothsBits[0]);
    mux_2 #(32) B_Selector(.out(B_Final_Mult), .select(subMult), .in0(w2), .in1(MultiplicandDivisor_Not));

    wire subDiv; //this is used as the carry in bit for CLA and mux selector for if we want B or B not for division
    wire [31:0] B_Final_Div;
    assign subDiv = ~currProductRQBits[63];
    mux_2 #(32) B_Selector2(.out(B_Final_Div), .select(subDiv), .in0(w2), .in1(MultiplicandDivisor_Not));

    wire finalCin1;
    wire finalCin;
    assign finalCin1 = isMult ? subMult : subDiv;
    assign finalCin = (shouldNegateQuotient & isCompleteOut) ? 1'b0 : finalCin1;
    wire [31:0] B_Final;
    wire [31:0] B_Final1;
    assign B_Final1 = isMult ? B_Final_Mult : B_Final_Div;
    assign B_Final = (shouldNegateQuotient & isCompleteOut) ? 1'b1 : B_Final1;

    wire [31:0] CLA_A_Input;
    wire [31:0] CLA_A_Input1;
    assign CLA_A_Input1 = isMult ? currProductRQBits[63:32] : leftShiftedDiv[63:32];
    assign CLA_A_Input = (shouldNegateQuotient & isCompleteOut) ? ~currProductRQBits[31:0] : CLA_A_Input1;
    wire [31:0] P_in, G_in;
    bitwise_and #(32) Get_G(.A(CLA_A_Input), .B(B_Final), .out(G_in)); //REPLACE WITH & AND |
    bitwise_or #(32) Get_P(.A(CLA_A_Input), .B(B_Final), .out(P_in));

    wire [31:0] CLA_Out;
    wire overflow;
    CLA CLA(.A(CLA_A_Input), .B(B_Final), .Cin(finalCin), .S(CLA_Out), .P_in(P_in), .G_in(G_in), .overflow(overflow));

    wire [63:0] w3, w4, nextProductRQBitsMult; //used for the next bits to store in productRQ regsiter for mult
    wire doNothingMult; //check if in booths case where we do nothing for this cycle except shift
    assign doNothingMult = (BoothsBits[2] & BoothsBits[1] & BoothsBits[0]) | (~BoothsBits[2] & ~BoothsBits[1] & ~BoothsBits[0]);
    assign w3 = {CLA_Out, currProductRQBits[31:0]}; //concatenate the CLA output with the lower 32 bits of the productRQ register (only needed if not on 000 or 111 booths)
    mux_2 #(64) w4_mux(.out(w4), .select(doNothingMult), .in0(w3), .in1(currProductRQBits)); //if we are in a booths case where we do nothing, then we just store the current productRQBits in the nextProductRQBitsMult
    //assign nextProductRQBitsMult = w4 >>> 2;
    SRA_Bit_64 #(2) RightShifter(.A(w4), .out(nextProductRQBitsMult));

    wire [63:0] nextProductRQBitsDiv; //used for the next bits to store in productRQ regsiter for div
    wire [63:0] nextProductRQBitsDiv1;
    wire [63:0] nextProductRQBitsDiv2;
    wire [63:0] leftShiftedDiv;
    SLL_Bit_64 #(1) leftShifter(.A(currProductRQBits), .out(leftShiftedDiv));
    assign nextProductRQBitsDiv1[63:1] = {CLA_Out, leftShiftedDiv[31:1]};
    assign nextProductRQBitsDiv1[0] = ~CLA_Out[31];
    assign nextProductRQBitsDiv2[63:0] = {currProductRQBits[63:32], CLA_Out};
    assign nextProductRQBitsDiv[63:0] = (shouldNegateQuotient & isCompleteOut) ? nextProductRQBitsDiv2 : nextProductRQBitsDiv1;
    

    wire [3:0] counterOut; //gives us which cycle we currently on
    wire counterEnable;
    assign counterEnable = 1'b1; //always enabled
    counter_16 counter(.q(counterOut), .en(counterEnable), .clk(clock), .clr(syncClear));

    wire [4:0] counterOut32;
    counter_32 counter2(.q(counterOut32), .en(counterEnable), .clk(clock), .clr(syncClear));

    //DATA RESULT STUFF
    assign data_result = currProductRQBits[31:0];

    wire w6, w7, w8, w9, w10;
    wire finMultException, finDivException;
    mult_Exception MULTEXCEPTION(.currProductRQUpper(currProductRQBits[63:31]), .out(w6));
    xor diffSigns(w10, MultiplicandDivisorBits[31], multiplierHighBit);
    xor diffResultSign(w7, w10, currProductRQBits[31]);  //signs dont make sense
    assign finMultException = w6 | (w7 & (|currProductRQBits[31:0]));
    assign w8 = !(|MultiplicandDivisorBits);
    assign w9 = 1'b0; //-2147483648 / -1
    assign finDivException = w8 | w9;
    assign data_exception = isMult ? finMultException : finDivException;
    //two exception cases for division: divide by 0 (data operand b = 0), or one of the inputs is -2147483648 (because converting to positive at start causes overflow)
    //div_Exception DIVEXCEPTION();
    
    //CONSIDER OVERFLOW DURING ADDITION IN CLA (0 - (-2147483648)) = 2147483648 which is out of range (OVERFLOW OUTPUT FROM CLA SHOULD BE 1 HERE)
    
    wire complete;
    wire isCompleteOut;
    wire completeDivNegateOut;
    assign complete = (isMult & counterOut[3] & counterOut[2] & counterOut[1] & counterOut[0]) | (isDiv & counterOut32[4] & counterOut32[3] & counterOut32[2] & counterOut32[1] & counterOut32[0]); 
    dffe_ref isComplete(.q(isCompleteOut), .d(complete), .clk(clock), .en(1'b1), .clr(1'b0)); 
    dffe_ref completeDivNegate(.q(completeDivNegateOut), .d((isCompleteOut & isDiv)), .clk(clock), .en(1'b1), .clr(1'b0));
    assign data_resultRDY = (isMult | !shouldNegateQuotient) ? isCompleteOut : completeDivNegateOut;
endmodule
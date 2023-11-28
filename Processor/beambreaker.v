module beambreaker(start, beam1, beam2, beam3, beam4);
    input start; //CPU does a sw $startBeamBreaker, (here)
    input IO1, IO2, IO3, IO4; //IO1 is beam1, IO2 is beam2, etc.
    output beam1, beam2, beam3, beam4; //CPU does a lw $registers b1,b2,b3,b4 from memory (AKA from the outputs of this file)
    //when register b1-b4 == 1, do an addi (of 25, 10, 5, or 1)
    reg b1, b2, b3, b4;

    assign beam1 = b1;
    assign beam2 = b2;
    assign beam3 = b3;
    assign beam4 = b4;

    always begin
        if (start == 1'b1) begin
            if (IO1 == 1'b0) begin
                b1 = 1'b1;
            end else begin
                b1 = 1'b0;
            end

            if (IO2 == 1'b0) begin
                b2 = 1'b1;
            end else begin
                b2 = 1'b0;
            end

            if (IO3 == 1'b0) begin
                b3 = 1'b1;
            end else begin
                b3 = 1'b0;
            end

            if (IO4 == 1'b0) begin
                b4 = 1'b1;
            end else begin
                b4 = 1'b0;
            end
        end
    end

endmodule
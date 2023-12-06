`timescale 1ns / 1ps
module keypad(cols, rows, clock, buttonPressed, acknowledgeKey, LED, LED12, LED13);
    input [2:0] cols; // col3, col2, col1;
    input clock;
    input [31:0] acknowledgeKey;
    output reg [3:0] rows; // row4, row3, row2, row1;
    output [3:0] buttonPressed;
    output [11:0] LED;
    output reg LED12, LED13;

    integer i, j; //row, col

    reg debounce;
    reg reset_counter;
    initial begin
        i = 0;
        j = 0;
        rows[0] = 1'b1;
        rows[1] = 1'b1;
        rows[2] = 1'b1;
        rows[3] = 1'b1;
        LED12 = 1'b0;
        LED13 = 1'b0;
        debounce = 1'b0;
        reset_counter = 1'b0;
    end

    wire [11:0] keys;
    assign keys[0] = i[1] & i[0] & ~cols[1];
    assign keys[1] = ~i[1] & ~i[0] & ~cols[0];
    assign keys[2] = ~i[1] & ~i[0] & ~cols[1];
    assign keys[3] = ~i[1] & ~i[0] & ~cols[2];
    assign keys[4] = ~i[1] & i[0] & ~cols[0];
    assign keys[5] = ~i[1] & i[0] & ~cols[1];
    assign keys[6] = ~i[1] & i[0] & ~cols[2];
    assign keys[7] = i[1] & ~i[0] & ~cols[0];
    assign keys[8] = i[1] & ~i[0] & ~cols[1];
    assign keys[9] = i[1] & ~i[0] & ~cols[2];
    assign keys[10] = i[1] & i[0] & ~cols[0]; //key *
    assign keys[11] = i[1] & i[0] & ~cols[2]; //key #

    wire [3:0] encoderOut;
    priorityEncoder164 encoder(.i(keys), .out(encoderOut));
    assign buttonPressed = debounce ? 4'b1101 : encoderOut;

    wire clk100Hz;
    keypadClockDiv clockDiv(.clk(clock), .clk_out(clk100Hz));

    wire buttonNotPressed;
    assign buttonNotPressed = cols[2] & cols[1] & cols[0]; //need to debounce button release
    

    always @(posedge clk100Hz) begin
        if (buttonNotPressed) begin //if we havent detected a button press go to next state
            if (j == 2) begin
                rows[i] = 1'b1; //set voltage high
                if (i == 3) begin
                    i = 0;
                    j = 0;
                end else begin
                    j = 0;
                    i = i + 1;
                end
                rows[i] = 1'b0; //set voltage low
            end else begin
                j = j + 1;
            end
        end
    end
    

    always @(posedge clock) begin
        if ((~buttonNotPressed) & ~(debounce)) begin
            LED13 = 1'b1;
            if (acknowledgeKey[0] == 1) begin
                LED12 = 1'b1;
                reset_counter = 1'b1;
                debounce = 1'b1;
                #10;
                reset_counter = 1'b0;
            end
        end
    end

    wire debounceCounterDone;
    debounce_counter DEBOUNCE(.clock(clock), .counter_done(debounceCounterDone), .reset(reset_counter));

    always @(posedge debounceCounterDone) begin
        if (debounce) begin
            LED12 = 1'b0;
            debounce = 1'b0;
        end
    end
    
    assign LED[11] = debounce;
    assign LED[10:7] = debounce ? 4'b1101 : encoderOut;
    assign LED[6:0] = keys[6:0];

endmodule
`timescale 1ns / 1ps
module debounceUnit(buttonNotPressed, acknowledge, clock, debounce);
    input acknowledge;
    input buttonNotPressed, clock;
    output reg debounce;

    //reg reset_counter;
    initial begin
        debounce = 1'b0;
        //reset_counter = 1'b0;
    end

    //wire debounceCounterDone;

    // always @(posedge clock or posedge debounceCounterDone) begin
    //     if (debounceCounterDone & debounce) begin
    //         debounce = 1'b0;
    //     end else if ((~buttonNotPressed) & ~(debounce)) begin
    //         if (acknowledge == 1) begin
    //             reset_counter = 1'b1;
    //             debounce = 1'b1;
    //             #10;
    //             reset_counter = 1'b0;
    //         end
    //     end
    // end


    reg [25:0] counter_reg = 0;
    reg timerStart = 0;  

    always @(posedge clock) begin
        if ((~buttonNotPressed) & ~(debounce)) begin
            if (acknowledge == 1) begin
                debounce = 1'b1;
                timerStart = 1'b1;
            end
        end else if (timerStart) begin
            timerStart = 1'b0;
            counter_reg = 0;
        end else if (counter_reg == 10000000) begin
            debounce = 1'b0;
        end else if (debounce) begin
            counter_reg <= counter_reg + 1;
        end
    end

    //debounce_counter DEBOUNCE(.clock(clock), .counter_done(debounceCounterDone), .reset(reset_counter));


endmodule
module debounceUnit(buttonNotPressed, acknowledge, clock, debounce);
    input acknowledge;
    input buttonNotPressed, clock;
    output reg debounce;

    reg reset_counter;
    initial begin
        debounce = 1'b0;
        reset_counter = 1'b0;
    end

    wire debounceCounterDone;

    always @(posedge clock or posedge debounceCounterDone) begin
        if (debounceCounterDone & debounce) begin
            debounce = 1'b0;
        end else if ((~buttonNotPressed) & ~(debounce)) begin
            if (acknowledge == 1) begin
                reset_counter = 1'b1;
                debounce = 1'b1;
                #10;
                reset_counter = 1'b0;
            end
        end
    end

    debounce_counter DEBOUNCE(.clock(clock), .counter_done(debounceCounterDone), .reset(reset_counter));

endmodule
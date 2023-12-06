module debounce_counter(clock, counter_done, reset);
    input clock, reset;
    output counter_done;

    assign counter_done = (counter_reg == 30000000) ? 1'b1 : 1'b0;

    reg [25:0] counter_reg = 0;

    always @(posedge reset) begin
        counter_reg = 0;
    end

    always @(posedge clock) begin
        if (~reset) begin
            counter_reg = counter_reg + 1;
        end
    end

endmodule
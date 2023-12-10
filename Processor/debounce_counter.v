`timescale 1ns / 1ps
module debounce_counter(clock, counter_done, reset);
    input clock, reset;
    output counter_done;

    assign counter_done = (counter_reg >= 20000000) ? 1'b1 : 1'b0;

    reg [25:0] counter_reg = 0;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
        end
    end

endmodule
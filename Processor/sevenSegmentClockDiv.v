module sevenSegmentClockDiv(clk, clk_out);
    input clk;
    output clk_out;

    assign clk_out = clk1KHz;

    reg clk1KHz = 0;
    reg [15:0] counter = 0;
    always @(posedge clk) begin
        if (counter < 14999) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            clk1KHz <= ~clk1KHz;
        end
    end
endmodule
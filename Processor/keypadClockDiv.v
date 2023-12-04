module keypadClockDiv(clk, clk_out);
    input clk;
    output clk_out;

    assign clk_out = clk100Hz;

    reg clk100Hz = 0;
    reg [17:0] counter = 0;
    always @(posedge clk) begin
        if (counter < 149999) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            clk100Hz <= ~clk100Hz;
        end
    end
endmodule
`timescale 1 ns / 100 ps
module keypad_tb;
    reg start;
    reg [2:0] cols;
    wire [3:0] rows;
    wire [31:0] foundRow, foundCol;
    wire dataReady;

    keypad KEYPAD(.start(start), .dataReady(dataReady), .cols(cols), .rows(rows), .foundRow(foundRow), .foundCol(foundCol));

    initial begin
        start = 0;
        cols[2] = 0;
        cols[1] = 0;
        cols[0] = 0;

        #200;
        cols[2] = ~cols[2];
        cols[1] = ~cols[1];
        cols[0] = ~cols[0];
        start = ~start;
        #200;
        start = ~start;

        while (dataReady == 0) begin
            if (rows[1] == 0) begin
                cols[1] = ~cols[1];
            end
        end

        #100;
        $finish;
    end

    always @(dataReady) begin
        #1;
        $display("start: %b, dataReady: %b, foundRow: %b, foundCol: %b", start, dataReady, foundRow, foundCol);
    end

endmodule
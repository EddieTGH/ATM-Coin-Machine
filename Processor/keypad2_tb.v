`timescale 1 ns / 100 ps
module keypad_tb2;
    reg start;
    reg [2:0] cols;
    wire [3:0] rows;
    wire [31:0] foundRow, foundCol;
    wire dataReady;

    keypad KEYPAD(.start(start), .dataReady(dataReady), .cols(cols), .rows(rows), .foundRow(foundRow), .foundCol(foundCol));

    integer i, j;

    initial begin
        start = 0;

        // Loop through all rows
        for (i = 0; i < 4; i = i + 1) begin
            // Set the current row to '1' and others to '0'
            for (j = 0; j < 4; j = j + 1) begin
                cols[j] = (j == i) ? 1'b1 : 1'b0;
            end
            #200; // Wait for some time to stabilize
            start = ~start; // Trigger the keypad scan
            #200; // Wait for some time
        end

        #100;
        $finish;
    end

    always @(dataReady) begin
        #1;
        $display("start: %b, dataReady: %b, foundRow: %b, foundCol: %b", start, dataReady, foundRow, foundCol);
    end

endmodule
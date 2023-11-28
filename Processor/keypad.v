module keypad(start, dataReady, cols, rows, foundRow, foundCol);
    input start;
    input [2:0] cols; // col3, col2, col1;
    output [3:0] rows; // row4, row3, row2, row1;
    output [31:0] foundRow, foundCol; 
    output dataReady;

    integer i, j; //row, col

    //reg getStart;
    //assign getStart = start;

    reg getDataReady;
    assign dataReady = getDataReady;

    reg [31:0] getFoundRow, getFoundCol;
    assign foundRow = getFoundRow;
    assign foundCol = getFoundCol;

    reg [3:0] setRows;
    assign rows = setRows;

    always @(start) begin
        if (start == 1'b1) begin
            getDataReady = 1'b0;
            setRows[0] = 1'b1;
            setRows[1] = 1'b1;
            setRows[2] = 1'b1;
            setRows[3] = 1'b1;

            while ((getDataReady == 1'b0)) begin
                for (i = 0; i < 4; i = i + 1) begin
                    if (getDataReady == 1'b0) begin
                        setRows[i] = 1'b0; //set voltage low
                        for (j = 0; j < 3; j = j + 1) begin
                            if (getDataReady == 1'b0) begin
                                if (cols[j] == 1'b0) begin //if find low voltage at a column, we know button pressed
                                    getDataReady = 1'b1;
                                    getFoundRow = i;
                                    getFoundCol = j;
                                end
                            end
                        end
                        setRows[i] = 1'b1; //set voltage high
                    end
                end

            end

        end
    end

endmodule
module mult_Exception(currProductRQUpper, out);
    input [32:0] currProductRQUpper;
    input data_resultRDY;
    output out;

    assign out = ((|currProductRQUpper[32:1]) & !(currProductRQUpper[0])) | (!(&currProductRQUpper[32:1]) & (currProductRQUpper[0]));
endmodule
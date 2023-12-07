`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2016 03:28:33 PM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test;

reg [7:0] sw;
reg clr;
reg clk;

wire PWM;

PWM uut (
    .sw(sw),
    .clr(clr),
    .clk(clk),
    .PWM(PWM)
    );


initial begin
clk = 0;
sw = 8'b0;
clr = 1'b1;
#5 clr = 1'b0;
#1000 sw = 8'b10000000;


end



always 
#5 clk = ~clk;

endmodule

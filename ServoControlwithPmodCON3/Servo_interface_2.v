`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent
// Engineer: Kaitlyn Franz
// 
// Create Date: 01/31/2016 03:04:42 PM
// Design Name: ServoControlwithPmodCON3
// Module Name: Servo_interface
// Project Name: The Claw
// Target Devices: Basys 3 with PmodCON3
// Tool Versions: 2015.4
// Description: 
//      This module creates the PWM signal needed to drive
//      one servo using the PmodCON3. To use the other 3 servo connectors,
//      you can instantiate this module 4 times, or send the same PWM sigal to 
//      four Pmod connector pins. This depends on whether you want the same servo signal, 
//      or different servo signals. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Servo_interface_2 (
    input [31:0] servoCtrl,
    input SW,
    // input [15:0] SW, 
    input clr,
    input clk,
    output JC_Signal,
    output reg servoBackDone,
    output reg servoFrontDone
    );
    
    wire [19:0] A_net;
    wire [19:0] value_net;
    wire [8:0] angle_net;
    wire PWM;
    assign JC_Signal = PWM;
    // reg pwm 
    
    
    // Convert the incoming switch value
    // to an angle.
//    sw_to_angle converter(
//        .sw(SW),
//        .angle(angle_net)
//        );
    
    wire [31:0] inServoControl;
    //assign inServoControl = { 31'b0000000000000000000000000000000, SW};
    assign inServoControl = servoCtrl;
    
    //convert the incoming servocontrol (0,1) to an angle
    servoControl_to_Angle2 servoControlToAngle (.servoControl(inServoControl), .angle(angle_net) );
    
    // Convert the angle value to 
    // the constant value needed for the PWM.
    angle_decoder decode(
        .angle(angle_net),
        .value(value_net)
        );
    
    // Compare the count value from the
    // counter, with the constant value set by
    // the switches.
    comparator compare(
        .A(A_net),
        .B(value_net),
        .PWM(PWM)
        );
      
    // Counts up to a certain value and then resets.
    // This module creates the refresh rate of 20ms.   
    counter count(
        .clr(clr),
        .clk(clk),
        .count(A_net)
        );

    reg timerStart = 0;  
    reg [25:0] counter_reg = 0;  
    reg currPos = 0;
    initial begin
        servoFrontDone = 1'b1;
        servoBackDone = 1'b1;
    end

    always @(posedge clk) begin
        if (servoCtrl[0] & (~currPos)) begin //back position
            currPos = ~currPos;
            servoBackDone = 1'b0;
            timerStart = 1'b1;
        end else if (~servoCtrl[0] & currPos) begin //front position
            currPos = ~currPos;
            servoFrontDone = 1'b0;
            timerStart = 1'b1;
        end else if (timerStart) begin
            timerStart = 1'b0;
            counter_reg <= 0;
        end else if (counter_reg == 30000000) begin
            if (~servoFrontDone) begin
                servoFrontDone <= 1'b1;
            end else if (~servoBackDone) begin
                servoBackDone <= 1'b1;
            end
        end else if (~(servoFrontDone) | ~(servoBackDone)) begin
            counter_reg <= counter_reg + 1;
        end
    end


endmodule

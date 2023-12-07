`timescale 1ns / 1ps
module servoControl_to_Angle(
    input [31:0] servoControl,
    output reg [8:0] angle
    );
    
    // Run when the value of the switches
    // changes
    always @ (servoControl)
    begin
        case (servoControl)
        // servoControl = 1
        1:
        angle = 9'd360;
        // servoControl = 0
        default:
        angle = 9'd0;
        endcase                 
    end
endmodule

`timescale 1ns / 1ps
module beamBreak(beamBroken, reading);
    input reading;
    output beamBroken;

    assign beamBroken = reading; 

endmodule
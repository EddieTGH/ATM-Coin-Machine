`timescale 1ns / 1ps
module beamBreak(beamBroken1, reading1, beamBroken2, reading2, beamBroken3, reading3, beamBroken4, reading4, clock, acknowledgeBeam, LED);
    input reading1, reading2, reading3, reading4, clock;
    input [31:0] acknowledgeBeam;
    output beamBroken1, beamBroken2, beamBroken3, beamBroken4;
    output [3:0] LED;

    //penny 
    wire debounce1; //debounce stuff
    debounceUnit DEBBEAM1(.buttonNotPressed(~reading1), .acknowledge(acknowledgeBeam[0]), .clock(clock), .debounce(debounce1));

    assign beamBroken1 = debounce1 ? 1'b0 : reading1; 

    //nickel 
    wire debounce2; //debounce stuff
    debounceUnit DEBBEAM2(.buttonNotPressed(~reading2), .acknowledge(acknowledgeBeam[0]), .clock(clock), .debounce(debounce2));

    assign beamBroken2 = debounce2 ? 1'b0 : reading2; 

    //dime 
    wire debounce3; //debounce stuff
    debounceUnit DEBBEAM3(.buttonNotPressed(~reading3), .acknowledge(acknowledgeBeam[0]), .clock(clock), .debounce(debounce3));

    assign beamBroken3 = debounce3 ? 1'b0 : reading3; 

    //quarter 
    wire debounce4; //debounce stuff
    debounceUnit DEBBEAM4(.buttonNotPressed(~reading4), .acknowledge(acknowledgeBeam[0]), .clock(clock), .debounce(debounce4));

    assign beamBroken4 = debounce4 ? 1'b0 : reading4; 


    
    assign LED[0] = debounce1;
    assign LED[1] = debounce2;
    assign LED[2] = debounce3;
    assign LED[3] = debounce4;
endmodule

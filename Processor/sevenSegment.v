module sevenSegment (
    number,
    CA,
    CB,
    CC,
    CD,
    CE,
    CF,
    CG,
    DP,
    AN
);
input [31:0] number;
output CA, CB, CC, CD, CE, CF, CG, DP;
output [3:0] AN;


wire [15:0] decoded = 1 << number;

assign CA = decoded[1] | decoded[4];
assign CB = decoded[5] | decoded[6];
assign CC = decoded[2];
assign CD = decoded[1] | decoded[4] | decoded[7] | decoded[9];
assign CE = decoded[1] | decoded[3] | decoded[4] | decoded[5] | decoded[7] | decoded[9];
assign CF = decoded[1] | decoded[2] | decoded[3] | decoded[7];
assign CG = decoded[0] | decoded[1] | decoded[7];
assign DP = 1'b0;
assign AN[3:0] = 4'b0;


endmodule
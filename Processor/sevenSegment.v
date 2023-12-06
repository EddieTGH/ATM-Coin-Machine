module sevenSegment (
    seg0,
    seg1,
    seg2,
    seg3,
    CA,
    CB,
    CC,
    CD,
    CE,
    CF,
    CG,
    DP,
    AN,
    clock
);
input [31:0] seg0, seg1, seg2, seg3;
input clock;
output CA, CB, CC, CD, CE, CF, CG, DP;
output reg [3:0] AN;


wire [15:0] decoded0 = 1 << seg0;
wire [15:0] decoded1 = 1 << seg1;
wire [15:0] decoded2 = 1 << seg2;
wire [15:0] decoded3 = 1 << seg3;

integer i;


wire [15:0] decoded;
mux_4 #(16) MUX4(.out(decoded), .select(i[1:0]), .in0(decoded0), .in1(decoded1), .in2(decoded2), .in3(decoded3));
assign CA = decoded[1] | decoded[4];
assign CB = decoded[5] | decoded[6];
assign CC = decoded[2];
assign CD = decoded[1] | decoded[4] | decoded[7] | decoded[9];
assign CE = decoded[1] | decoded[3] | decoded[4] | decoded[5] | decoded[7] | decoded[9];
assign CF = decoded[1] | decoded[2] | decoded[3] | decoded[7];
assign CG = decoded[0] | decoded[1] | decoded[7];
assign DP = 1'b0;


initial begin
    i = 0;
    AN[3:0] = 4'b1111;
end

wire clk1KHz;
sevenSegmentClockDiv CLOCKDIV(.clk(clock), .clk_out(clk1KHz));

always @(posedge clk1KHz) begin
    AN[i] = 1'b1;
    if (i == 3) begin
        i = 0;
    end else begin
        i = i + 1;
    end
    AN[i] = 1'b0;
end


endmodule
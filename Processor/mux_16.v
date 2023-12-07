module mux_16 #(parameter WIDTH=1)(out, select, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15); 
    input [3:0] select;
    input [WIDTH-1:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
    output [WIDTH-1:0] out;
    wire [WIDTH-1:0] w1, w2;

    mux_8 #(WIDTH) first1(w1, select[2:0], in0, in1, in2, in3, in4, in5, in6, in7);
    mux_8 #(WIDTH) first2(w2, select[2:0], in8, in9, in10, in11, in12, in13, in14, in15);
    mux_2 #(WIDTH) second(out, select[3], w1, w2);
endmodule
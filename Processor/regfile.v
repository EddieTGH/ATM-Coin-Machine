module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB, LEDout //LED reg MAPPING
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;
	// LED Reg MAPPING
	output [13:0] LEDout;
	// LED Reg MAPPING

	// add your code here

	wire [31:0] decode_out;
	decoder_32 DECODE(.select(ctrl_writeReg), .enable(1'b1), .out(decode_out));
	wire [31:0] decode_out1;
	decoder_32 DECODE1(.select(ctrl_readRegA), .enable(1'b1), .out(decode_out1));
	wire [31:0] decode_out2;
	decoder_32 DECODE2(.select(ctrl_readRegB), .enable(1'b1), .out(decode_out2));

	wire [31:0] w2;
	register_regfile REG0(.data_writeReg(data_writeReg), .data_readReg(w2), .clk(clock), .write_enable(1'b0), .decode_result(decode_out[0]), .reset(ctrl_reset));
	tristate_buffer TB2(.in(32'b0), .enable(decode_out1[0]), .out(data_readRegA));
	tristate_buffer TB3(.in(32'b0), .enable(decode_out2[0]), .out(data_readRegB));

	genvar i;
	generate
		for (i = 1; i < 32; i = i + 1) begin
			wire [31:0] w1;
			register_regfile REG(.data_writeReg(data_writeReg), .data_readReg(w1), .clk(clock), .write_enable(ctrl_writeEnable), .decode_result(decode_out[i]), .reset(ctrl_reset));
			// LED Reg MAPPING
			if (i == 29) begin
			     assign LEDout = w1[13:0];
		    end
			// LED Reg MAPPING
			tristate_buffer TB(.in(w1), .enable(decode_out1[i]), .out(data_readRegA));
			tristate_buffer TB1(.in(w1), .enable(decode_out2[i]), .out(data_readRegB));
		end
	endgenerate

endmodule

// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/21/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: serial to parallel shift register

module flex_stp_sr
#(
	parameter NUM_BITS = 4, //4 bit MSB Stp shift register
	parameter SHIFT_MSB = 1 //TRUE
)

(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output reg [NUM_BITS - 1: 0] parallel_out
);
	reg [NUM_BITS - 1: 0] next_parallel_out;
always_comb begin: NEXT_STATE_LOGIC
	next_parallel_out = parallel_out;
	if (shift_enable) begin
		case(SHIFT_MSB)
			1'b1:
				next_parallel_out = {parallel_out[NUM_BITS - 2: 0], serial_in};
			1'b0:
				next_parallel_out = {serial_in, parallel_out[NUM_BITS - 1:1]};
		endcase
	end
end

always_ff @(negedge n_rst, posedge clk) begin
	if(!n_rst)
		parallel_out <= '1;
	else
		parallel_out <= next_parallel_out;
	end

endmodule

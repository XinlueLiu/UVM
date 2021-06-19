// $Id: $
// File name:   flex_counter.sv
// Created:     9/16/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter Design

module flex_counter
#(
  parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS - 1:0] rollover_val,
	output reg [NUM_CNT_BITS - 1:0] count_out,
	output reg rollover_flag
);

	reg[NUM_CNT_BITS - 1:0] next_countout;
	reg nextRollover;

always_comb begin : NEXT_STATE_LOGIC
	nextRollover = 0;
	next_countout = count_out;
	if (clear) begin
		next_countout = 0;
		nextRollover = 0;
	end else if (count_enable) begin
		if (count_out == rollover_val - 1) begin
			nextRollover = 1;
			next_countout = count_out + 1;
		end else if (count_out == rollover_val) begin
			next_countout = 1;
			nextRollover = 0;
		end else begin
			next_countout = count_out + 1;
			nextRollover = 0;
		end
	end
end

always_ff @ (negedge n_rst, posedge clk) begin
	if (!n_rst)
		count_out <= 0;
	else
		count_out <= next_countout;
	end

always_ff @ (negedge n_rst, posedge clk) begin
	if (!n_rst)
		rollover_flag <= 0;
	else
		rollover_flag <= nextRollover;
	end

endmodule 
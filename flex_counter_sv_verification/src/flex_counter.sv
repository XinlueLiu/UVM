// Created:     9/16/2019
// Modified:    6/18/2021

`include "flex_counter_if.svh"
`include "parameter_def.v"

module flex_counter
(
	input logic CLK, nRST, 
	flex_counter_if.flex_counter fcif
);

	logic	[`NUM_CNT_BITS - 1:0] next_countout;
	logic   next_rollover;

always_comb begin : NEXT_STATE_LOGIC
	next_rollover = 0;
	next_countout = fcif.count_out;
	if (fcif.clear) begin
		next_countout = 0;
		next_rollover = 0;
	end 
	
	if (fcif.count_enable) begin
		if (fcif.count_out == fcif.rollover_val - 1) begin
			next_rollover = 1;
			next_countout = fcif.count_out + 1;
		end else if (fcif.count_out == fcif.rollover_val) begin
			next_countout = 1;
			next_rollover = 0;
		end else begin
			next_countout = fcif.count_out + 1;
			next_rollover = 0;
		end
	end
end

always_ff @( posedge CLK, negedge nRST ) begin : COUNT_FLAG_TIM
	if (!nRST) begin
		fcif.count_out <= '0;
		fcif.rollover_flag <= '0;
	end else begin
		fcif.count_out <= next_countout;
		fcif.rollover_flag <= next_rollover;
	end
end

endmodule 
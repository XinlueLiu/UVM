// $Id: $
// File name:   timer.sv
// Created:     9/25/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Timing Controller

module timer
(
	input wire clk,
	input wire n_rst,
	input wire enable_timer,
	output reg shift_enable,
	output reg packet_done
);

flex_counter #(4) //count n times because n times faster
  CLOCK_COUNTER(
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(enable_timer),
    .rollover_val(4'd10),
    .rollover_flag(shift_enable),
    .clear(!enable_timer || packet_done)
  );

flex_counter #(4) //count k times because k useful bits
  BIT_COUNTER(
    .clk(clk),
    .n_rst(n_rst),
    .rollover_val(4'd9),
    .count_enable(shift_enable),
    .rollover_flag(packet_done),
    .clear(!enable_timer || packet_done)
  );

endmodule 
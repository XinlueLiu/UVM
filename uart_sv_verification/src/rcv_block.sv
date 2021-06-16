// $Id: $
// File name:   rcv_block.sv
// Created:     9/25/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Top Level Block

module rcv_block
(
	input wire clk,
	input wire n_rst,
	input wire serial_in,
	input wire data_read,
	output reg [7:0] rx_data,
	output reg data_ready,
	output reg overrun_error,
	output reg framing_error
);
	wire start_bit_detected;
	wire shift_enable;
	reg [7:0] data;
	reg stopbit;
	reg packet_done;
	reg sbc_clear;
	reg sbc_enable;
	reg load_buffer;
	reg enable_timer;

start_bit_det
  START_BIT_DETECTOR(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(serial_in),
    .start_bit_detected(start_bit_detected)
  );

sr_9bit
  SHIFT_REGISTER_9BIT(
    .clk(clk),
    .n_rst(n_rst),
    .shift_strobe(shift_enable),
    .serial_in(serial_in),
    .packet_data(data),
    .stop_bit(stopbit) 
  );

rcu
  RECEIVER_CONTROL_UNIT(
  .clk(clk),
  .n_rst(n_rst),
  .start_bit_detected(start_bit_detected),
  .packet_done(packet_done),
  .framing_error(framing_error),
  .sbc_clear(sbc_clear),
  .sbc_enable(sbc_enable),
  .load_buffer(load_buffer),
  .enable_timer(enable_timer)
  );

timer
  TIMING_CONTROLLER(
  .clk(clk),
  .n_rst(n_rst),
  .enable_timer(enable_timer),
  .shift_enable(shift_enable),
  .packet_done(packet_done)
  );

stop_bit_chk
  STOP_BIT_CHECKER(
  .clk(clk),
  .n_rst(n_rst),
  .sbc_clear(sbc_clear),
  .sbc_enable(sbc_enable),
  .stop_bit(stopbit),
  .framing_error(framing_error)
  );

rx_data_buff
  RX_DATA_BUFFER(
  .clk(clk),
  .n_rst(n_rst),
  .load_buffer(load_buffer),
  .packet_data(data),
  .data_read(data_read),
  .rx_data(rx_data),
  .data_ready(data_ready),
  .overrun_error(overrun_error)
  );

endmodule 
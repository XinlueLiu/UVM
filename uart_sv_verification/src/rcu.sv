// $Id: $
// File name:   rcu.sv
// Created:     9/25/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Receiver Control Unit(RCU)
module rcu
(
	input wire clk,
	input wire n_rst,
	input wire start_bit_detected,
	input wire packet_done,
	input wire framing_error,
	output reg sbc_clear,
	output reg sbc_enable,
	output reg load_buffer,
	output reg enable_timer
);

typedef enum bit [2:0] {IDLE, WAIT_CLK, TIMER_EN, CHECK_SBCEN, WAIT_FRAM, LOAD} stateType;

reg [2:0] STATE;
reg [2:0] NXT_STATE;

always_ff @ (negedge n_rst, posedge clk)
	begin: REG_LOGIC
	if (!n_rst)
		STATE <= IDLE;
	else
		STATE <= NXT_STATE;
end

always_comb
	begin: NXT_LOGIC
	NXT_STATE = STATE;

	case(STATE)
	IDLE: begin
		if (!start_bit_detected)
			NXT_STATE = IDLE;
		else if (start_bit_detected)
			NXT_STATE = WAIT_CLK;
		end
	WAIT_CLK: begin
		NXT_STATE = TIMER_EN;
		end
	TIMER_EN: begin
		if (!packet_done)
			NXT_STATE = TIMER_EN;
		else if (packet_done)
			NXT_STATE = CHECK_SBCEN;
		end
	CHECK_SBCEN: begin
		NXT_STATE = WAIT_FRAM;
		end
	WAIT_FRAM: begin
		if (!framing_error)
			NXT_STATE = LOAD;
		else if (framing_error)
			NXT_STATE = IDLE;
		end
	LOAD: begin
		NXT_STATE = IDLE;
	end
	endcase
end


always_comb
	begin: OUT_LOGIC
		sbc_clear = 1'b0;
		enable_timer = 1'b0;
		sbc_enable = 1'b0;
		load_buffer = 1'b0;
	case(STATE)
	WAIT_CLK: begin
		enable_timer = 1'b0;
		sbc_enable = 1'b0;
		load_buffer = 1'b0;
		sbc_clear = 1'b1;
		end
	TIMER_EN: begin
		enable_timer = 1'b1;
		sbc_clear = 1'b0;
		sbc_enable = 1'b0;
		load_buffer = 1'b0;
		end
	CHECK_SBCEN: begin
		sbc_enable = 1'b1;
		sbc_clear = 1'b0;
		enable_timer = 1'b0;
		load_buffer = 1'b0;
		end
	WAIT_FRAM: begin
		sbc_enable = 1'b1;
		sbc_clear = 1'b0;
		enable_timer = 1'b0;
		load_buffer = 1'b0;
		end
	LOAD: begin
		load_buffer = 1'b1;
		sbc_clear = 1'b0;
		enable_timer = 1'b0;
		sbc_enable = 1'b0;
		end

	endcase
end

endmodule 
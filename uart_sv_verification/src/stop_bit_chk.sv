// $Id: $
// File name:   stop_bit_chk.sv
// Created:     2/5/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: stop bit checker for UART RX Design

`timescale 1ns / 10ps

module stop_bit_chk
(
  input  wire clk,
  input  wire n_rst,
  input  wire sbc_clear,
  input  wire sbc_enable,
  input  wire stop_bit,
  output reg  framing_error
);

  reg nxt_framing_error;
  
  always @ (negedge n_rst, posedge clk)
  begin : REG_LOGIC
    if(1'b0 == n_rst)
    begin
      framing_error  <= 1'b0; // Initialize to inactive value
    end
    else
    begin
      framing_error <= nxt_framing_error;
    end
  end
  
  always @ (framing_error, sbc_clear, sbc_enable, stop_bit)
  begin : NXT_LOGIC
    // Set default value(s)
    nxt_framing_error <= framing_error;
    
    // Define override condition(s)
    if(1'b1 == sbc_clear) // Synchronus clear/reset takes top priority for value
    begin
      nxt_framing_error <= 1'b0;
    end
    else if(1'b1 == sbc_enable) // Stop bit checker is enabled
    begin
      if(1'b1 == stop_bit) // Proper stop bit -> framming error flag should be inactive
      begin
        nxt_framing_error <= 1'b0;
      end
      else // Improper stop bit -> framing error flag should be asserted
      begin
        nxt_framing_error <= 1'b1;
      end
    end
  end
  
  // No additional output logic is needed since output port is used as flip-flop

  // Input checking assertions
  always @ (clk, n_rst, sbc_clear, sbc_enable, stop_bit)
  begin
    #(0.2ns);
  
    assert((1'b0 == clk) || (1'b1 == clk))
    else
      $warning("Stop bit checker input clk is not a logic '1' or '0'");
    
    assert((1'b0 == n_rst) || (1'b1 == n_rst))
    else
      $warning("Stop bit checker input n_rst is not a logic '1' or '0'");
    
    assert((1'b0 == sbc_clear) || (1'b1 == sbc_clear))
    else
      $warning("Stop bit checker input sbc_clear is not a logic '1' or '0'");
    
    assert((1'b0 == sbc_enable) || (1'b1 == sbc_enable))
    else
      $warning("Stop bit checker input sbc_enable is not a logic '1' or '0'");
    
    assert((1'b0 == stop_bit) || (1'b1 == stop_bit))
    else
      $warning("Stop bit checker input stop_bit is not a logic '1' or '0'");
  end
endmodule

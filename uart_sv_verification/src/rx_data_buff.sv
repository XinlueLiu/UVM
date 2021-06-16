// $Id: $
// File name:   rx_data_buff.sv
// Created:     2/5/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: 8-bit data buffer for UART RX Design

`timescale 1ns / 10ps

module rx_data_buff
(
  input  wire clk,
  input  wire n_rst,
  input  wire load_buffer,
  input  wire [7:0] packet_data,
  input  wire data_read,
  output reg  [7:0] rx_data,
  output reg  data_ready,
  output reg  overrun_error,
  output reg  even_parity_bit
);
  reg bit_sum;
  integer j;
  always @(packet_data) begin
    bit_sum = 0;
    for (j = 0; j < 8; j++) begin
      if (packet_data[j] == 1'b1) begin
        bit_sum = bit_sum + 1;
      end
      if (j == 7) begin
        if (bit_sum % 2) begin  //if 1, odd
          even_parity_bit = 1'b1;
        end else begin
          even_parity_bit = 1'b0;
        end
      end
    end
  end

  reg [7:0] nxt_rx_data;
  reg nxt_overrun_error;
  reg nxt_data_ready;
  integer i;
  
  always @ (negedge n_rst, posedge clk)
  begin : REG_LOGIC
    if(1'b0 == n_rst)
    begin
      rx_data       <= '1;  // Initialize the rx_data buffer to have all bits be the idle line value
      data_ready    <= 1'b0;        // Initialize the data_ready flag to be inactive
      overrun_error <= 1'b0;        // Initialize the overrun_error flag to be inactive
    end
    else
    begin
      rx_data       <= nxt_rx_data;
      data_ready    <= nxt_data_ready;
      overrun_error <= nxt_overrun_error;
    end
  end

  always @ (rx_data, data_ready, overrun_error, packet_data, load_buffer, data_read)
  begin : NXT_LOGIC
    // Assign default values
    nxt_rx_data        <= rx_data;
    nxt_data_ready    <= data_ready;
    nxt_overrun_error  <= overrun_error;
    
    // Define override condition(s)
    // RX data logic
    if(1'b1 == load_buffer)
    begin
      nxt_rx_data <= packet_data;
    end
    
    // Data ready logic
    if(1'b1 == load_buffer)  // New data will be loaded on the next clock edge -> should always cause data_ready to be asserted
    begin
      nxt_data_ready <= 1'b1;
    end
    else if (1'b1 == data_read) // If new data is not going to be loaded on the next clk edge and the currently stored data is being read -> deassert the data ready flag
    begin
      nxt_data_ready <= 1'b0;
    end
    
    // Overrun Error logic
    if((1'b1 == load_buffer) && (1'b1 == data_ready) && (1'b0 == data_read)) // Loading new data, already have data loaded, and current data is not being read -> overrun will occur
    begin
      nxt_overrun_error <= 1'b1;
    end
    else if (1'b1 == data_read) // Currently stored data is being read -> clear any prior overrun error
    begin
      nxt_overrun_error <= 1'b0;
    end
  end  

  // No additional ouput logic is needed since port names are used for the flipflops directly
  
  // Input checking assertions
  always @ (clk, n_rst, load_buffer, data_read, packet_data)
  begin
    #(0.2ns);
  
    assert((1'b0 == clk) || (1'b1 == clk))
    else
      $warning("Rx data buffer input clk is not a logic '1' or '0'");
    
    assert((1'b0 == n_rst) || (1'b1 == n_rst))
    else
      $warning("Rx data buffer input n_rst is not a logic '1' or '0'");
    
    assert((1'b0 == load_buffer) || (1'b1 == load_buffer))
    else
      $warning("Rx data buffer input load_buffer is not a logic '1' or '0'");
    
    assert((1'b0 == data_read) || (1'b1 == data_read))
    else
      $warning("Rx data buffer input data_read is not a logic '1' or '0'");
    
    for(i = 0; i < 8; i++)
    begin
      assert((1'b0 == packet_data[i]) || (1'b1 == packet_data[i]))
      else
        $warning("Rx data buffer input packet_data[%d] is not a logic '1' or '0'", i);
    end
  end
  
endmodule

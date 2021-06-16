// $Id: $
// File name:   tb_rcv_block-starter.sv
// Created:     2/5/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: starter top level test bench provided for Lab 5

`timescale 1ns / 10ps

module tb_rcv_block();

  // Define parameters
  parameter CLK_PERIOD        = 2.5;
  parameter NORM_DATA_PERIOD  = (10 * CLK_PERIOD);
  
  localparam OUTPUT_CHECK_DELAY = (CLK_PERIOD - 0.2);
  localparam WORST_FAST_DATA_PERIOD = (NORM_DATA_PERIOD * 0.96);
  localparam WORST_SLOW_DATA_PERIOD = (NORM_DATA_PERIOD * 1.04);
  
  //  DUT inputs
  reg tb_clk;
  reg tb_n_rst;
  reg tb_serial_in;
  reg tb_data_read;
  
  // DUT outputs
  wire [7:0] tb_rx_data;
  wire tb_data_ready;
  wire tb_overrun_error;
  wire tb_framing_error;
  wire tb_parity_check;
  
  // Test bench debug signals
  // Overall test case number for reference
  integer tb_test_num;
  string  tb_test_case;
  // Test case 'inputs' used for test stimulus
  reg [7:0] tb_test_data;
  reg       tb_test_stop_bit;
  time       tb_test_bit_period;
  reg        tb_test_data_read;
  // Test case expected output values for the test case
  reg [7:0] tb_expected_rx_data;
  reg       tb_expected_framing_error;
  reg       tb_expected_data_ready;
  reg       tb_expected_overrun;
  reg       tb_expected_parity;

  integer i;
  
  // DUT portmap
  rcv_block DUT
  (
    .clk(tb_clk),
    .n_rst(tb_n_rst),
    .serial_in(tb_serial_in),
    .data_read(tb_data_read),
    .rx_data(tb_rx_data),
    .data_ready(tb_data_ready),
    .overrun_error(tb_overrun_error),
    .framing_error(tb_framing_error),
    .even_parity_bit(tb_parity_check)
  );
  
  // Tasks for regulating the timing of input stimulus to the design
  task send_packet;
    input  [7:0] data;
    input  stop_bit;
    input  time data_period;
    
    integer i;
  begin
    // First synchronize to away from clock's rising edge
    @(negedge tb_clk)
    
    // Send start bit
    tb_serial_in = 1'b0;
    #data_period;
    
    // Send data bits
    for(i = 0; i < 8; i = i + 1)
    begin
      tb_serial_in = data[i];
      #data_period;
    end
    
    // Send stop bit
    tb_serial_in = stop_bit;
    #data_period;
  end
  endtask
  
  task reset_dut;
  begin
    // Activate the design's reset (does not need to be synchronize with clock)
    tb_n_rst = 1'b0;
    
    // Wait for a couple clock cycles
    @(posedge tb_clk);
    @(posedge tb_clk);
    
    // Release the reset
    @(negedge tb_clk);
    tb_n_rst = 1;
    
    // Wait for a while before activating the design
    @(posedge tb_clk);
    @(posedge tb_clk);
  end
  endtask
  
  task check_outputs;
    input assert_data_read;
  begin
    // Don't need to syncrhonize relative to clock edge for this design's outputs since they should have been stable for quite a while given the 2 Data Period gap between the end of the packet and when this should be used to check the outputs
    assert(tb_expected_parity == tb_parity_check)
      $info("Test case %0d: parity bit correctly calculated", tb_test_num);
    else
      $error("Test case %0d: parity bit was not correctly calculated", tb_test_num);
    // Data recieved should match the data sent
    assert(tb_expected_rx_data == tb_rx_data)
      $info("Test case %0d: Test data correctly received", tb_test_num);
    else
      $error("Test case %0d: Test data was not correctly received", tb_test_num);
      
    // If and only if a proper stop bit is sent ('1') there shouldn't be a framing error.
    assert(tb_expected_framing_error == tb_framing_error)
      $info("Test case %0d: DUT correctly shows no framing error", tb_test_num);
    else
      $error("Test case %0d: DUT incorrectly shows a framing error", tb_test_num);
    
    // If and only if a proper stop bit is sent ('1') should there be 'data ready'
    assert(tb_expected_data_ready == tb_data_ready)
      $info("Test case %0d: DUT correctly asserted the data ready flag", tb_test_num);
    else
      $error("Test case %0d: DUT did not correctly assert the data ready flag", tb_test_num);
      
    // Check for the proper overrun error state for this test case
    if(1'b0 == tb_expected_overrun)
    begin
      assert(1'b0 == tb_overrun_error)
        $info("Test case %0d: DUT correctly shows no overrun error", tb_test_num);
      else
        $error("Test case %0d: DUT incorrectly shows an overrun error", tb_test_num);
    end
    else
    begin
      assert(1'b1 == tb_overrun_error)
        $info("Test case %0d: DUT correctly shows an overrun error", tb_test_num);
      else
        $error("Test case %0d: DUT incorrectly shows no overrun error", tb_test_num);
    end
    
    // Handle the case of the test case asserting the data read signal
    if(1'b1 == assert_data_read)
    begin
      // Test case is supposed to have data read asserted -> check for proper handling
      // Should synchronize away from rising edge of clock for asserting this input.
      @(negedge tb_clk);
      
      // Activate the data read input 
      tb_data_read <= 1'b1;
      
      // Wait a clock cycle before checking for the flag to clear
      @(negedge tb_clk);
      tb_data_read <= 1'b0;
      
      // Check to see if the data ready flag cleared
      assert(1'b0 == tb_data_ready)
        $info("Test case %0d: DUT correctly cleared the data ready flag", tb_test_num);
      else
        $error("Test case %0d: DUT did not correctly clear the data ready flag", tb_test_num);
    end
  end
  endtask
  
  always
  begin : CLK_GEN
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk = 1'b1;
    #(CLK_PERIOD / 2);
  end
//************************************************************************
  // Actual test bench process
  initial
  begin : TEST_PROC
    // Initialize all test bench signals
    tb_test_num               = -1;
    tb_test_case              = "TB Init";
    tb_test_data              = '1;
    tb_test_stop_bit          = 1'b1;
    tb_test_bit_period        = NORM_DATA_PERIOD;
    tb_test_data_read         = 1'b0;
    tb_expected_rx_data       = '1;
    tb_expected_data_ready    = 1'b0; 
    tb_expected_framing_error = 1'b0;
    tb_expected_overrun       = 1'b0;
    // Initilize all inputs to inactive/idle values
    tb_n_rst      = 1'b1; // Initially inactive
    tb_serial_in  = 1'b1; // Initially idle
    tb_data_read  = 1'b0; // Initially inactive
    
    // Get away from Time = 0
    #0.1; 

 //************************************************************************   
    // Test case 0: Basic Power on Reset
    tb_test_num  = 0;
    tb_test_case = "Power-on-Reset";
    
    // Power-on Reset Test case: Simply populate the expected outputs
    // These values don't matter since it's a reset test but really should be set to 'idle'/inactive values
    tb_test_data        = '1;
    tb_test_stop_bit    = 1'b1;
    tb_test_bit_period  = NORM_DATA_PERIOD;
    tb_test_data_read   = 1'b0;
    
    // Define expected ouputs for this test case
    // Note: expected outputs should all be inactive/idle values
    // For a good packet RX Data value should match data sent
    tb_expected_rx_data       = '1;
    // Valid stop bit ('1') -> Valid data -> Active data ready output
    tb_expected_data_ready    = 1'b0; 
    // Framing error if and only if bad stop_bit ('0') was sent
    tb_expected_framing_error = 1'b0;
    // Not intentionally creating an overrun condition -> overrun should be 0
    tb_expected_overrun       = 1'b0;
    tb_expected_parity        = 1'b0;
    
    // DUT Reset
    reset_dut;
    
    // Check outputs
    check_outputs(tb_test_data_read);
 //************************************************************************  
    // Test case 1: Normal data rate, Normal packet
    // Synchronize to falling edge of clock to prevent timing shifts from prior test case(s)
    @(negedge tb_clk);
    tb_test_num  += 1;
    tb_test_case = "Normal Data-Rate, Normal Packet";
    
    // Setup packet info for debugging/verificaton signals
    tb_test_data       = 8'b11110000;
    tb_test_stop_bit   = 1'b1;
    tb_test_bit_period = NORM_DATA_PERIOD;
    tb_test_data_read  = 1'b1;
    
    // Define expected ouputs for this test case
    // For a good packet RX Data value should match data sent
    tb_expected_rx_data       = tb_test_data;
    // Valid stop bit ('1') -> Valid data -> Active data ready output
    tb_expected_data_ready    = tb_test_stop_bit; 
    // Framing error if and only if bad stop_bit ('0') was sent
    tb_expected_framing_error = ~tb_test_stop_bit;
    // Not intentionally creating an overrun condition -> overrun should be 0
    tb_expected_overrun       = 1'b0;
    tb_expected_parity        = 1'b0;
    
    // DUT Reset
    reset_dut;
    
    // Send packet
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    
    // Wait for 2 data periods to allow DUT to finish processing the packet
    #(tb_test_bit_period * 2);
    
    // Check outputs
    check_outputs(tb_test_data_read);

    //************************************************************************   
    // Test case 2: Normal packet, WORST_FAST_DATA_PERIOD
    // Synchronize to falling edge of clock to prevent timing shifts from prior test case(s)
    @(negedge tb_clk);
    tb_test_num += 1;
    tb_test_case = "Max Fast Data-Rate, Normal Packet";
    
    // Setup packet info for debugging/verificaton signals
    tb_test_data       = 8'b01010100;
    tb_test_stop_bit   = 1'b1;
    tb_test_bit_period = WORST_FAST_DATA_PERIOD;
    tb_test_data_read  = 1'b1;
    
    // Define expected ouputs for this test case
    // For a good packet RX Data value should match data sent
    tb_expected_rx_data       = tb_test_data;
    // Valid stop bit ('1') -> Valid data -> Active data ready output
    tb_expected_data_ready    = tb_test_stop_bit; 
    // Framing error if and only if bad stop_bit ('0') was sent
    tb_expected_framing_error = ~tb_test_stop_bit;
    // Not intentionally creating an overrun condition -> overrun should be 0
    tb_expected_overrun       = 1'b0;
    tb_expected_parity        = 1'b1;
    
    // DUT Reset
    reset_dut;
    
    // Send packet
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    
    // Wait for 2 data periods to allow DUT to finish processing the packet
    #(tb_test_bit_period * 2);
    
    // Check outputs
    check_outputs(tb_test_data_read);
 
    // Append additonal test cases here (such as overrun case)

    //************************************************************************   
    // Test case 3: Normal packet, WORST_SLOW_DATA_PERIOD
    // Synchronize to falling edge of clock to prevent timing shifts from prior test case(s)
    /*@(negedge tb_clk);
    tb_test_num += 1;
    tb_test_case = "Max Fast Data-Rate, Normal Packet";
    
    // Setup packet info for debugging/verificaton signals
    tb_test_data       = 8'b10101010;
    tb_test_stop_bit   = 1'b1;
    tb_test_bit_period = WORST_SLOW_DATA_PERIOD;
    tb_test_data_read  = 1'b1;
    
    // Define expected ouputs for this test case
    // For a good packet RX Data value should match data sent
    tb_expected_rx_data       = tb_test_data;
    // Valid stop bit ('1') -> Valid data -> Active data ready output
    tb_expected_data_ready    = tb_test_stop_bit; 
    // Framing error if and only if bad stop_bit ('0') was sent
    tb_expected_framing_error = ~tb_test_stop_bit;
    // Not intentionally creating an overrun condition -> overrun should be 0
    tb_expected_overrun       = 1'b0;
    
    // DUT Reset
    reset_dut;
    
    // Send packet
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    
    // Wait for 2 data periods to allow DUT to finish processing the packet
    #(tb_test_bit_period * 2);
    
    // Check outputs
    check_outputs(tb_test_data_read);
 
    // Append additonal test cases here (such as overrun case)

    //************************************************************************  
    // Test case 4: Framing error with Normal data rate, Normal packet
    // Synchronize to falling edge of clock to prevent timing shifts from prior test case(s)
    @(negedge tb_clk);
    tb_test_num  += 1;
    tb_test_case = "Normal Data-Rate, Normal Packet";
    
    // Setup packet info for debugging/verificaton signals
    tb_test_data       = 8'b11010011;
    tb_test_stop_bit   = 1'b0;
    tb_test_bit_period = NORM_DATA_PERIOD;
    tb_test_data_read  = 1'b1;
    
    // Define expected ouputs for this test case
    // For a good packet RX Data value should match data sent
    tb_expected_rx_data       = '1;
    // Valid stop bit ('1') -> Valid data -> Active data ready output
    tb_expected_data_ready    = tb_test_stop_bit; 
    // Framing error if and only if bad stop_bit ('0') was sent
    tb_expected_framing_error = 1'b1;
    // Not intentionally creating an overrun condition -> overrun should be 0
    tb_expected_overrun       = 1'b0;
    
    // DUT Reset
    reset_dut;
    
    // Send packet
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    
    // Wait for 2 data periods to allow DUT to finish processing the packet
    #(tb_test_bit_period * 2);
    
    // Check outputs
    check_outputs(tb_test_data_read);
    //************************************************************************
    //test case 5: normal -> framing error (-> normal)
    @(negedge tb_clk);
    tb_test_num += 1;
    tb_test_case = "normal -> framing error";
    tb_test_data       = 8'b11110000;
    tb_test_stop_bit   = 1'b1;
    tb_test_bit_period = NORM_DATA_PERIOD;
    tb_test_data_read  = 1'b1;

    tb_expected_rx_data       = tb_test_data;
    tb_expected_data_ready    = tb_test_stop_bit; 
    tb_expected_framing_error = 1'b0;
    tb_expected_overrun       = 1'b0;
    reset_dut;
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    #(tb_test_bit_period * 2);
    check_outputs(tb_test_data_read);
    
    tb_test_data       = 8'b11010011;
    tb_test_stop_bit   = 1'b0;
    tb_test_bit_period = NORM_DATA_PERIOD;
    tb_test_data_read  = 1'b1;

    tb_expected_rx_data = 8'b11110000; //should it output previous data(11110000) or or 1?
    tb_expected_framing_error = 1'b1;
    tb_expected_overrun       = 1'b0;
    tb_expected_data_ready    = tb_test_stop_bit;
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    #(tb_test_bit_period * 2);
    tb_serial_in = '1;
    check_outputs(tb_test_data_read);

    tb_test_data       = 8'b11010010;
    tb_test_stop_bit   = 1'b1;
    tb_test_bit_period = NORM_DATA_PERIOD;
    tb_test_data_read  = 1'b1;

    tb_expected_rx_data = tb_test_data; //should it output previous data or or 1?
    tb_expected_framing_error = 1'b0;
    tb_expected_overrun       = 1'b0;
    tb_expected_data_ready    = tb_test_stop_bit;
    send_packet(tb_test_data, tb_test_stop_bit, tb_test_bit_period);
    #(tb_test_bit_period * 2);
    check_outputs(tb_test_data_read);*/
 $finish();

end
endmodule

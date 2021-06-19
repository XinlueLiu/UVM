
// 337 TA Provided Lab 4 Testbench
// This code serves as a starer test bench for the synchronizer design
// STUDENT: Replace this message and the above header section with an
// appropriate header based on your other code files

// 0.5um D-FlipFlop Timing Data Estimates:
// Data Propagation delay (clk->Q): 670ps
// Setup time for data relative to clock: 190ps
// Hold time for data relative to clock: 10ps

`timescale 1ns / 10ps

module tb_flex_counter();

  // Define local parameters used by the test bench
  localparam NUM_CNT_BITS = 4;
  localparam  CLK_PERIOD    = 2.5;
  localparam  FF_SETUP_TIME = 0.190;
  localparam  FF_HOLD_TIME  = 0.100;
  localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  
  localparam  INACTIVE_VALUE     = 0;
  localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;
  integer i;
  
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst; 
  logic tb_clear;
  logic tb_count_enable;
  logic [NUM_CNT_BITS - 1:0] tb_rollover_val;
  reg [NUM_CNT_BITS - 1:0] tb_count_out;
  reg tb_rollover_flag;
  
  //reg tb_async_in;
  //wire tb_sync_out;
  
  // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;
  integer tb_stream_test_num;
  string tb_stream_check_tag;

  //Normal Clear Task(pulse the clear for 1 cycle)
  task clear_task;
  begin
  @(posedge tb_clk);
  tb_clear = 1'b1;
  @(posedge tb_clk);
  #(CLK_PERIOD);
  end
  endtask

  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_n_rst = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_n_rst = 1'b1;

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges, 
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Task to cleanly and consistently check DUT output values
  //check flag
  task check_output;
    input logic  [3:0]expected_value_count;
    input logic  expected_value_flag;
    input string check_tag;
  begin
    @(negedge tb_clk);
    if(expected_value_count == tb_count_out[NUM_CNT_BITS - 1:0]) begin // Check passed
      $info("Correct tb_count_out output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed-3 for not having explanation for 
      $error("Incorrect tb_count_out output %s during %s test case, %d, %d", check_tag, tb_test_case,expected_value_count,tb_count_out);
    end
    if(expected_value_flag == tb_rollover_flag) begin // Check passed
      $info("Correct tb_rollover_flag output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed-3 for not having explanation for 
      $error("Incorrect tb_rollover_flag output %s during %s test case, %d, %d", check_tag, tb_test_case,expected_value_count,expected_value_flag);
    end
  end
  endtask

  // Task to cleanly and consistently check for correct values during MetaStability Test Cases
  task check_output_meta;
    input string check_tag;
  begin
    // Only need to check that it's not a metastable value  decays are random
    if(('b1 == tb_count_out[NUM_CNT_BITS - 1:0]) || ('b0 == tb_count_out[NUM_CNT_BITS - 1:0])) begin // Check passed
      $info("Correct tb_count_out output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect tb_count_out output %s during %s test case", check_tag, tb_test_case);
    end
    if(('b1 == tb_rollover_flag) || ('b0 == tb_rollover_flag)) begin // Check passed
      $info("Correct expected_value_flag output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      $error("Incorrect expected_value_flag output %s during %s test case", check_tag, tb_test_case);
    end
  end
  endtask

  // Clock generation block
  always
  begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end
  
  // DUT Port map
  //sync_high DUT(.clk(tb_clk), .n_rst(tb_n_rst), .async_in(tb_async_in), .sync_out(tb_sync_out));
  flex_counter DUT(.CLK(tb_clk), .nRST(tb_n_rst), .clear(tb_clear), .count_enable(tb_count_enable), 
		.rollover_val(tb_rollover_val), .count_out(tb_count_out), .rollover_flag(tb_rollover_flag));

  // Test bench main process
  initial
  begin
    // Initialize all of the test inputs
    tb_n_rst  = 1'b1;              // Initialize to be inactive
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_rollover_val = 2;
    //tb_async_in  = INACTIVE_VALUE; // Initialize input to inactive  value
    tb_test_num = 0;               // Initialize test case counter
    tb_test_case = "Test bench initializaton";
    tb_stream_test_num = 0;
    tb_stream_check_tag = "N/A";
    // Wait some time before starting first test case
    #(0.1);
    
    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    //  localparam  INACTIVE_VALUE     = 2'b00;
    //  localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    //tb_async_in  = INACTIVE_VALUE; // Set to be the the non-reset value //1'b1
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_n_rst  = 1'b0;    // Activate reset
    tb_rollover_val = 2;
    
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.4);

    // Check that internal state was correctly reset
    check_output( RESET_OUTPUT_VALUE, RESET_OUTPUT_VALUE,
                  "after reset applied");
    
    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    check_output( RESET_OUTPUT_VALUE, RESET_OUTPUT_VALUE,
                  "after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(posedge tb_clk);
    #(FF_HOLD_TIME);
    tb_n_rst  = 1'b1;   // Deactivate the chip reset
    //tb_count_enable = 1'b1;
    #0.5;
    // Check that internal state was correctly keep after reset release
    check_output( RESET_OUTPUT_VALUE, RESET_OUTPUT_VALUE,
                  "after reset was released");


    // ************************************************************************
    // Test Case 2: Rollover for a rollover value that is not a power of two
    // ************************************************************************    
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Rollover for a rollover value that is not a power of two";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    //tb_async_in = INACTIVE_VALUE;

    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_n_rst  = 1'b0;    // Activate reset
    tb_rollover_val = 3;
    reset_dut();

    // Assign test case stimulus 
    @(posedge tb_clk);
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    #(3 * CLK_PERIOD);
    #(0.2);
    //#(FF_HOLD_TIME);
    
    // Wait for DUT to process stimulus before checking results
    //@(posedge tb_clk); 
    //@(posedge tb_clk); 
    // Move away from risign edge and allow for propagation delays before checking
    //#(CHECK_DELAY);
    // Check results
    check_output(3,1,
                  "Rollover for a rollover value that is not a power of two");
       // ************************************************************************    
    // Test Case 3: Continuous counting
    // ************************************************************************
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "Continuous counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_n_rst  = 1'b0;    // Activate reset
    tb_rollover_val = 2;
    reset_dut();
    //logic i;
 
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
	@(posedge tb_clk);
    	for(i = 0; i < 15; i++) begin
		#(0.1);
		check_output(i % tb_rollover_val + 1, (i % tb_rollover_val + 1)/ tb_rollover_val,"Continuous counting");
		@(posedge tb_clk);
    	end
    
    // ************************************************************************
    // Test Case 4: Discontinuous Counting
    // ************************************************************************
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "iscontinuous Counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_n_rst  = 1'b0;    // Activate reset
    tb_rollover_val = 10;
    reset_dut();
    //logic i;
 
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;

	for(i = 0; i < 15; i++) begin
		@(posedge tb_clk);
		#(0.1);
    		check_output((i/2 % tb_rollover_val +1), ((i % tb_rollover_val + 1)/ tb_rollover_val)/2,"Continuous counting");
		
		tb_count_enable = !tb_count_enable;
	end
    // ************************************************************************
    // Last Test Case: Clearing while counting to check clear vs. count enable priorit
    // ************************************************************************
    @(negedge tb_clk); 
    tb_test_num = tb_test_num + 1;
    tb_test_case = "iscontinuous Counting";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    tb_clear = 1'b0;
    tb_count_enable = 1'b0;
    tb_n_rst  = 1'b0;    // Activate reset
    tb_rollover_val = 10;
    reset_dut();
    //logic i;
 
    tb_n_rst = 1'b1;
    tb_count_enable = 1'b1;
    @(posedge tb_clk);
    #(3*CLK_PERIOD);
    clear_task();
    check_output(0,0,
                  "Clear task");
  end
endmodule 

//flex_counter design files
`include "flex_counter.sv"
//parameter files
`include "parameter_def.sv"
//interface file
`include "flex_counter_if.svh"

`include "uvm_macros.svh"
`include "fc_test.sv"

`timescale 1ns/1ps

module tb_flex_counter;
    import uvm_pkg::*;
    logic CLK, nRST;

    //clock generation
    initial begin
        CLK <= 0;
        forever begin
            #5 CLK <= !CLK;
        end
    end

    //reset generation
    initial begin
        #10 nRST <= 0;
        repeat(10) @(posedge CLK);
        nRST <= 1;
    end

    //interface
    flex_counter_if fcif(.CLK(CLK));

    //DUT
    flex_counter DUT(
        .CLK(CLK),
        .nRST(nRST),
        .fcif(fcif)
    );

    initial begin
        //set the interface
        uvm_config_db#(virtual flex_counter_if)::set(null, "", "vif", fcif);
        //initiate the tes t
        run_test("fc_test");      
    end

endmodule
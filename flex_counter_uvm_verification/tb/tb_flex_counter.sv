
import uvm_pkg::*;
`include "uvm_macros.svh"
//flex_counter design files
`include "flex_counter.sv"
//parameter files
`include "parameter_def.sv"
//interface file
`include "flex_counter_if.svh"
`include "fc_test.sv"

`timescale 1ns/1ps

module tb_flex_counter;
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
        //pass the interface down to the components
        //static set. type of value, prefix, path, field name, and value. 
        //prefix+path will get the hierarchy path
        uvm_config_db#(virtual flex_counter_if)::set(null, "", "fcif", fcif);
        //if (!uvm_config_db#(virtual flex_counter_if)::set(null, "", "fcif", fcif)) begin
            //`uvm_fatal("uvm_tb", "set interface failed at uvm_top")       
        //end
       
        //create an instance of the fc_test class and execute the specific test
        run_test("fc_test");      
    end

endmodule
/*
This is the top level module that generates CLK and nRST signal. It also 
instantiate the DUT and the interface, and connect them together. In addition, it also instantiates
the UVM_test module and pass the interface down to the components.
*/

/*uvm_pkg contains all uvm classes needed to build the verification environment. When we import the uvm_pkg, all the predefined
classess are available to use. So everyone uses similar modeling and code becomes more readable. 
So we are deriving objects from the predefined classes from uvm_pkg, register our variables with uvm_factory,
and use predefined tasks and functions. 
*/
import uvm_pkg::*;
`include "uvm_macros.svh"
//include the fifo design .sv file
`include "fifo.sv"
//include the interface file
`include "fifo_if.svh"
//include the parameter file
`include "fifo_param_pkg.svh"
//include the uvm_test file
`include "fifo_test.sv"

`timescale 1ps/1ps
module tb_fifo;
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

    //instantiate the interface
    fifo_if syn_fifo_if(.CLK(CLK));

    //instantiate the DUT
    fifo DUT(
        .CLK(CLK),
        .nRST(nRST),
        .syn_fifo_if(syn_fifo_if)
    );

    initial begin
        //This uvm_config_db can transfer from one layer to another layer
        //static set. type of value, prefix, path, field name, and value. 
        //prefix+path will set/get the hierarchy path
        //so it passes the interface down to the components

        //a virtual interface instantiates an actual interface. Because interface is static and classes are dynamic, we cannot declare interface within classes, 
        //but we can refer to the interface(declare a virtual interface to point to the interface)
        //"virtual interfaces provide a mechanism for separating abstract models and test programs from the actual signals that make up the design"
        uvm_config_db#(virtual fifo_if)::set(this, "*", "syn_fifo_if", syn_fifo_if);
        //create an instance of the fc_test class and execute the specific test
        run_test("fifo_basic_test");
    end
    
endmodule
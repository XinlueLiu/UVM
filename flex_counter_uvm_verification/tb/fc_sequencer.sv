import uvm_pkg::*;
`include "uvm_macros.svh"
`include "flex_counter_if.svh"
`include "fc_transaction.sv"

class fc_sequence extends uvm_sequence #(fc_transaction);
    `uvm_object_utils(fc_sequence)   

    function new(string name = "fc_sequence");
        super.new(name);
    endfunction: new

    task body();
        fc_transaction fc_item;
        fc_item = fc_transaction::type_id::create("fc_item");
        repeat(10) begin
            start_item(fc_item);
            if (!fc_item.randomize()) begin
                `uvm_fatal("sequence_item_randomization", "cannot randomize inputs of fc_item");            
            end
            finish_item(fc_item);
        end
    endtask : body
    
endclass: fc_sequence

class fc_sequencer extends uvm_sequencer #(fc_transaction);
    `uvm_component_utils(fc_sequencer)

    function new (input string name = "fc_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
endclass : fc_sequencer
    
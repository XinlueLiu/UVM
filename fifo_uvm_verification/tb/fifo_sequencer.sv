import uvm_pkg::*;
`include "uvm_macros.svh"

`include "fifo_transaction.svh"

class fifo_sequencer exxtends uvm_sequencer#(fifo_transaction)
    `uvm_component_utils(fifo_sequencer)
 
   function new(input string name= "fifo_sequencer", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new
endclass: fifo_sequencer
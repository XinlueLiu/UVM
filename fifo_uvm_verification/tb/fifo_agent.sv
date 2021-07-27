import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_sequencer.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"

class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)
    fifo_sequencer sqr;
    fifo_driver drv;
    fifo_monitor mon;

    function new(string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //virtual function
    function void build_phase(uvm_phase phase);
        //if this UVM agent is active, then build the driver and sequencer
        if (get_is_active()) begin
            sqr = fifo_sequencer::type_id::create("sqr", this);
            dvr = fifo_driver::type_id::create("dvr", this);
        end
        mon = fifo_monitor::type_id::create("mon", this);
    endfunction 

    function void connect_phase(uvm_phase phase);
        //use uvm_seq_item to let a sequencer communicate with the driver
        dvr.seq_item_port.connnect(sqr.seq_item_export);
    endfunction
    
endclass
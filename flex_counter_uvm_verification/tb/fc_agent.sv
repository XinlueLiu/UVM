import uvm_pkg::*;
`include "uvm_macros.svh"
`include "flex_counter_if.svh"
`include "fc_sequencer.sv"
`include "fc_driver.sv"
`include "fc_monitor.sv"

class fc_agent extends uvm_agent;
    //register
    `uvm_component_utils(fc_agent)

    virtual flex_counter_if fcif;
    fc_sequencer fc_sqr;
    fc_driver fc_drv;
    fc_monitor fc_mon;

    function new(string name = "fc_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        fc_sqr = fc_sequencer::type_id::create("fc_sqr", this);
        fc_drv = fc_driver::type_id::create("fc_drv", this);
        fc_mon = fc_monitor::type_id::create("fc_mon", this);

        //get the interface and pass the interface down
        /*if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
            `uvm_fatal("uvm_agt", "failed to get interface from uvm_env")
        end
        uvm_config_db#(virtual flex_counter_if)::set(this, "fc_sqr", "fcif", fcif);
        uvm_config_db#(virtual flex_counter_if)::set(this, "fc_drv", "fcif", fcif);
        uvm_config_db#(virtual flex_counter_if)::set(this, "fc_mon", "fcif", fcif);*/
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        //connect the driver to the sequencer and communicate throught the sequence item port
        fc_drv.seq_item_port.connect(fc_sqr.seq_item_export);
    endfunction
    
endclass :fc_agent

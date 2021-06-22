import uvm_pkg::*;
`include "uvm_macros.svh"
`include "flex_counter_if.svh"
`include "fc_transaction.sv"

class fc_driver extends uvm_driver #(fc_transaction)
    `uvm_component_utils(fc_driver)

    virtual flex_counter_if fcif;
    
    function new(string name = "fc_driver", uvm_component parent);
		super.new(name, parent);
	endfunction: new

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
            `uvm_fatal("uvm_drv", "failed to get interface from uvm_agt")
        end
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        forever begin
            fc_transaction fc_tx;
            @(posedge fcif.driver_ck);
            seq_item_port.get_next_item(fc_tx);
            fcif.clear = fc_tx.clear;
            fcif.count_enable = fc_tx.count_enable;
            fcif.rollover_val = fc_tx.rollover_val;
            @(posedge fcif.driver_ck);
            seq_item_port.item_done(); //transaction complete
        end
    endtask : run_phase

endclass : fc_driver
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_transaction.sv"
`include "flex_counter_if.svh"

class fc_monitor extends uvm_monitor;
    `uvm_component_utils(fc_monitor)

    uvm_analysis_port #(fc_transaction) mon_ap;
    uvm_analysis_port #(fc_transaction) mon_result_ap;
    virtual flex_counter_if fcif;

    function new(string name = "fc_monitor", uvm_component parent);
        super.new(name, parent);
        mon_ap =  new("mon_ap", this);
        mon_result_ap = new("mon_result_ap", this);
    endfunction : new

    function void build_phase (uvm_phase phase);
        if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
            `uvm_fatal("uvm_drv", "failed to get interface from uvm_agt")
        end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            fc_transaction fc_tx;
            @(posedge fcif.monitor_ck);
            fc_tx = fc_transaction::type_id::create("fc_tx");
            fc_tx.clear = fcif.clear;
            fc_tx.count_enable = fcif.count_enable;
            fc_tx.rollover_val = fcif.rollover_val;
            //fc_tx.count_out = fcif.count_out;
            //fc_tx.rollover_flag = fcif.rollover_flag;
            if ((fc_tx.clear != 'X) && (fc_tx.count_enable != 'X) && (fc_tx.rollover_val != 'X)) begin
                mon_ap.write(fc_tx);
                @(posedge fcif.monitor_ck);
                fc_tx.count_out = fcif.count_out;
                fc_tx.rollover_flag = fcif.rollover_flag;
                mon_result_ap.write(fc_tx);               
            end
        end
    endtask : run_phase

endclass : fc_monitor
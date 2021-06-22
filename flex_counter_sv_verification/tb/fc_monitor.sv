import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_transaction.sv"

class fc_monitor extends uvm_monitor;
    `uvm_component_utils(fc_monitor)

    uvm_analysis_port #(fc_transaction) mon_ap;
    uvm_analysis_port #(fc_transaction) mon_result_ap;

    function new(string name = "fc_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase (uvm_phase phase);
        mon_ap =  new("mon_ap", this);
        mon_result_ap = new("mon_result_ap", this);
        if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
            `uvm_fatal("uvm_drv", "failed to get interface from uvm_agt")
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            fc_transaction fc_tx;
            @(posedge fcif.driver_ck);
            fc_tx = fc_transaction::type_id::create("fc_tx");
            fc_tx.clear = fcif.clear;
            fc_tx.count_enable = fcif.count_enable;
            fc_tx.rollover_val = fcif.rollover_val;
            fc_tx.count_out = fcif.count_out;
            fc_tx.rollover_flag = fcif.rollover_flag;
            mon_ap.write(fc_tx);

            @(posedge fcif.driver_ck);
            @(posedge fcif.driver_ck);
            @(posedge fcif.driver_ck);
            fc_tx.count_out = fcif.count_out;
            fc_tx.rollover_flag = fcif.rollover_flag;
            mon_result_ap.write(fc_tx);
        end
    endtask : run_phase
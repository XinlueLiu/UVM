import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_transaction.sv"

class fc_predictor extends uvm_subscriber #(fc_transaction);
    `uvm_component_utils(fc_predictor)

    uvm_analysis_port #(fc_transaction) fc_pred_ap;

    function new(string name = "fc_predictor", uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        fc_pred_ap = new("fc_pred_ap", this);
    endfunction

    function void write(fc_transaction t);
        fc_transaction fc_tx_output;
        fc_tx_output = fc_transaction::type_id::create("fc_tx_output", this);
        fc_tx_output.copy(t);
        fc_tx_output.count_out = 1'b1; //to be changed
        fc_tx_output.rollover_flag = 1'b0;
        fc_pred_ap.write(fc_tx_output);
    endfunction : write

endclass : fc_predictor
    
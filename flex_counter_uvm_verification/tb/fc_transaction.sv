`ifndef FC_TRANSACTION
`define FC_TRANSACTION

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "parameter_def.sv"

//  Class: fc_transaction
//
class fc_transaction extends uvm_sequence_item;
    `uvm_object_utils(fc_transaction)
    
    //input signals
    rand logic clear, count_enable;
    rand logic [`NUM_CNT_BITS - 1:0] rollover_val;

    //output signals
    logic [`NUM_CNT_BITS - 1:0] count_out;
    logic rollover_flag;

    constraint clear_count_enable {clear == 0 && count_enable == 1;}
    constraint rollover_val_set {rollover_val == 2;}

    function new(string name = "fc_transaction");
        super.new(name);
    endfunction: new

    function int compare_input(fc_transaction fc_tx_in);
        int result;
        if ((this.clear == fc_tx_in.clear) && (this.count_enable == fc_tx_in.count_enable) && (this.rollover_val == fc_tx_in.rollover_val)) begin
            result = 1;
        end else begin
            result = 0;
        end
        return result;
    endfunction

    function int compare_output(fc_transaction fc_tx_out);
        int result;
        if ((this.count_out == fc_tx_out.count_out) && (this.rollover_flag == fc_tx_out.rollover_flag)) begin
            result = 1;
        end else begin
            result = 0;
        end
        return result;
    endfunction
    
endclass: fc_transaction

`endif
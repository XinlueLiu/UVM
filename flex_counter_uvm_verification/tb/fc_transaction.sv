`ifndef FC_TRANSACTION
`define FC_TRANSACTION

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "parameter_def.sv"

class fc_transaction extends uvm_sequence_item;
    //input signals
    rand logic clear, count_enable;
    rand logic [`NUM_CNT_BITS - 1:0] rollover_val;

    //output signals
    logic [`NUM_CNT_BITS - 1:0] count_out;
    logic rollover_flag;

    //to use build-in functions, such as print to debug
    `uvm_object_utils_begin(fc_transaction)
        `uvm_field_int(clear, UVM_ALL_ON)
        `uvm_field_int(count_enable, UVM_ALL_ON)
        `uvm_field_int(rollover_val, UVM_ALL_ON)
        `uvm_field_int(count_out, UVM_ALL_ON)
        `uvm_field_int(rollover_flag, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint clear_count_enable {clear == 0 && count_enable == 1;}
    constraint rollover_val_set {rollover_val == 1;}

    function new(string name = "fc_transaction");
        super.new(name);
    endfunction: new
    
endclass: fc_transaction

`endif
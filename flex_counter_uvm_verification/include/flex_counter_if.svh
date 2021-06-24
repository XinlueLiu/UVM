`ifndef FLEX_COUNTER_IF
`define FLEX_COUNTER_IF

`include "parameter_def.sv"

`timescale 1ns/1ps

interface flex_counter_if(input bit CLK);
    //input to flex_counter
    logic clear, count_enable;
    logic [`NUM_CNT_BITS - 1:0] rollover_val;
    //output of flex_counter
    logic [`NUM_CNT_BITS - 1:0] count_out;
    logic rollover_flag;

    clocking driver_ck @(posedge CLK);
        default input #1ns output #1ns;
        input count_out, rollover_flag;
        output clear, count_enable, rollover_val;
    endclocking: driver_ck

    clocking monitor_ck @(posedge CLK);
        default input #1ns output #1ns;
        input clear, count_enable, rollover_val, count_out, rollover_flag;
    endclocking: monitor_ck

    modport flex_counter (
    input clear,count_enable,rollover_val,
    output count_out, rollover_flag
    );
endinterface //flex_counter_if

`endif
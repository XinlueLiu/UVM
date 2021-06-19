`include "parameter_def.v"
interface flex_counter_if;
    logic clear, count_enable;
    logic [`NUM_CNT_BITS - 1:0] rollover_val;
    logic [`NUM_CNT_BITS - 1:0] count_out;
    logic rollover_flag;

    modport flex_counter (
    input clear,count_enable,rollover_val,
    output count_out, rollover_flag
    );
endinterface //flex_counter_if
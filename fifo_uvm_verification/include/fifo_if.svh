`ifndef FIFO_IF_SVH
`define FIFO_IF_SVH

`include "fifo_param_pkg.svh"

interface fifo_if;
    import fifo_param_pkg::*;

    //FIFO WRITE LOGIC
    //input signals
    logic fifo_wr_en; //write enable signal
    logic [FIFO_WIDTH - 1: 0] fifo_wr_data; //data to write to fifo memory
    logic fifo_rd_en; //read enable signal
    //output signals
    logic fifo_full; //enable to indicate that fifo is already fifo
    logic fifo_wr_err; //error signal(may be used when trying to write to fifo thats full)
    logic fifo_empty;
    logic fifo_rd_err;
    logic [FIFO_WIDTH - 1: 0] fifo_rd_data; //data to read from fifo memory

    modport fifo (
    input fifo_wr_en, fifo_wr_data, fifo_rd_en,
    output fifo_full, fifo_wr_err, fifo_empty, fifo_rd_err, fifo_rd_data
    );
    
endinterface //fifo_if

`endif //FIFO_IF_SVH
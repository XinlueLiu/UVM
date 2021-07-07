`ifndef FIFO_IF_SVH
`define FIFO_IF_SVH

`include "FIFO_param_pkg.svh"

interface fifo_if;
    import FIFO_param_pkg::*;

    //FIFO WRITE LOGIC
    //input signals
    logic fifo_wr_en; //write enable signal
    //output signals
    //to systemc
    logic fifo_full; //enable to indicate that fifo is already fifo
    logic fifo_wr_err; //error signal(may be used when trying to write to fifo thats full)
    //to fifo memory
    logic [WIDTH - 1: 0] fifo_wr_data; //data to write to fifo memory
    logic mem_wr_en; //write enable signal to fifo_memory

    //FIFO READ LOGIC
    logic fifo_rd_en; //read enable signal
    //output signals
    //to system
    logic fifo_empty;
    logic fifo_rd_err;
    //to fifo memory
    logic [WIDTH - 1: 0] fifo_rd_data; //data to read from fifo memory
    logic mem_rd_en; //read enable signal to fifo mempry

    //memory output
    logic mem_wr_err, mem_rd_err, mem_full, mem_empty;

    modport FIFO_wr (
    input fifo_wr_en, mem_wr_err, mem_full
    output fifo_full, fifo_wr_err, mem_wr_en
    );

    modport FIFO_rd (
    input fifo_rd_en, mem_rd_err, mem_empty
    output fifo_empty, fifo_rd_err, mem_rd_en
    );

    modport FIFO_mem (
    input mem_wr_en, mem_rd_en, fifo_wr_data,
    output fifo_rd_data, mem_wr_err, mem_rd_err, mem_full, mem_empty
    );
    
endinterface //fifo_if

`endif //FIFO_IF_SVH
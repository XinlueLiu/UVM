`ifndef FIFO_PARAM_PKG_SVH
`define FIFO_PARAM_PKG_SVH

package FIFO_param_pkg;
    parameter FIFO_WIDTH = 4; //4 bytes, 32 bits of FIFO width
    parameter FIFO_DEPTH = 32; //maximum depth of the FIFO
    parameter FIFO_ADDR = 5; //5 bits can be used to represent the address of the fifo
endpackage

`endif //FIFO_PARAM_PKG_SVH
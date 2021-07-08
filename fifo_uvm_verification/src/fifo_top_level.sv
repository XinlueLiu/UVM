`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

module fifo_top_level (
    input CLK, nRST, fifo_if.FIFO_wr fifo_wr, fifo_if.FIFO_rd fifo_rd, fifo_if.FIFO_mem fifo_mem
); 

fifo_read RD(
    .CLK(CLK),
    .nRST(nRST),
    .fifo_rd(fifo_rd)    
);

fifo_write WR(
    .CLK(CLK),
    .nRST(nRST),
    .fifo_wr(fifo_wr)
);

fifo_memory MEM(
    .CLK(CLK),
    .nRST(nRST),
    .fifo_mem(fifo_mem)
);
    
endmodule
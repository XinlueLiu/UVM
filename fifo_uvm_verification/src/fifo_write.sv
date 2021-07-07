`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

module fifo_write(
    input CLK, nRST, fifo_if.FIFO_wr fifo_wr;
);

always_ff @(posedge CLK , negedge nRST) begin
    if (!nRST) begin
        fifo_wr.fifo_full <= '0;
        fifo_wr.fifo_wr_err <= '0;
        fifo_wr.mem_wr_en <= '0;
    end else begin
        fifo_wr.fifo_full <= fifo_wr.mem_full;
        fifo_wr.fifo_wr_err <= fifo_wr.mem_wr_err;
        fifo_wr.mem_wr_en <= fifo_wr.fifo_wr_en;
    end
end
    
endmodule
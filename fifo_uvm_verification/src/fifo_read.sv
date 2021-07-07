`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

module fifo_read(
    input CLK, nRST, fifo_if.FIFO_rd fifo_rd
);
    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            fifo_rd.fifo_empty <= '0;
            fifo_rd.fifo_rd_err <= '0;
            fifo_rd.mem_rd_en <= '0;
        end else begin
            fifo_rd.fifo_empty <= fifo_rd.mem_empty;
            fifo_rd.fifo_rd_err <= fifo_rd.mem_rd_err;
            fifo_rd.mem_rd_en <= fifo_rd.fifo_rd_en;
        end
    end
    
endmodule
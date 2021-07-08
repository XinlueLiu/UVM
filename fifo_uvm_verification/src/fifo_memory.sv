`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

module fifo_memory (
    input CLK, nRST, fifo_if.FIFO_mem fifo_mem
);

//the functionality of the fifo memory is to queue the data into the fifo(when its not full)
//and dequeue the data from the memory(if the memory is not memory)
import FIFO_param_pkg::*;

//fifo_count to determine full or empty
logic [FIFO_ADDR - 1: 0] fifo_count;

//the 32 bytes depth and 4 bytes wide FIFO
logic [FIFO_DEPTH - 1: 0][FIFO_WIDTH - 1: 0] fifo_memory; 

//read pointer and write pointer to manipulate data
logic [FIFO_ADDR - 1: 0] rd_ptr;
logic [FIFO_ADDR - 1: 0] wr_ptr;

always_ff @(posedge CLK , negedge nRST) begin : COUNT_LOGIC
    if (!nRST) begin
        fifo_count <= '0;
    end else begin
        //if FIFO is not full and trying to write
        if ((fifo_count != FIFO_ADDR) && fifo_mem.mem_wr_en) begin
            fifo_count <= fifo_count + 1'b1;
        //if FIFO is not empty and trying to read
        end else if ((fifo_count != 0) && fifo_mem.mem_rd_en) begin
            fifo_count <= fifo_count - 1'b1;
        end else begin
            //default case
            //if FIFO is full and trying to write
            //if FIFO is empty and trying to read
            //if trying to read and write at the same time, fifo_count keeps the same
            fifo_count <= fifo_count;
        end
    end
end

always_ff @(posedge CLK , negedge nRST) begin : MEMORY_CONDITION_LOGIC
    if (!nRST) begin
        fifo_mem.mem_full <= '0;
        fifo_mem.mem_empty <= '0;
    end else begin
        if (fifo_count == FIFO_ADDR) begin
            fifo_mem.mem_full <= '1;
        end else if (fifo_count == '0) begin
            fifo_mem.mem_empty <= '1;
        end else begin
            //if neither, reset the signal
            fifo_mem.mem_empty <= '0;
            fifo_mem.mem_full <= '0;
        end
    end
end


always_ff @(posedge CLK , negedge nRST) begin : OUTPUT_LOGIC 
    if (!nRST) begin
        fifo_mem.fifo_rd_data <= '0;
        fifo_mem.mem_wr_err <= '0;
        fifo_mem.mem_rd_err <= '0;
        rd_ptr <= '0;
        wr_ptr <= '0;
        fifo_memory <= '0;
    end else begin
        //if rd_ptr or wr_ptr reaches the top, and if its not full
        //we wrap around the fifo
        //if trying to read and write at the same time
        if (fifo_mem.mem_wr_en && fifo_mem.mem_rd_en) begin
            fifo_memory[wr_ptr] <= fifo_mem.fifo_wr_data;
            fifo_mem.fifo_rd_data <= fifo_memory[rd_ptr];
        end else
        //if fifo is NOT full and trying to write
        if ((fifo_count != FIFO_ADDR) && fifo_mem.mem_wr_en) begin
            fifo_memory[wr_ptr] <= fifo_mem.fifo_wr_data;
            if (wr_ptr != '1) begin
                ++wr_ptr;
            end else begin
                wr_ptr <= '0;
            end
        //if fifo is NOT empty and trying to read
        end else if ((fifo_count != 0) && fifo_mem.mem_rd_en) begin
            fifo_mem.fifo_rd_data <= fifo_memory[rd_ptr];
            if (rd_ptr != '1) begin
                ++rd_ptr;
            end else begin
                rd_ptr <= '0;
            end
        end

        //if fifo is full and trying to write
        if ((fifo_count == FIFO_ADDR) && fifo_mem.mem_wr_en) begin
            fifo_mem.mem_wr_err <= '1;
        end 
        //if fifo is empty and trying to read
        if ((fifo_count == 0) && fifo_mem.mem_rd_en) begin
            //output all zeros as trying to read an empty fifo
            fifo_mem.fifo_rd_data <= '0;
            fifo_mem.mem_rd_err <= '1;
        end
        else begin
            //default case
            fifo_mem.fifo_rd_data <= fifo_mem.fifo_rd_data;
            fifo_mem.mem_wr_err <= fifo_mem.mem_wr_err;
            fifo_mem.mem_rd_err <= fifo_mem.mem_rd_err;
            fifo_memory <= fifo_memory;
        end
    end
end

endmodule
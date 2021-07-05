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
logic [FIFO_ADDR - 1: 0] nxt_fifo_count;

//the 32 bytes depth and 4 bytes wide FIFO
logic [FIFO_DEPTH - 1: 0][WIDTH - 1: 0] fifo_memory; 
logic [FIFO_DEPTH - 1: 0][WIDTH - 1: 0] nxt_fifo_memory; 

//read pointer and write pointer to manipulate data
logic [FIFO_ADDR - 1: 0] rd_ptr;
logic [FIFO_ADDR - 1: 0] nxt_rd_ptr;
logic [FIFO_ADDR - 1: 0] wr_ptr;
logic [FIFO_ADDR - 1: 0] nxt_wr_ptr;

always_ff @( posedge CLK, negedge nRST ) begin : COUNT_LOGIC
    if (!nRST) begin
        fifo_count <= '0;
        fifo_memory <= '0;
        rd_ptr <= '0;
        wr_ptr <= '0;
    end else begin
        fifo_count <= nxt_fifo_count;
        fifo_memory <= nxt_fifo_memory;
        rd_ptr <= nxt_rd_ptr;
        wr_ptr <= nxt_wr_ptr;
    end
end

always_comb begin : NXT_COUNT_LOGIC
    nxt_fifo_count = fifo_count;
    nxt_fifo_memory = fifo_memory;
    nxt_rd_ptr = rd_ptr;
    nxt_wr_ptr = wr_ptr;
    casez ({mem_rd_en, mem_wr_en})
        2'b01 : begin
            //wrap around condition when fifo_count < FIFO_DEPTH but wr_ptr || rd_ptr has reached the FIFO_DEPTH        
            if (wr_ptr == FIFO_DEPTH) begin
                nxt_wr_ptr = 0;
            end
            //when only memory write signal is asserted
            if (fifo_count < FIFO_DEPTH) begin
                nxt_fifo_memory[wr_ptr] = fifo_wr_data;
                nxt_fifo_count++;
                //increment the write pointer
                nxt_wr_ptr++;
            end else begin
                fifo_mem.wr_full_err = 1'b1; //assert fifo_full error
            end
        end
        2'b10 : begin
            //wrap around condition
            if (rd_ptr == FIFO_DEPTH) begin
                nxt_rd_ptr = 0;
            end
            if (fifo_count > 0) begin
                fifo_mem.fifo_rd_data = fifo_memory[rd_ptr];
                nxt_fifo_count--;
                //increment the read pointer
                nxt_rd_ptr++;
            end else begin
                fifo_mem.rd_empty_err = 1'b1; //assert fifo_empty error
            end
        end
        2'b11 : begin
            //will not generate wr_full_err or rd_empty_err because we are reading and writing
            nxt_fifo_memory[wr_ptr] = fifo_wr_data;
            fifo_mem.fifo_rd_data = fifo_memory[rd_ptr];
        end
    endcase
end
endmodule
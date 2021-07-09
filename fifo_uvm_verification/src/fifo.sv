`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

module fifo (
    input CLK, nRST, fifo_if.fifo syn_fifo_if
);
    import fifo_param_pkg::*;

    //fifo_count to determine full or empty
    logic [FIFO_ADDR - 1: 0] fifo_count;

    //the 32 bytes depth and 4 bytes wide FIFO
    logic [FIFO_DEPTH - 1: 0][FIFO_WIDTH - 1: 0] fifo_memory; 

    //read pointer and write pointer to manipulate data
    logic [FIFO_ADDR - 1: 0] rd_ptr;
    logic [FIFO_ADDR - 1: 0] wr_ptr;
    logic [3:0] caseCondition;
    assign caseCondition = {syn_fifo_if.fifo_wr_en, syn_fifo_if.fifo_rd_en, (fifo_count == FIFO_DEPTH - 1),(fifo_count == 0)};

    always_ff @(posedge CLK , negedge nRST) begin : COUNT_LOGIC
        if (!nRST) begin
            fifo_count <= '0;
        end else begin
            //default case
            //if FIFO is full and trying to write
            //if FIFO is empty and trying to read
            //if trying to read and write at the same time, fifo_count keeps the same
            fifo_count <= fifo_count;
            //if FIFO is not full and trying to write
            if ((fifo_count != FIFO_DEPTH - 1) && syn_fifo_if.fifo_wr_en) begin
                fifo_count <= fifo_count + 1'b1;
            //if FIFO is not empty and trying to read
            end else if ((fifo_count != 0) && syn_fifo_if.fifo_rd_en) begin
                fifo_count <= fifo_count - 1'b1;
            end
                
        end
    end

    always_ff @(posedge CLK , negedge nRST) begin : MEMORY_CONDITION_LOGIC
        if (!nRST) begin
            syn_fifo_if.fifo_full <= '0;
            syn_fifo_if.fifo_empty <= '0;
        end else begin
            syn_fifo_if.fifo_empty <= syn_fifo_if.fifo_empty;
            syn_fifo_if.fifo_full <= syn_fifo_if.fifo_full;
            if (fifo_count == FIFO_DEPTH - 1) begin
                syn_fifo_if.fifo_full <= '1;
            end else begin
                syn_fifo_if.fifo_full <= '0;
            end
            if (fifo_count == '0) begin
                syn_fifo_if.fifo_empty <= '1;
            end else begin
                syn_fifo_if.fifo_empty <= '0;
            end
        end
    end
    

    always_ff @(posedge CLK , negedge nRST) begin : OUTPUT_LOGIC 
        if (!nRST) begin
            syn_fifo_if.fifo_rd_data <= '0;
            syn_fifo_if.fifo_wr_err <= '0;
            syn_fifo_if.fifo_rd_err <= '0;
            rd_ptr <= '0;
            wr_ptr <= '0;
            fifo_memory <= '0;
        end else begin
            //if rd_ptr or wr_ptr reaches the top, and if its not full
            //we wrap around the fifo
            //if trying to read and write at the same time
            syn_fifo_if.fifo_wr_err <= '0;
            syn_fifo_if.fifo_rd_err <= '0;
            //default case
            casez (caseCondition)
                4'b11??: begin
                    fifo_memory[wr_ptr] <= syn_fifo_if.fifo_wr_data;
                    syn_fifo_if.fifo_rd_data <= fifo_memory[rd_ptr];
                    
                end
                4'b100?: begin
                    fifo_memory[wr_ptr] <= syn_fifo_if.fifo_wr_data;
                    if (wr_ptr != '1) begin
                        ++wr_ptr;
                    end else begin
                        wr_ptr <= '0;
                    end
                end
                4'b01?0: begin
                    syn_fifo_if.fifo_rd_data <= fifo_memory[rd_ptr];
                    if (rd_ptr != '1) begin
                        ++rd_ptr;
                    end else begin
                        rd_ptr <= '0;
                    end
                end
                4'b101?: begin
                    syn_fifo_if.fifo_wr_err <= '1;
                end
                4'b01?1: begin
                    //output all zeros as trying to read an empty fifo
                    syn_fifo_if.fifo_rd_data <= '0;
                    syn_fifo_if.fifo_rd_err <= '1;
                end
                default: begin
                    syn_fifo_if.fifo_rd_data <= syn_fifo_if.fifo_rd_data;
                    syn_fifo_if.fifo_wr_err <= syn_fifo_if.fifo_wr_err;
                    syn_fifo_if.fifo_rd_err <= syn_fifo_if.fifo_rd_err;
                    fifo_memory <= fifo_memory;
                end
            endcase
        end
    end

endmodule
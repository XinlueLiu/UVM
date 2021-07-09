`include "fifo_param_pkg.svh"
`include "fifo_if.svh"

`timescale 1ps/1ps

module tb_fifo ();
    import fifo_param_pkg::*;

    parameter PERIOD = 10;
    logic CLK = 0, nRST;

    int tb_test_num;
    string tb_test_case;

    bit [3:0] i;
    integer j,k;

    //clock generation
    always #(PERIOD / 2) CLK++;

    fifo_if fifo_if();

    fifo DUT(
        .CLK(CLK), 
        .nRST(nRST),
        .syn_fifo_if(fifo_if)
    );
    
    task reset_dut;
        begin
            nRST = 1'b0;
            @(posedge CLK);
            @(posedge CLK);

            @(negedge CLK);
            nRST = 1'b1;
            @(posedge CLK);
            @(posedge CLK);
        end
    endtask

    initial begin
        tb_test_num = -1;
        tb_test_case = "TB_test_init";
        fifo_if.fifo_wr_en = '0;
        fifo_if.fifo_rd_en = '0;
        fifo_if.fifo_wr_data = '0;
        i = '0;
        reset_dut();

        //test1, write 2 times
        @(posedge CLK);
        tb_test_num++;
        tb_test_case = "test1, write 2 times";
        fifo_if.fifo_wr_en = '1;
        fifo_if.fifo_wr_data = ++i;
        //wait a clock for mem_wr_en to be asserted
        @(posedge CLK);
        fifo_if.fifo_wr_data = ++i;
        @(posedge CLK);
        fifo_if.fifo_wr_en = '0;
        
        //test2, read 2 times
        //read requires one more cycle to proceed
        tb_test_num++;
        tb_test_case = "test2, read 2 times";
        fifo_if.fifo_rd_en = '1;
        repeat(2) @(posedge CLK);
        fifo_if.fifo_rd_en = '0;
        repeat(2) @(posedge CLK);
        //test3, write and read at the same time
        tb_test_num++;
        tb_test_case = "test3, write and read at the same time";
        fifo_if.fifo_wr_en = '1;
        fifo_if.fifo_rd_en = '1;
        fifo_if.fifo_wr_data = ++i;
        repeat(4) @(posedge CLK);
        //fifo_if.fifo_wr_data = ++i;
        //repeat(2) @(posedge CLK);
        fifo_if.fifo_wr_en = '0;
        fifo_if.fifo_rd_en = '0;
        reset_dut();
        //test4, write more than 32 times
        tb_test_num++;
        tb_test_case = "test4, write more than 32 times";
        fifo_if.fifo_wr_en = '1;
        for (j = 0; j < 37; ++j) begin
            @(posedge CLK);
            fifo_if.fifo_wr_data = ++i;
        end
        @(posedge CLK);
        fifo_if.fifo_wr_en = '0;
        repeat(4) @(posedge CLK);

        //test5, read more than 32 times
        tb_test_num++;
        tb_test_case = "test5, read more than 32 times";
        fifo_if.fifo_rd_en = '1;
        repeat(40) @(posedge CLK);
        fifo_if.fifo_wr_en = '0;
        repeat(4) @(posedge CLK);
        $finish();
    end

endmodule
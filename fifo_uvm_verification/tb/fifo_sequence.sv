import uvm_pkg::*;
`include "uvm_macros.svh"

`include "fifo_transaction.svh"

class fifo_sequence extends uvm_sequence#(fifo_transaction)
    `uvm_object_utils(fifo_sequence)
    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction fifo_data;
        fifo_data = fifo_transaction::type_id::create("fifo_data");

        repeat(4) begin
            start_item(fifo_data);
            if (!fifo_data.randomize()) begin
                `uvm_fatal(get_type_name(), "failed to randomize fifo data")
            end
            finish_item(fifo_data);
        end
    endtask: body
endclass:fifo_sequence
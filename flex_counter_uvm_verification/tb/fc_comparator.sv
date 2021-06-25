import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_transaction.sv"

class fc_comparator extends uvm_scoreboard;
    `uvm_component_utils(fc_comparator)

    uvm_analysis_export #(fc_transaction) expected_export; 
    uvm_analysis_export #(fc_transaction) actual_export; 
    uvm_tlm_analysis_fifo #(fc_transaction) expected_fifo;
    uvm_tlm_analysis_fifo #(fc_transaction) actual_fifo;
    
    int num_matches = 0;
    int num_mismatches = 0;

    function new(string name = "fc_comparator", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        expected_export = new("expected_export", this);
        actual_export = new("actual_export", this);
        expected_fifo = new("expected_fifo", this);
        actual_fifo = new("actual_fifo", this);
    endfunction 
    
    function void connect_phase(uvm_phase phase);
        expected_export.connect(expected_fifo.analysis_export);
        actual_export.connect(actual_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        fc_transaction expected_tx;
        fc_transaction actual_tx; 
        forever begin
          expected_fifo.get(expected_tx);
          actual_fifo.get(actual_tx);
          if(actual_tx.count_out == expected_tx.count_out) begin
            num_matches++;
            uvm_report_info("fc_comparator", "data match");
          end else begin
            num_mismatches++;
            uvm_report_error("fc_comparator", "data mismatch");
            actual_tx.print();
            expected_tx.print();
          end
        end
      endtask
    
      function void report_phase(uvm_phase phase);
        uvm_report_info("fc_comparator", $sformatf("Matches:    %0d", num_matches));
        uvm_report_info("fc_comparator", $sformatf("Mismatches: %0d", num_mismatches));
      endfunction

endclass : fc_comparator
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_agent.sv"
`include "fifo_comparator.sv"
`include "fifo_predictor.sv"
`include "fifo_transaction.sv"

class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    //instantiate the agent(contains sequencer, driver, and monitor), predictor, and comparator
    fifo_agent agt;
    fifo_predictor pred;
    fifo_comparator comp;

    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //create the instantiated components via type_id::create
        agt = fifo_agent::type_id::create("fifo_agent", this);
        pred = fifo_predictor::type_id::create("fifo_predictor", this);
        comp = fifo_comparator::type_id::create("fifo_comparator", this);
    endfunction

    function void connect_phase(uvm_phase);
        //connect the TLM ports between different components
        //the predictor, which derive from uvm_subscriber, already has an an export.
        agt.mon.stimulus_in_ap.connect(pred.analysis_export);
        pred.analysis_export.connect(comp.expected_export_imp); //connect the predictor to comparator
        agt.mon.result_ap.connect(comp.actual_export_imp); //connect monitor to comparator
    endfunction

endclass: fifo_env
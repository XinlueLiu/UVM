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

    function new(string name = "fifo_env", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //create the instantiated components via type_id::create
        agt = fifo_agent::type_id::create("fifo_agent", this);
        pred = fifo_predictor::type_id::create("fifo_predictor", this);
        comp = fifo_comparator::type_id::create("fifo_comparator", this);
    endfunction

    function void connect_phase(uvm_phase);
        /*
        UVM TLM: Transaction Level Modeling, a modeling style for abstraction and being able to represent data as transations and 
        changes in signals as transactions(read or write operation)
        -UVM provides a set of transaction-level communication interfaces that are used to connect between components such that 
        data packets can be transferred between them. It isolates a component from the changes in other components

        TLM interface ports "port" and "export" are used to send transactions objects cross different levels of testbench hierarchy
        -"port"s are used to initiate and forward packets to the top layer of the hierarchy
        -"export"s are used to accept and forward packets from top layer to destination

        uvm_analysis_port
        -A specialized TLM based class whose interface consists of a single function "write()" and can be embedded within any components
        -This port contains a list of analysis exports and it cycles through the list and calls the write() method of each connected export
        when component(e.g. monitor) calls analysis_port.write()
        -An analysis port may be connected to 0,1, or many analysis exports and allows a component to call write() method without
        depending on the number of connected exports
        
        */
        //connect the monitor to predictor.
        //Since predictor is derived from uvm_subscriber, it already has an analysis port implementation object predefined by the name analysis_export
        agt.mon.stimulus_in_ap.connect(pred.analysis_export);
        pred.pred_ap.connect(comp.expected_export); //connect the predictor to comparator
        agt.mon.result_ap.connect(comp.actual_export); //connect monitor to comparator
    endfunction

endclass: fifo_env
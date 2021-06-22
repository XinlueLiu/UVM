//import uvm_package
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_env.sv"

class fc_test extends uvm_test;
    //register to the factory
    `uvm_component_utils(fc_test)

    //instantiate virtual interface, the environment, and sequence to send
    virtual flex_counter_if fcif;
    fc_env env;
    fc_sequence seq;

    function new(string name = "fc_test", uvm_component parent);
       super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        //super.build_phase(phase);
        //create the instance env and seq
        env = fc_env::type_id::create("env", this);
        //sequence is uvm_object, so no parent
        seq = fc_sequence::type_id::create("seq");

        //get the interface to this scope
        if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
            `uvm_fatal("uvm_test", "failed to get interface from uvm_top")
        end

        //pass the virtual interface so any element looking for the virtual interface will get it
        if (!uvm_config_db#(virtual flex_counter_if)::set(this, "*", "fcif", fcif)) begin
            `uvm_fatal("uvm_test_down", "failed to pass interface down to other components")
        end
        
    endfunction: build_phase
    
    task run_phase (uvm_phase phase);
        phase.raise_objection(this, "raise objection for test");
        //the test will start the sequence. the argument is the sequencer we're gonna start
        //no parent argument since this is top level
        seq.start(env.fc_agt.sqr);
        phase.drop_objection(this, "drop objection for test");
    endtask :run_phase
    
endclass: fc_test
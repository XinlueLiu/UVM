//import uvm_package
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_env.sv"

class fifo_test extends uvm_test;
    //use macro to register component/object to the factory.
    //for easy type overriding without modifying base code
    //and we can use factory provided methods such as create, get_type_name,
    `uvm_component_utils(fifo_test)

    //instantiate virtual interface, the environment, and sequence to send
    virtual fifo_if syn_fifo_if;
    fifo_env env;
    fifo_sequence seq;

    function new(string name = "fifo_test", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //create the fifo_env instance and set this(fifo_test) as the parent
      //create vs new
      //create is the factory method used to construct objects for class derived from uvm_components and uvm_objects
      //works only if the class has been registered with the factory
      env = fifo_env::type_id::create("env", this);
      seq = fifo_sequence::type_id::create("seq");

      //get the interface from the config_db
      if (!uvm_config_db#(virtual fifo_if)::get(this, "", "syn_fifo_if", syn_fifo_if)) begin
          `uvm_fatal("fifo_test", "failed to get interface")
      end

      //TODO: remove this and see if the agent can get the interface
      uvm_config_db#(virtual fifo_if)::set(this, "*", "syn_fifo_if", syn_fifo_if);  
    endfunction: build_phase

    task run_phase (uvm_phase phase);
        //objections are for controlling when to stop the simulation(aka end the phase), but usually only the run phase consumes time
        //if no objections raised, simulation stops
        phase.raise_objection(this, "raise objection for basic test");
        $display("%t run_phase of fifo_test started", $time);
        //the sequence is started
        seq.start(env.agt.sqr);
        phase.drop_objection(this, "drop objection for basic test");
    endtask: run_phase
endclass: fifo_test
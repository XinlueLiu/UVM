//import uvm_package
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fc_env.sv"

class fc_test extends uvm_test;
    //register
     `uvm_component_utils(fc_test)

    fc_env env;
    virtual flex_counter_if fcif;

    function new(string name = "fc_test", uvm_component parent);
       super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fc_env::type_id::create("env", this);
        uvm_config_db#(virtual flex_counter_if)::get(this, inst_name, field_name, value);
        
        
    endfunction: build_phase
    
    
endclass: fc_test
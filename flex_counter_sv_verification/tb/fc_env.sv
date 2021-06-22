import uvm_pkg::*;
`include "uvm_macros.svh"
`include "flex_counter_if.svh"
`include "fc_agent.sv"
`include "fc_comparator.sv"
`include "fc_predictor.sv"
`include "fc_transaction.sv"

class fc_env extends uvm_env;
    `uvm_component_utils(fc_env)

    virtual flex_counter_if fcif;
    fc_agent fc_agt;
    fc_predictor fc_pred;
    fc_comparator fc_comp;

    function new(string name = "fc_env", uvm_component parent);
      super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        fc_agt = fc_agent::type_id::create("fc_agt", this);
        fc_pred = fc_predictor::type_id::create("fc_pred", this);
        fc_comp = fc_comparator::type_id::create("fc_comp", this);

        //get the interface and pass the interface down
        if (!uvm_config_db#(virtual flex_counter_if)::get(this, "", "fcif", fcif)) begin
          `uvm_fatal("uvm_env", "failed to get interface from uvm_test")
        end

        if (!uvm_config_db#(virtual flex_counter_if)::set(this, "fc_agt", "fcif", fcif)) begin
            `uvm_fatal("uvm_env_down", "failed to pass interface down to the agent")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
      //the monitor sends transactions to predictor so predictor can make prediction(the expected data)
      //the predictor sends expected data to comparator
      //the monitor sends actual data to comparator and the comparator makes comparisons

      //connnect the analysis port of monitor to the analysis export of the predictor(subscriber)
      fc_agt.fc_mon.mon_ap.connect(fc_pred.analysis_export);
      //connect the analysis port of the predictor to the expected port of the comparator
      fc_pred.fc_pred_ap.connect(fc_comp.expected_port);
      //connect the analysis port of the monitor to the actual export of the comparator
      fc_agt.fc_mon.mon_result_ap.connect(fc_comp.actual_export)
    endfunction
        

endclass: fc_env
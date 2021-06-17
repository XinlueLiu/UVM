1. UVM factory
    (1). define, register, create
    //example:
    class comp1 extends uvm_component; //define
        `uvm_component_utils(comp1); //register
        //  Constructor: new
        function new(string name = "comp1", uvm_component parent);
            super.new(name, parent);
        endfunction: new
    endclass: comp1
    
    class obj1 extends uvm_object;
        `uvm_object_utils(obj1);
        function new(string name = "obj1");
            super.new(name);
        endfunction: new
    endclass: obj1
    
    //create via factory
    //when create uvm_component object
    comp_type::type_id::create(string name, uvm_component parent);
    //in above example, should create 
    comp1 c1;
    c1 = comp1::type_id::create("c1",null);
    //when create uvm_object object
    object_type::type_id::create(string name);
    (2). uvm_coreservice_t
    //don't need to be instantiated. include uvm_factory.

2. uvm factory override
    (1). //replace a type
    static function void set_type_override(uvm_object_wrapper override_type, bit replace = 1);
    //how to use set_type_override
    orig_type::type_id::set_type_override(new_type::get_type());
    (2). //replace certain instantiation
    static function void set_inst_override(uvm_object_wrapper override_type, string inst_path, uvm_component parent=null);
    //how to use set_inst_override
    orig_type::type_id::set_inst_override(new_type::get_type(),"orig_inst_path");
    //for the orig_inst_path, if we are looking at at checker, then its address is 
    //root.test.env.checker
    //replace first then create

3. field automation
    //example
    //  Class: box
    //
    class box extends uvm_object;
        int volume;
        color_t color = WHITE;
        string name = "box";
    
        `uvm_object_utils_begin(box)
            `uvm_field_int(volume, UVM_ALL_ON)
            `uvm_field_enum(color_t, UVM_ALL_ON)
            `uvm_field_string(name, UVM_ALL_ON)
        `uvm_object_utils_end
        //  Constructor: new
        function new(string name = "box");
            super.new(name);
        endfunction: new
        
    endclass: box
    
    //because we declare the fields, so we can directly use the pre-defined methods
    //example
    box b2, b1;
    b2.copy(b1); //we can directly use copy, compare, print, .etc
    //when do_compare, make sure to cast the generic uvm_object to user defined object

4. objection 
    //example
    class test1 extends uvm_test;
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            #1us;
            phase.drop_objection(this);
        endtask
    endclass
    //at least 1 component raise objection, otherwise uvm will go to next phase

5. uvm_phases
    function types:
        1. build_phase: build testbench components and create their instances
        2. connect_phase: connect between different testbench components via TLM ports
        3. end_of_elaboration_phase: display UVM topology and other functions required to be done after connection
        4. start_of_simulation_phase: Used to set initial run-time configuration or display topology
    task type:
        5. run_phase: Actual simulation that consumes time happens 
        in this UVM phase and runs parallel to other UVM run-time phases.
    function types:
        6. extract_phase: extract and compute expected data from scoreboard
        7. check_phase: perform scoreboard tasks that check for errors between expected and actual values from design
        8. report_phase: display result from checkers, or summary of other test objectives
        9.final_phase: do last minute operations before exiting the simulation
        
6. config
    //form
    uvm_config_db#(type)::set(contxt, inst_name, field_name, value);
    uvm_config_db#(type)::get(contxt, inst_name, field_name, value);
    
7. uvm_report 
    function void uvm_report_info(string id, string message, int verbosity = UVM_MEDIUM);
    //also have uvm_report_warning, uvm_report_error, uvm_report_fatal
    //or we can use uvm macros to do so
    `uvm_info(get_name(), "message", UVM_NONE)
    //verbosity default is LOW, which is pretty important
    `uvm_warning(get_name(), "message")
    `uvm_error(get_name(), "message")
    `uvm_fatal(get_name(), "message")

8. uvm_components 
    (1). uvm_driver
    //get transaction from uvm_sequencer, and drive the DUT(send the transaction)
    //request type defaulted as uvm_sequence_item, response defaulted same as response
    class uvm_driver # (type REQ=uvm_sequence_item, type RSP=REQ) extends uvm_component;
    //in order for driver to get new transaction from sequencer, use pull
    driver.seq_item_port.connect(sequencer.seq_item_export); //get the request
    driver.rsp_port.connect(sequencer.rsp_export); //send the response

    //example: how to user define a driver
    class dut_driver extends uvm_driver #(basic_transaction) //type of sequence item, REQ
        virtual chip_if vif; //virtual interface
        `uvm_component_utils(dut_driver)
        function new(string name, uvm_component parent);
          super.new(name,parent);
        endfunction:new
        extern task run_phase(uvm_phase phase); //can define later
    endclass: dut_driver

    (2). uvm_monitor 
    //to monitor interface data, internal data, .etc. no new methods comparing to uvm_component
    //keep PASSIVE mode. never drive dut
    class serial_monitor extends uvm_monitor;
        virtual serial_if.monitor mi; //virtual interface + modport
        `uvm_component_utils(serial_monitor)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new
        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
        endfunction: build_phase
        extern task run_phase(uvm_phase phase);
    endclass: serial_monitor
        
    //external definition
    task serial_monitor::run_phase(uvm_phase);
    endtask: run_phase
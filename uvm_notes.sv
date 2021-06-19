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

    (3). uvm_sequencer 
    //like a tube to transport transactions from sequence to driver

    (4). uvm_agent
    //like a standard verification environment, which include a driver, a monitor, and a sequener
    //sometimes uvm agent only need 1 monitor, if its not active(UVM_PASSIVE)
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    //master agent and slave agent

    (5). uvm_scoreboard
    //compare, report data, like a checker
    //it will receive data from many monitors
    uvm_in_order_comparator #(type T) //compare expected and output value when have the same time
    uvm_altorithm_comparator #(type BEFORE, type AFTER, type TRANSFORMER) //transform BEFORE to AFTER using TRANSFORMER

    (6). uvm_env 
    //may include many uvm_agent and other components
    //will be re-used in upper level design environment
    //example
    class top_env extends uvm_env;
        sub_env m_se;
        my_agent m_agt;
        my_scoreboard m_sb;
        `uvm_component_utils(top_env)
        extern function new(string name, uvm_component parent);
        function void build_phase(uvm_phase);
            m_se = sub_env::type_id::create("m_se", this);
            m_agt = my_agent::type_id::create("m_agt", this);
            m_sb = my_scoreboard::type_id::create("my_sb", this);
        endfunction
    endclass: top_env
    
    (6). uvm_test 
    //instantiate the environment

    (7). overall structure
    //uvm_top is the only instantiation of the uvm_root. uvm_top creates uvm_test(if parent = null, then its 
    //parent is uvm_top, but its not recommend). uvm_test creates uvm_env, and uvm_env creates 
    //scoreboard, agent, register model, .etc. It also controls phase, objections, .etc. 

9. (1). TLM(Transaction level modeling)
    //initiator(sender) and target(responder). Always connect initiator to target
    //producer and consumer, this is based on direction of transaction.  
    //port types:
    //port: start of initiator. initiator use port to access target
    //export: port of in-between ports of initiator and target. is never the end
    //imp: end point of target, cannot extend

    //cannot use type_id::create, because its neither object nor component. 
    //uvm_port_base inherit uvm_void
    //can be unidirection or bidirection
    (2). unidirectional communication
    //have both blocking and non_blocking, such as get and try_get
    //all this methods are implemented in the target, and initiator use this method from target
    uvm_put_PORT //initiator to target
    uvm_get_PORT //target to initiator
    uvm_peek_PORT
    uvm_get_peek_PORT 
    (3). bidirectional communication
    //still have initiator and target, but both sides are producer and consumer
    (4). multi-directional communication
    //still between two components, but multiple transactions between initiator and target
    `uvm_blocking_put_imp_decl(_p1)
    `uvm_blocking_put_imp_decl(_p2)
    //if comp1 is initiator, comp2 is target
    class comp1 extends uvm_component;
        uvm_blocking_put_port #(itrans) bp_port1;
        uvm_blocking_put_port #(itrans) bp_port2;
        ...
        task run_phase(uvm_phase phase);
            itrans itr1, itr2;
            this.bp_port1.put(itr1);
            this.bp_port1.put(itr2); //do not need to specify p1 or p2
        endtask
    endclass
    class comp2 extends uvm_component;
        uvm_blocking_put_imp_p1 #(itrans, comp2) bt_imp_p1;
        uvm_blocking_put_imp_p2 #(itrans, comp2) bt_imp_p2;
        semaphore key;
        ...
        task put_p1(itrans t);
            key.get();
            key.put();
        endtask
        task put_p2(itrans t);
            key.get();
            key.put();
        endtask
    endclass
    class env1 extends uvm_env;
        comp1 c1;
        comp2 c2;
        `uvm_component_utils(env1)
        ...
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            c1 = comp1::type_id::create("c1", this);
            c2 = comp2::type_id::create("c2", this);
        endfunction: build_phase
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            c1.bp_port1.connect(c2.bt_imp_p1);
            c1.bp_port2.connect(c2.bt_imp_p2);
        endfunction:connect_phase
    endclass
    (5). 
    1. TLM_FIFO
    //similar to mailbox
    2. uvm_analysis_port 
    //1 port to multiple ports(1 initiator to multiple targets). observer pattern
    //use write() function
    3. Analysis TLM_FIFO 
    uvm_tlm_analysis_fifo 
    4. Request & Response 
    //bidirectional transport, that can send request and receive response

10. synchronization in uvm
    (1). uvm_event //can share a uvm_event_pool
    //use trigger() to trigger the event and use wait_trigger() to wait
    //if need to wait again, use reset() then trigger()
    //can use trigger(T data), and wait_trigger_data(output T data)
    //can use add_callback(uvm_event_callback cb, bit append=1) to add callback function
    //can use get_num_waiters() to get number of transactions waiting

    //use uvm_event_pool::get_global("e1") to get the uvm_event object
    //can define pre_trigger() and post_trigger(). if pre_trigger() return 1, then uvm_event will not be triggered
    //and post_trigger() will not be triggered. 

    //can use wait_ptrigger() and wait_ptrigger_data(). level triggered
    //wait_trigger is edge triggered

    //normal data communication use TLM, such as sequencer and driver, monitor and scoreboard
    //data communication between object and component, object and object, sequence and sequencer,
    //sequence and driver can use uvm_event
    (2). uvm_barrier
    //can set certain threshold. when there are at least k processes, the event will be triggered.
    //multiple barriers share 1 global uvm_barrier_pool
    //use uvm_barrier::set_Threshold() and uvm_barrier::wait_for()
    (3). uvm_callback
    //1. define callback. 2. register callback. 3. insert callback 4. add callback

11. sequence, sequence item, sequencer, driver
//sequence produces items(data to send), send to sequencer which acts like a arbitor, and then get to driver which
//sends data to driver which manipulates the data
(1). reationship betweeen uvm_sequence_item and uvm_sequence
//item is based on uvm_object, which includes the specific data to send
//use rand to randomize, and automation to clone, .etc
//sequence can randomize items

//uvm_sequence 
//has body();
//flat sequence
//organize sequence_items

//hierarchical sequence
//organize multiple sequence to attach to 1 sequencer

//virtual sequence
//do not attach to 1 specific sequencer
//organize multiple sequence to connect to different sequencer
(2). relationship between uvm_sequencer and driver 
//both are components, and use TLM communication.
//driver is the initiator that gets itsm from sequencer
//mostly used get_next_item and item_done

//flat_se::body()
    //-create request item via create_item()
    //-send item via start_item
    //-randomize item before sending
    //-finish_item()
    //-get response item from driver if necessary

//driver::run_phase()
    //get valid request item via seq_item_port.get_next_item(REQ)
    //get data from request item and produce stimulus
    //if want to response, clone request item and send it back to sequence
(3). sequencer and sequence
    //can use macros to finish attach and send
    //`uvm_do(item) and `uvm_do(seq)
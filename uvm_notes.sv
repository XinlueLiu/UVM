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

5. config
    //form
    uvm_config_db#(type)::set(contxt, inst_name, field_name, value);
    uvm_config_db#(type)::get(contxt, inst_name, field_name, value);
    
6. uvm_report 
    function void uvm_report_info(string id, string message, int verbosity = UVM_MEDIUM);
    //also have uvm_report_warning, uvm_report_error, uvm_report_fatal
    //or we can use uvm macros to do so
    `uvm_info(get_name(), "message", UVM_NONE)
    //verbosity default is LOW, which is pretty important
    `uvm_warning(get_name(), "message")
    `uvm_error(get_name(), "message")
    `uvm_fatal(get_name(), "message")
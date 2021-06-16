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
    
1. clocking blocks
    (1). To prevent race condition. A race condition happenes when the order of execution between two constructs
    cannot be guaranteed, like when multiple processes reading and writing the same variable synchronized to
    the same event region.
    (2). clocking blocks makes timing explicit.
    syntax:

    clocking name @(clocking_event);
        default input intput_skew output output_skew;
        input input_signals;
        output output_signals;
    endclocking:name

    example:
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns; (the input and output skew can also use steps. e.g. input #1step output #0)
        output ch_data, ch_valid;
        input ch_ready, ch_margin;
    endclocking:drv_ck
    (3). input/output skew: when the input/output is sampled before/after the clocking event occurs
    (4). A clocking can only be declared inside a module, interface(most often), checker, or program.

2. function automatic vs static 
    (1). syntax
        function automatic/static type(e.g. int) name(type argument); endfunction
    (2). automatic vs static
        automatic: new value will be created when entering the function. destoryed when leave the function.
        static: created at the beginning of the simulation. destoryed when simulation ends.
        example:

        function automatic int count(input a);
            int cnt = 0;
            cnt+=a;
            return cnt;
        endfunction
        if calling count function two times with argument a = 1, then displays two cnt = 1;
        if automatic changes to static, then displays cnt = 1, cnt = 2.

3. fork join
    (1). the statements are executed in parallel
    fork
        statement1;
        statement2;
    join
    statement3; //statement3 will be executed after both statement1 and statemen2 finish running

    fork
        statement1;
        statement2;
    join_any
    statement3; //statement3 will be executed after either one of statement1 and statemen2 finish running

    fork
        statement1;
        statement2;
        statement3;
    join_any
    disable fork;
    statement4; //statement4 will be executed after either one of above statements finish running, and kill the 
    //rest of it

    fork
        statement1;
        statement2;
        statement3;
    join_none
    statement4; //statement4 will be executed immediately
    wait fork; //wo;; waot fpr statement1,2,3, but not 4
    (2). nested between begin...end, the two statements will be executed sequentially, but the two begin..end 
    blocks will be executed in parallel
    fork
        begin
            statement1;
            statement2;
        end
        begin
            statement3;
            statement4;
        end
    join

4. virtual
    (1). virtual interface
        if instantiate multiple interfaces without virtual, then all the instantiations will be changed if one
        variable in one instantiation is changed.
    (2). virtual function/tasks
        if virtual is declared, function/tasks used in child class will look into the parent class is not exist
        in the child class. if virtual not declared, then only find it in the child class;
    (3). virtual methods/classes
        virtual methods are resolved according to the contents of a handle, not the type

        virtual class cannot be instantiated, only to be inherited.
        virtual class may have pure virtual methods, which is a prototype only(no implementation). The subclass
        must provide implementation
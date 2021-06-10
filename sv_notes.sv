1. clocking blocks
    (1). To prevent race condition. A race condition happenes when the order of execution between two constructs
    cannot be guaranteed, like when multiple processes reading and writing the same variable synchronized to
    the same event region.
    (2). clocking blocks makes timing explicit.
    //syntax:

    clocking name @(clocking_event);
        default input intput_skew output output_skew;
        input input_signals;
        output output_signals;
    endclocking:name

    //example:
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns; (the input and output skew can also use steps. e.g. input #1step output #0)
        output ch_data, ch_valid;
        input ch_ready, ch_margin;
    endclocking:drv_ck
    (3). input/output skew: when the input/output is sampled before/after the clocking event occurs
    (4). A clocking can only be declared inside a module, interface(most often), checker, or program.

2. function automatic vs static 
    (1). //syntax
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

5. package
    //example:

    //declaration of a package
    package package_name
        typedef enum {ADD,SUB} opcode_t;
    endpackage
    //use package
    //import everything
    import package_name::*;
    //import individually
    output logic result;
    case()
        ADD:result = 0;
    endcase 
    import package_name::ADD;
    //use individually
    output logic result;
    case()
        package_name::ADD:result = 0;
    endcase 
    
6. randomization keywords

    rand, randc, constraint{}:
    systemverilog can only randomize 2-value datatypes. e.g. bits. if rand logic, x and z will not be randomized
    rand:randomly choose within the constraint. possibility of getting each i is the same.
    randc: rand cycle. i that's already been chosen will only be chosen again if all possible i have been chosen
    (used in class)

    //example:

    class packet_rand;
        rand bit [31:0] test1, test2;
        randc bit [1:0] test3;
        constraint c {test1 > 5; test1 < 10;}
    endclass //packet_rand
    packet_rand p;
    initial begin
        p = new(); //create a packet_rand
        assert (p.randomize()) 
        else   $fatal(0, "randomization failed"); //is constraint is test1>5, test1<6, then randomization failed
        //if failed, test1,2,3 all failed
    end

    if randomize(test1) then only test1 get randomized, not including test2

    inside:
    <variable> inside {<values or range>}
    my_var inside {1,2,3} //check if my_var is either 1,2,3
    my_var inside {[1,10]} //check if my)var is between 1 and 10

    dist:
    rand int src, dst;
    constraint const_dist {
        src dist {0:=40, [1:3]:=60};
        //weight denominator is 40+3*60=220. so the change for src=0 is 40/220
        dst dist {0:/40, [1:3]:/60};
        //weight denominator is 100. so the change for src=0 is 2/5
    }

    $:
    To determine maximum and minimum number
    rand bit [6:0] a; //a is in the range of 0 and 127
    constraint dollar_range{
        a inside {[$:5], [10:$]}; // 0 <= a <= 5 || 10 <= a <= 127
    }

    $random(): return 32-bit signed
    $urandom(): return 32-bit unsigned
    $urandom_range(): return a value in the range

    //can use if...else in constraint. or we can use symbol "->".
    // (condition) -> statement; when condition returns not 0, the statement becomes true.

7. constraint_mode()
    p.const1.constraint_mode(0); //shut down the specific constraint
    p.constraint_mode(0); //shut down all constraint
    p.const1.constraint_mode(1); //turn the specific const1 on

   randomize() with //additional constraint when asserting the randomization
   
   soft keyword
   //the constraint with soft has lower priority then other constraints

   //remember to declare the size of a dynamic array
   //can use sum(), foreach to constraint the dynamic array

   //can user define pre_randomize() and post_randomize()

   //can use randsequence() to weight the possibility of entering the tasks
   //can use randcase to weight the possibility of entering the cases

8. mailbox
    //used to communicate between transactions
    //mailbox behaves like queue, but mailbox cannot access a given index within the mailbox queue. 
    //It can only be retrieved in FIFO order
    syntax:
    axi_txn txn = new();
    mailbox #(axi_txn) mbx = new(); //create a unbounded mailbox with type axi_txn
    mailbox mbx2 = new(sizet); //create bounded mailbox with size sizet
    mbx.put(txn); //put the messagein the mailbox
    mbx.get(txn); //retrieve a message from a mailbox
    mbx.num(); //get numbers of messages currently in the mailbox
    mbx.try_put(txn); //can put if mailbox is not full and returns positive integer. else return 0
    mbx.try_get(txn); //can get if mailbox is not empty. if empty returns 0
    mbx.peek(txn); //copies one message from the mailbox without removing the messaage from the queue
    mbx.try_peek(txn); //try to peek
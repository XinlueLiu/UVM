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

    fork : disable_example
        statement1;
        statement2;
        statement3;
    join_any
    disable disable_example; //can use tag or disable fork
    statement4; //statement4 will be executed after either one of above statements finish running, and kill the 
    //rest of it

    fork
        statement1;
        statement2;
        statement3;
    join_none
    statement4; //statement4 will be executed immediately
    wait fork; //will wait for statement1,2,3, but not 4
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
        better to declare virtual class on the superclass, and it only needs to be declared once

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

8. interprocess Communication
    (1).event //can use -> to trigger next event.
               //event does not need new
        example:
        
        event e1, e2;
        initial begin
            -> e1;
            //if use @e2,which is edge triggered, then either e1 or e2 may not been triggered due to delta cycle
            //triggered is level triggered, so it will wait until the event is triggered. if its already 
            //been triggered, then its still good
            wait (e2.triggered());
        end
        initial begin
            -> e2;
            wait (e1.triggered());
        end

    (2). semaphore //need to get the key to process
        example:

        semaphore sem; //create a semaphore
        sem = new(1); //create a key
        sem.get(1); //get a key
        sem.put(1); //return a key   

    (3). mailbox
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

9. coverage
    1. coverage types
        (1). code coverage
            //coverage of design code
            line coverage
            path coverage
            condition/branch coverage //if
            Toggle coverage //bit value 1 or 0
            FSM coverage
        (2). assertion coverage
            //A kind of Functional Coverage which measures which assertions have been triggered. 
        (3). functional coverage
            //Functional coverage is a measure of what functionalities/features of the design have been exercised by the tests. 
    2. coverage group
        //can include one or more coverpoint, which sample in specific times

        example1: 
        
        class example;
            example ex1;
            covergroup cg_ex1
                coverpoint ex1.test;
                function new();
                  cg_ex1 cg1 = new();
                endfunction
            endgroup: cg_ex1
        endclass
        
        task main
            forever begin
                cg1.sample();
            end
        endtask 

        example2:
        event trans_ready;
        //  Covergroup: cg_cg1
        //
        covergroup cg_cg1 @(trans_ready);
            coverpoint ex1.test;
        endgroup: cg_cg1

    3. coverpoint bin 
        //sv will create(or user define) many bins to record # of times each value get sampled
        //user define bin
        example: 
        covergroup cg1;
            options.auto_bin_max = 8;
            coverpoint ex1.test {options.auto_bin_max = 2;} //auto_bin # = 2
        endgroup

        covergroup cg1;
            options.auto_bin_max = 8;
            coverpoint ex1.test {
                bins zero = {0};
                bins low = {[1:3],[5]};
            } 
        endgroup

        //coverpoint can use iff to add conditions. can use .start() or .stop() to control the sampling

        //coverpoint can also record the changing status of the values
        covergroup cg1;
            coverpoint ex1.test {
                bins b1 = (0 => 1), (0 => 2), (0 => 3);
            }
        endgroup
        
        //can use wildcard to create multiple status
        covergroup cg1;
            coverpoint ex1.test {
                wildcard bins even = {3'b??0};
                wildcard bins odd = {3'b??1};
            }
        endgroup

        ignore_bins and illegal_bins 
        //can use ignore_bins to ignore certain vals
        //can use illegal_bins. when enconters error will pop up
    
        cross coverage
        //can use cross keyword to sample multiple vals
        binsof, intersect 
        //can use binsof to choose specific bins
        //can use intersect to specific specific element of bins

        example:
        //if we have 2 rand vals a and b, and we are interested in these three cases
        //when {a ==0, b ==0}, {a == 1, b == 0}, and {b == 1}
        class transactions
            rand bit a,b;
        endclass

        covergroup crossBinExaple;
            a : coverpoint tr.a{
                bins a0 = {0};
                bins a1 = {1};
                option.weight = 0; //define the influence of a coverpoint to the total coverage number
            }
            b : coverpoint tr.b{
                bins b0 = {0};
                bins b1 = {1};
                option.weight = 0; //define the influence of a coverpoint to the total coverage number
            }
            ab : cross a,b {
                bins a0b0 = binsof(a.a0) && binsof(b.b0);
                bins a1b0 = binsof(a.a1) && binsof(b.b0));
                bins b1 = binsof(b.b1);
            }
        endgroup

10. type casting
    $cast(tgt, src) and int'(1.0)

11. copy
    (1). shallow copy
        p1 = new();
        p2 = new p1;

12. callback
    //declare pre_callback and post_callback in superclass for subclass to use
13. parametrize class
    example: //user defined mailbox

    class mailbox #(type T = int);
         local T = queue[$]; //To specify a finite, but unbounded, number of iterations, the dollar sign ( $ ) is used
         task put(input T i);
            queue.push_back(i);
         endtask

         task get(ref T o);
            wait(queue.size() > 0);
            o = queue.pop_front();
         endtask

         task peek(ref T o);
            wait (queue.size() > 0);
            o = queue[0];
         endtask
    endclass //mailbox
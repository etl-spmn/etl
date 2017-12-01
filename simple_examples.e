<'
import e/etl_top;

// utility dummy structs
struct packet {
    is_valid : bool;
    addr     : byte;
};
struct compound_packet like packet {
    packets: list of packet;
    keep packets.size() < 4;
    keep for each in packets {
        .addr == addr;
    };
};

// vector
// This example shows how the wrapper can be used for additional checks
template struct no_null_vector of <type> like vector of <type> {
    add(item: <type>) is first {
        if item == NULL {
            error("This vector must not contain NULL values.");
        };
    };
    // same for all methods that add new items
};

// deque
// Good for fifo operations
unit simple_scheduler {
    !fifo: deque of packet;
    put_new_packet(p: packet) is {
        fifo.add(p);
    };
    get_next_packet(): packet is {
        if fifo.size() > 0 {
            result = fifo.pop0();
        };
    };
};

// linked_list
// Good for inserting using iterator
struct packet_linked_list like linked_list of packet {
    expand() is {
        var iter := get_iterator();
        var packets: list of packet;
        while iter.has_next() {
            var p := iter.next();
            if p is a compound_packet (cp) {
                // remove the current compound one, and instaed - add the its sub packets 
                packets = cp.packets;
                iter.remove(); 
                for each in reverse  packets {
                    iter.insert(it);
                };
            };
        };
    };
};

// keyed_set
// The guarantie of uniqueness is not so much interesting, but the ability to add checks and other functionality
struct valid_packet_set like keyed_set of packet {
    add(packet) is first {  
        if not packet.is_valid {
            return;
        };
    };
    // same for all methods that add new keys
};

// keyed_multi_set
// It is possible to implement simple multi map using keyed_multi_set
template struct simple_multi_map of (<key'type>, <value'type>) {
    private mset: keyed_multi_set of <key'type>;
    private vec: list of <value'type>;
    put(k: <key'type>, v: <value'type>) is {  
        mset.add(k);
        vec.add(v);
    };
    get_value(k: <key'type>): <value'type> is {
        var idx := mset.key_index(k);
        if idx != UNDEF {
            result = vec[idx];
        };
    };
    get_all_values(k: <key'type>): list of <value'type> is {
        for each (idx) in mset.all_key_indices(k) {
            result.add(vec[idx]);
        };
    };
};




'>


<'

unit env {
    !packet          : packet;
    !compound_packet : compound_packet;
    
    // vector, regular list
    my_vector : vector of packet;
    
    demo_vector() @sys.any is {
        out("\n   VECTOR \n   ------");
        my_vector = new;
        
        for i from 0 to 5 {
            wait cycle;
            print my_vector;
            gen packet;
            my_vector.add(packet);
        };
    };
    
    scenario() @sys.any is {
        raise_objection(TEST_DONE);
        demo_vector();
    };
    
    
    // dequeue, fifo
    !fifo : deque of packet;
    
    demo_queue() @sys.any is {
        out("\n\n   DEQUE \n   -----");
        fifo = new;
        
        for i from 0 to 5 {
            wait cycle;
            packet = new with {
                .addr = i; .is_valid = TRUE;
            };
            fifo.add(packet);
        };
        print fifo.get_list();
        wait cycle;
        
        for i from 0 to 5 {
            packet = fifo.pop();
            print packet;
        };
        
        
    };
    scenario() @sys.any is also {
        demo_queue();
    };
    
    
    // linked list
    linked_list : packet_linked_list;
    demo_linked_list() @sys.any is {
        out("\n\n   LINKED LIST \n   ---------");
        wait cycle;
        
        linked_list = new;
        for i from 0 to 6 {
            gen compound_packet keeping {
                .addr == i; .is_valid == TRUE;
            }; 
            linked_list.add(compound_packet);
        };
        
        print linked_list.get_list();
        out("   call expand");
        linked_list.expand();
        print linked_list.get_list();
    };
    
    scenario() @sys.any is also {
        demo_linked_list();
    };
    

    
    scenario() @sys.any is also {
        wait cycle;
        drop_objection(TEST_DONE);
    };
    run() is also {
        start scenario();
    };
};

extend sys {
    env : env is instance;
};

'>

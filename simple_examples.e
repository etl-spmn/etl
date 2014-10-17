<'
import e/etl_top;

// utility dummy structs
struct packet {
    is_valid: bool;
};
struct compound_packet like packet {
    packets: list of packet;
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
struct packet_queue like linked_list of packet {
    expand() is {
        var iter := get_iterator();
        while iter.has_next() {
            var p := iter.next();
            if p is a compound_packet (cp) {
                for each in reverse cp.packets {
                    iter.insert(it);
                };
                iter.remove(); // remove the current compound one;
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
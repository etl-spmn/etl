<'

package etl;

import e/container.e;

// Implements keyed_set, based on regular "list (key:it) of <type>". (A data structure similar to 
// "list (key:<field>) of <type>" will be implemented as keyed_map.) The difference is that the methods 
// that modify the contents, have checks to guarantee the consistency, first of all against inserting several equal keys.
template struct keyed_set of <type> like container of <type> { 
    
    // Keyed list that represents the contents of keyed_set. Can be accessed for read directly without any problem. 
    // However, unlike keyed_set, regular keyed list is not protected against inserting several equal keys, 
    // so changing it directly is not recommended.
    package keyed_list: list (key: it) of <type>;
    
    // API Methods
    
    // Return iterator instance of keyed_set.
    get_iterator(): iterator of <type> is {
        result = new keyed_set_iterator of <type> with {
            // keyed_set_iterator will have a reference to this keyed_set
            it.keyed_list_itr = me;
            // Set the initial index of the iterator.
            it.iterator_index = -1;
        };
    };
    
    // Set a key at a specified index in O(alpha) - a little over O(1) keyed list operation overhead.
    set(index: uint, key: <type>) is {  
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a keyed_set - index must be >= 0.");
        };
        
        if is_empty() {
            error("keyed_set is empty - cannot access item ",index)      
        };
        
        if index >= keyed_list.size() {                
            error("keyed_set has only ", keyed_list.size()," items - cannot access item ", index);
        };
        
        if keyed_list.key_exists(key) {
            error("keyed_set set already has key ", key);   	
        };
              
        keyed_list[index] = key;
    };
    
    // Return a key at a specified index in O(1).
    get(index: uint): <type> is {
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a keyed_set - index must be >= 0.");
        };
        
        if is_empty() {
            error("keyed_set is empty - cannot access item ",index)      
        };
              
        if index >= keyed_list.size() {
            error("keyed_set has only ", keyed_list.size()," items - cannot access item ", index);
        };
            
        return keyed_list[index];
    };
    
    // Add a key to the end of keyed_set in O(alpha) - a little over O(1) keyed list operation overhead.
    add(key: <type>) is {
        if not keyed_list.key_exists(key) { 
            keyed_list.add(key);
        }
        else {
            error("keyed_set already has key ", key);   
        };    
    };
	
    // Add a list to the end of keyed_set in O(N).
    add_list(my_list: list of <type>) is {
        for each in my_list {
            if keyed_list.key_exists(it){
                error("keyed_set already has key ", it);
            };
        };
        keyed_list.add(my_list);
    };
    
    // Add a key to the head of keyed_set in O(N).
    add0(key: <type>) is {
        if !keyed_list.key_exists(key) { 
            keyed_list.add0(key);
        }
        else {
            error("keyed_set already has key ", key);    
        };     
    };
    
    // Add a list to the head of keyed_set 
    add0_list(my_list: list of <type>) is {
        for each in my_list {
            if keyed_list.key_exists(it){
                error("keyed_set already has key ", it);
            };
        };
        keyed_list.add0(my_list);
    };
	
    // Delete all keys from keyed_set in O(alpha).
    clear() is {
        keyed_list.clear();
    };
    
    // Delete a key from keyed_set at a specified index in O(N).
    delete(index: uint) is {
        if keyed_list.size() > 0 {
            if (index >= 0) and (index < keyed_list.size()) { 
                keyed_list.delete(index);
            }
            else {
                error("keyed_set has only ", keyed_list.size()," items - cannot access item ",index.as_a(int));
            }; 
        }
        else {
            error("keyed_set is empty - cannot access item ", index.as_a(int));  
        }; 
    };
    
    // Delete a key from keyed_set at a specified index without adjusting all indices in O(alpha).
    fast_delete(index: uint) is {
        if keyed_list.size() > 0 {
            if (index >= 0) and (index < keyed_list.size()) { 
                keyed_list.fast_delete(index); 
            } 
            else {
                error("keyed_set has only ", keyed_list.size(), " items - cannot access item ", index.as_a(int));
            };
        }
        else {
            error("keyed_set is empty - cannot access item ", index.as_a(int));  
        };
    };    
    
    // Insert a key to keyed_set at a specified index in O(alpha).
    insert(index: uint, key: <type>) is {
        if !keyed_list.key_exists(key) {
            if (index >= 0) and (index <= keyed_list.size()) {
                keyed_list.insert(index,key);
            }
            else {
                error("keyed_set set has only ", keyed_list.size(), " items - cannot access item ", index.as_a(int));
            }; 
        }
        else {
            error("keyed_set set already has key ", key);
        };        
    };
    
    // Insert a list to keyed_set starting at a specified index in O(N);
    insert_list(index: uint, my_list: list of <type>) is {
        for each in my_list {
            if keyed_list.key_exists(it){
                error("keyed_set already has key ", it);
            };
        };
        keyed_list.insert(index, my_list);
    };
	
    // Remove and return the last key of keyed_set in O(alpha).
    pop(): <type> is {
        if keyed_list.size() > 0 {
            return keyed_list.pop();
        }
        else {
            error("Cannot use 'pop()' method on an empty keyed_set");  
        };
    };

    // Remove and return the first key of keyed_set in O(N).
    pop0(): <type> is {
        if keyed_list.size() > 0 {
            return keyed_list.pop0();
        }
        else {
            error("Cannot use 'pop0()' method on an empty keyed_set");  
        };
    };
    
    // Add a key to the end of keyed_set in O(alpha).
    push(key: <type>) is {
        add(key);   
    };
        
    // Add a key to the head of keyed_set in O(N).
    push0(key: <type>) is {
        add0(key);   
    };
	
    // Check if keyed_set is empty in O(1);
    is_empty(): bool is {
        return keyed_list.is_empty();
    };
	
    // Return the number of items in keyed_set in O(1).
    size(): uint is {
        return keyed_list.size();  
    };
	
    // Return the last key of keyed_set in O(1).
    top(): <type> is {
        if keyed_list.size() > 0 {
            return keyed_list.top();
        }
        else {
            error("Cannot use 'top()' method on an empty keyed_set");  
        };   
    };
	
    // Return the first key of keyed_set in O(1).
    top0(): <type> is {
        if keyed_list.size() > 0 {
            return keyed_list.top0();
        }   
        else {
            error("Cannot use 'top0()' method on an empty keyed_set");  
        };     
    };
     
    // Return the index of the first key that is equal to the given key in O(alpha) - we know that the if it exists, it's the only one.
    first_index_of_item(key: <type>): int is {
        return keyed_list.key_index(key);
    };
    
    // Return the index of the last key that is equal to the given key in O(alpha) - we know that the if it exists, it's the only one.
    last_index_of_item(key: <type>): int is {
        return keyed_list.key_index(key);            
    };
    
    // Check that a keyed_set has at least one key that is equal to the given key in O(alpha).
    has_item(key: <type>): bool is {
        return keyed_list.key_exists(key);
    };
 
    // Return all keys of keyed_set as a regular list in O(N).
    get_list(): list of <type> is { 
        return keyed_list.as_a(list of <type>);
    };
    
    // Return the key if such key exists in keyed_set, otherwise returns default value for the <type> in O(alpha).
    key(key_item: <type>): <type> is {
        return keyed_list.key(key_item);  
    };
   
    // Return the index of the key, equal to given key_item. If not found, UNDEF is returned. O(alpha).
    key_index(key_item: <type>): int is {
        return keyed_list.key_index(key_item);  
    };
    
    // Check that a particular key is in keyed_set in O(alpha).
    key_exists(key_item: <type>): bool is {
        return keyed_list.key_exists(key_item);  
    };
};

// Iterator implementation for keyed_set
template struct keyed_set_iterator of <type> like iterator of <type> {
    // Internal field - point to the keyed_set which is iterated over.
    package keyed_list_itr: keyed_set of <type>;
    // Current index inside keyed_set
    package iterator_index: int;
    
    //Return true if this keyed_set has more items when traversing the keyed_set set in the forward direction. 
    //(In other words, return true if next() would return an item rather than throwing an error.)
    has_next(): bool is {
        return (not keyed_list_itr.is_empty()) and (iterator_index == - 1 or iterator_index < keyed_list_itr.size() - 1);
    };
    
    //Return true if this keyed_set has more items when traversing the keyed_set in the reverse direction. 
    //(In other words, return true if prev() would return an item rather than throwing an error.)
    has_prev(): bool is {
        return iterator_index > 0;
    };

    //Return the next element in the keyed_set and advances the cursor position. This method may be called 
    //repeatedly to iterate through the keyed_set, or intermixed with calls to prev() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    next(): <type> is {
        if !has_next() {
            error("There isn't next item, keyed_set has only ", keyed_list_itr.size()," items - cannot access item ",iterator_index + 1);
        };
        iterator_index += 1;
        return keyed_list_itr.keyed_list[iterator_index];
    };
    
    //Return the prev item in the keyed_set and moves the cursor position backwards. This method may be called 
    //repeatedly to iterate through the keyed_set backwards, or intermixed with calls to next() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    prev(): <type> is {
        if iterator_index <= 0 {
            error("There isn't prev item, keyed_set has only ", keyed_list_itr.size()," items - cannot access item ",iterator_index + 1);
        };
        iterator_index -= 1;
        return keyed_list_itr.keyed_list[iterator_index];
    };
    
    //Return the index of the cursor position, this is the index of the current item. This index of the current iten 
    //is the index of the item that last returned by call to either next() or prev(). Note that it doesn't have meaning 
    //to use it before traversing on the keyed_set.
    index(): int is {--To check if to do error message.
        return iterator_index;
    };
    
    //Insert the specified item into the keyed_set. The item is inserted immediately before the item that would be 
    //returned by next(), if any, and after the item that was returned by prev call to next(), if any. 
    //(If the keyed_set had no items, the new item becomes the sole item.) A subsequent call to next would be unaffected, 
    //and a subsequent call to prev would return the item that returned by prev call to next(), if any.
    insert(item: <type>) is {
        iterator_index += 1;
        keyed_list_itr.insert(iterator_index,item);
    };
    
    //Remove the current item from the keyed_set. An error message is thrown if remove() is called before next() is invoked.
    remove() is {
        keyed_list_itr.delete(iterator_index);
        iterator_index -= 1;
    };

    //Replace the current item with the specified item, This is the item last returned by call to either next() or prev().
    set(item: <type>) is {
        keyed_list_itr.set(iterator_index,item);  
    };
};
                                                            

'>

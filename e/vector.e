<'

package etl;

import e/container.e;

// Effectively is a wrapper for regular list. Can be extended by user for build-in functionality.
template struct vector of <type> like container of <type> {
    
    // List that represents the contents of vector. If changed, this must not break any vector-specific behavior. 
    // However, user-defined types, based on vector, may add check, notifications, etc. to vector modification method, 
    // so it's not recommended to access the field.
    package vec: list of <type>;
    
    // API Methods
    
    // Return iterator instance of a vector.
    get_iterator(): iterator of <type> is {
        result = new vector_iterator of <type> with {
            //Set the vector in the vector_iterator struct to point to the vector that inside the vector struct
            it.vector = me;
            //Set the index of the iterator.
            it.iterator_index = -1;
        };
    };

    // Set an item at a specified index in O(1).
    set(index: uint, item: <type>) is {
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a vector - index must be >= 0.");
        };
            
        if is_empty() {
            error("Vector is empty - cannot access item ",index)      
        };
        
        if index >= vec.size() {
            error("Vector has only ", vec.size()," items - cannot access item ", index);
        };
          
        vec[index] = item;      
    };
	
    // Return an item at a specified index in O(1).
    get(index: uint): <type> is {
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a vector - index must be >= 0.");
        };
            
        if is_empty() {
            error("Vector is empty - cannot access item ",index)
        };
              
        if index >= vec.size() {
            error("Vector has only ", vec.size()," items - cannot access item ", index);
        };
         
        return vec[index];
    };
    
    // Add an item to the end of a vector in O(1).
    add(item: <type>) is {
        vec.add(item);
    };
	
    // Add a list to the end of a vector in O(N).
    add_list(my_list: list of <type>) is {
        vec.add(my_list);
    };
    
    // Add an item to the head of a vector in O(N).
    add0(item: <type>) is {
        vec.add0(item);
    };
    
    // Add a list to the head of a vector in O(N).
    add0_list(my_list: list of <type>) is {
        vec.add0(my_list);
    };
	
    // Delete all items from vector in O(1).
    clear() is {
        vec.clear();
    };
	
    // Delete an item from a vector at a specified index in O(N).
    delete(index: uint) is {
        if vec.size() > 0 {
            if (index >= 0) and (index < vec.size()) { 
                vec.delete(index);
            }
            else {
                error("Vector has only ", vec.size(), " items - cannot access item ", index.as_a(int)); 
            }; 
        }
        else {
            error("Vector is empty - cannot access item ", index.as_a(int)); 
        }; 
    };
    
    // Delete an item from a vector without adjusting all indexes in O(1).
    fast_delete(index: uint) is {
        if vec.size() > 0 {
            if (index >= 0) and (index < vec.size()) { 
                vec.fast_delete(index);
            } 
            else {
                error("Vector has only ", vec.size(), " items - cannot access item ", index.as_a(int)); 
            };
        }
        else {
            error("Vector is empty - cannot access item ", index.as_a(int)); 
        };
    };
    
    // Insert an item in a vector at a specified index in O(N).
    insert(index: uint, item: <type>) is {
        if (index >= 0) and (index <= vec.size()) { 
            vec.insert(index, item);
        }
        else {
            error("Vector has only ", vec.size(), " items - cannot access item ", index.as_a(int)); 
        }; 
    };
    
    // Insert a list in a vector starting at a specified index in O(N).
    insert_list(index: uint, my_list: list of <type>) is {
        if (index >= 0) and (index <= vec.size()) { 
            vec.insert(index, my_list);
        }
        else {
            error("Vector has only ", vec.size(), " items - cannot access item ", index.as_a(int));
        };   
    };
	
    // Remove and return the last vector item in O(1).
    pop(): <type> is {
        if vec.size() > 0 {
            return vec.pop();
        }
        else {
            error("Cannot use 'pop()' method on an empty vector");  
        };
    };

    // Remove and return the first vector item in O(N).
    pop0(): <type> is {
        if vec.size() > 0 {
            return vec.pop0();
        }
        else {
            error("Cannot use 'pop0()' method on an empty vector"); 
        };  
    };
	
    // Add an item to the end of a vector in O(1).
    push(item: <type>) is {
        vec.push(item);
    };    
        
    // Add an item to the head of a vector in O(N).
    push0(item: <type>) is {
        vec.push0(item);
    };
	
    // Change the size of a vector in O(N).
    resize(size: uint) is {
        vec.resize(size);
    };
	
    // Check if a vector is empty in O(1).
    is_empty(): bool is {
        return vec.is_empty();
    };
    
    // Return the size of a vector in O(1).
    size(): uint is {
        return vec.size();  
    };
	
    // Return the last item of a vector in O(1).
    top(): <type> is {
        if vec.size() > 0 {
            return vec.top();
        }
        else {
            error("Cannot use 'top()' method on an empty vector"); 
        };
    };
	
    // Return the first item of a vector in O(1).
    top0(): <type> is {
        if vec.size() > 0 {
            return vec.top0();
        }   
        else {
            error("Cannot use 'top0()' method on an empty vector"); 
        };     
    };
    
    // Return the index of the first item that is equal to the given item in O(N).
    first_index_of_item(item: <type>): int is {
        return vec.first_index(it == item);
    };
    
    // Return the index of the last item that is equal to the given item in O(N).
    last_index_of_item(item: <type>): int is {
        return vec.last_index(it == item);            
    };
     
    // Check that a vector has at least one item that is equal to the given item in O(N).
    has_item(item: <type>): bool is {
        return vec.has(it == item);
    };
    
    // Return all the items as a new list in O(N). 
    get_list(): list of <type> is {
        return vec.copy();
    };
};

// Iterator implementation for vector
template struct vector_iterator of <type> like iterator of <type> {
    //Internal field - point to the vector that inside the vector struct.
    package vector: vector of <type>;
    package iterator_index: int;
    
    //Return true if this vector has more items when traversing the vector in the forward direction. (In other words, return true if next() would return an item rather than throwing an error.)
    has_next(): bool is {
        return (not vector.is_empty()) and (iterator_index == - 1 or iterator_index < vector.size() - 1);
    };
    
    //Return true if this vector has more items when traversing the vector in the reverse direction. (In other words, return true if prev() would return an item rather than throwing an error.)
    has_prev(): bool is {
        return iterator_index > 0;
    };

    //Return the next element in the vector and advances the cursor position. This method may be called repeatedly to iterate through the vector, or intermixed with calls to prev() to go back and forth. (Note that alternating calls to next and prev will return the same item repeatedly.)
    next(): <type> is {
        if !has_next() {
            error("There isn't next item, vector has only ", vector.size()," items - cannot access item ", iterator_index + 1);
        };
        iterator_index += 1;
        return vector.vec[iterator_index];
    };
    
    //Return the prev item in the vector and moves the cursor position backwards. This method may be called repeatedly to iterate through the vector backwards, or intermixed with calls to next() to go back and forth. (Note that alternating calls to next and prev will return the same item repeatedly.)
    prev(): <type> is {
        if !has_prev() {
            error("There isn't prev item, vector has only ", vector.size()," items - cannot access item ", iterator_index + 1);
        };
        iterator_index -= 1;
        return vector.vec[iterator_index];
    };
    
    //Return the index of the cursor position, this is the index of the current item. This index of the current item is the index of the item that last returned by call to either next() or prev().Note that it doesn't have meaning to use it before traversing on the vector.
    index(): int is {--To check if to do error message.
        return iterator_index;
    };
    
    //Insert the specified item into the vector. The item is inserted immediately before the item that would be returned by next(), if any, and after the item that was returned by prev call to next(), if any. (If the vector had no items, the new item becomes the sole item.) A subsequent call to next would be unaffected, and a subsequent call to prev would return the item that returned by prev call to next(), if any.
    insert(item: <type>) is {
        iterator_index += 1;
        vector.insert(iterator_index,item);
    };
    
    //Remove the current item from the vector. An error message is thrown if remove() is called before next() is invoked.
    remove() is {
        vector.delete(iterator_index);
        iterator_index -= 1;
    };

    //Replace the current item with the specified item, This is the item last returned by call to either next() or prev().
    set(item: <type>) is {
        vector.set(iterator_index,item);  
    };
};


'>



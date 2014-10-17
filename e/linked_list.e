<'

package etl;

import e/container.e;

// Used for internal data structure.
package template struct llist_node of <type> like base_struct {
    item: <type>;
    next: llist_node of <type>;
    prev: llist_node of <type>;
};

//Implement linked_list as a generic data structure. Good for O(1) changes of head, and using iterator - at any point.
template struct linked_list of <type> like container of <type> {
    package head: llist_node of <type>;
    package tail: llist_node of <type>;  
    package size: uint;
    
    // API Methods
    
    // Return iterator instance of a vector.
    get_iterator(): iterator of <type> is {
        result = new linked_list_iterator of <type> with {
            
            //Set the vector in the vector_iterator struct to point to the vector that inside the vector struct
            it.linked_list = me;
            
            //Set the index of the iterator.
            it.iterator_index = - 1;
	    it.iterator_pointer = NULL;
        };
    };
   
    // Set a value at a given index in the linked_list in O(N). 
    set(index: uint, item: <type>) is {
        var temp_node: llist_node of <type>;
        
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a linked_list - index must be >= 0.");
        };
        
        if is_empty() {  
            error("linked_list is empty - cannot access item ",index)         
        };
        
        if index >= size {      
            error("linked_list has only ", size," items - cannot access item ", index);
        };
          
        temp_node = go_index(index);
        temp_node.item = item;	
    };
    
    // Return an item in a linked_list at a specific index in O(N). 
    get(index: uint) :<type>  is {    
        var temp_node: llist_node of <type>;
        
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a linked_list - index must be >= 0.");
        };
        
        if is_empty() {  
            error("linked_list is empty - cannot access item ",index)         
        };
        
        if index >= size {      
            error("linked_list has only ", size," items - cannot access item ", index);
        };  
        
        temp_node = go_index(index);
        return temp_node.item;	
    };
    
    // Add an item to the end of the linked_list in O(1).  
    add(item: <type>) is {
        var temp_node: llist_node of <type>;
        
        if head == NULL {
            head = get_new_node();         
            head.item = item;
            head.next = NULL; 
            head.prev = NULL;
            tail = head; 
        }
        else {
            temp_node = get_new_node();     
            temp_node.item = item;
            temp_node.next = NULL;
            temp_node.prev = tail;
            tail.next = temp_node; 
            tail = temp_node;
        };
        
        size += 1;
    };
    
    // Add a list to the end of the linked_list in O(N).  
    add_list(my_list: list of <type>) is {
        for each in my_list {    
            add(it); 
        };          
    };
     
    // Add an item to the head of the linked_list in O(1).  
    add0(item: <type>) is {
        var temp_node: llist_node of <type>;
          
        if head == NULL {
            head = get_new_node();         
            head.item = item;
            head.next = NULL; 
            head.prev = NULL;     
            tail = head; 
        }
        else {    
            temp_node = get_new_node();         
            temp_node.item = item;
            temp_node.next = head;
            temp_node.prev = NULL;        
            head.prev = temp_node; 
            head = temp_node;
        };
        
        size += 1; 
    };
    
    // Add a list to the head of the linked_list in O(N).  
    add0_list(my_list: list of <type>) is {
        for each in reverse my_list {
            add0(it);  
        };
    };
    
    // Delete all items from a linked_list in O(N).  
    clear() is {  
        var temp_node: llist_node of <type>;
         
        if head != NULL {
            for i from 0 to size-1 do {  
                temp_node = head;   
                head = temp_node.next;
                delete_node(temp_node); 
            }; 
            
            tail = NULL;
            size = 0;
        };
    };
    
    // Delete an item by index from the linked_list in O(N).
    delete(index: uint) is {
        var temp_node: llist_node of <type>; 
        
        if head != NULL {
            if (index >= 0) and (index < size) {
                if index == 0 {
                    compute pop0();  
                }
                else if index == size-1 {
                    compute pop();  
                } 
                else {
                    temp_node = go_index(index);
                    (temp_node.prev).next = temp_node.next;
                    (temp_node.next).prev = temp_node.prev; 
                    delete_node(temp_node);  
                    size -= 1;
                };              
            }
            else {
                error("linked_list has only ", size," items - cannot access item ",index.as_a(int));
            };     
        }
        else {    
            error("linked_list is empty - cannot access item ",index.as_a(int));
        };
    };
        
    // Insert an item in a linked_list at a specified index in O(N).   
    insert(index: uint, item: <type>) is {       
        var temp_node: llist_node of <type>; 
        var temp_node2: llist_node of <type>; 
        
        if (index >= 0) and (index <= size) {
            if index == 0 {
                add0(item);  
            }
            else if index == size {
                add(item);  
            } 
            else {  
                temp_node = get_new_node();        
                temp_node2 = go_index(index);
                temp_node.item = item;
                (temp_node2.prev).next = temp_node;
                temp_node.prev = temp_node2.prev;
                temp_node.next = temp_node2;
                temp_node2.prev = temp_node;   
                size += 1; 
            };   
        }
        else {
                
            error("linked_list has only ", size," items - cannot access item ",index.as_a(int));
        };  
    };
    
    // Insert a list in a linked_list starting at a specified index in O(N).
    // TBD - O(N) replacing "insert" with smarter code with single "go_index"
    insert_list(index: uint, my_list: list of <type>) is {
        if (index >= 0) and (index <= size) {
            if index == 0 {
                add0_list(my_list)  
            }
            else if index == size {
                add_list(my_list)  
            }
            else {
                for each using index (idx) in my_list {
                    insert(index + idx, it); // bad!
                };
            };
        }
        else {
            error("linked_list has only ", size," items - cannot access item ",index.as_a(int));
        };    
    };
    
    // Remove and return the last linked_list item in O(1). 
    pop(): <type> is {
        var temp_node: llist_node of <type>;
        
        if head != NULL {
            temp_node = tail;
            
            if size == 1 {
                head = NULL;
                tail = NULL;
                size = 0;
            }
            else {
                tail = tail.prev;
                tail.next = NULL;
                delete_node(temp_node);  
                size -= 1;
            };
            
            return temp_node.item;
        }
        else {
            error("Cannot use 'pop()' method on an empty linked_list");  
        };
    };
    
    
    // Remove and return the first linked_list item in O(1).
    pop0(): <type> is {
        var temp_node: llist_node of <type>;
        
        if head != NULL {
            temp_node = head;
            
            if size == 1 {
                head = NULL;
                tail = NULL;
                size = 0;
            } 
            else {
                head = head.next;
                head.prev = NULL;
                delete_node(temp_node);    
                size -= 1;
            };
            
            return temp_node.item;
        }
        else {
            error("Cannot use 'pop0()' method on an empty linked_list");   
        };
    };
    
    // Add an item to the end of a linked_list in O(1).
    push(item: <type>) is {
        add(item);
    };    
        
    // Add an item to the head of a linked_list in O(1). 
    push0(item: <type>) is {
        add0(item);
    };
    
    // Check if a linked_list is empty in O(1). 
    is_empty(): bool is {
        if size == 0 {
            return TRUE;
        };
            
        return FALSE;     
    };
    
    // Return the size of a linked_list in O(1).
    size(): uint is {            
        return size;  
    };
    
    // Return the last item of a linked_list in O(1).
    top(): <type> is {
        if head != NULL {
            return tail.item;
        }
        else {
            error("Cannot use 'top()' method on an empty linked_list");  
        };
    };
    
    // Return the first item of a linked_list in O(1).
    top0(): <type> is {
        if head != NULL {
            return head.item;
        }
        else {
            error("Cannot use 'top0()' method on an empty linked_list");  
        };
    };
    
    // Return the index of the first item that is equal to the given item in O(N).
    first_index_of_item(item: <type>): int is {
        var temp_node: llist_node of <type>;
        temp_node = head;
        
        if head != NULL {
            for i from 0 to size-1 do {
                if temp_node.item == item {
                    return i;
                }
                else {
                    temp_node = temp_node.next;          
                };
            };
        };
             
        return UNDEF;    
    };
    
    // Return the index of the last item that is equal to the given item in O(N).
    last_index_of_item(item: <type>): int is {
        var temp_node: llist_node of <type>;
        temp_node = tail;
        
        if head != NULL { 
            for i from size-1 down to 0 do {
                if temp_node.item == item {
                    return i;
                }
                else {
                    temp_node = temp_node.prev;          
                };
            };
        };
            
        return UNDEF;     
    };
    
    // Check that a linked_list has at least one item that is equal to the given item in O(N).
    has_item(item: <type>): bool is {
        var temp_node: llist_node of <type>;
        temp_node = head;
        
        if head != NULL {
            for i from 0 to size-1 do {
                if temp_node.item == item {
                    return TRUE;
                }
                else {
                    temp_node = temp_node.next;          
                };
            };
        };
        
        return FALSE;  
    };
    
    // Return all items of linked_list as regular list in O(N).
    get_list(): list of <type> is {
        var temp_node: llist_node of <type>;
        temp_node = head;
        
        if head != NULL {
            for i from 0 to size-1 do {  
                result.add(temp_node.item);
                temp_node = temp_node.next;
            };
        };
        
    };
    
    // Internal methods
    
    // Memory allocation hook. Pool should be plugged in here.
    package get_new_node(): llist_node of <type> is {   
        result = new;
    };
    
    // Memory allocation hook. Pool should be plugged in here.
    package delete_node(item: llist_node of <type>) is empty;
    
    // Go to a specific index at the linked_list in O(N).
    package go_index(index: uint): llist_node of <type> is {
        var temp_node: llist_node of <type>;
        
        if head != NULL {
            if (index >= 0) and (index < size) {
                temp_node = head;
                
                if index == size-1 {
                    temp_node = tail; 
                };
                    
                if (index > 0) and (index < size-1) {
                    for i from 0 to index-1 do {
                        temp_node = temp_node.next;
                    };
                };
                    
                return temp_node;
            }
            else {
                error("linked_list has only ", size," items - cannot access item ",index.as_a(int));
            };    
        }
        else {
            error("linked_list is empty - cannot access item ",index.as_a(int)); 
        };
    };
};

// Iterator implementation for linked_list
template struct linked_list_iterator of <type> like iterator of <type> {
    //Internal field - point to the linked_list that inside the linked_list struct.
    package linked_list: linked_list of <type>;
    package iterator_pointer: llist_node of <type>;
    package iterator_index: int;
    
    //Return true if this linked_list has more items when traversing the linked_list in the forward direction. 
    //(In other words, return true if next() would return an item rather than throwing an error.)
    has_next(): bool is {
        return (not linked_list.is_empty()) and (iterator_index == -1 or iterator_index < linked_list.size() - 1);
    };
    
    //Return true if this linked_list has more items when traversing the linked_list in the reverse direction. 
    //(In other words, return true if prev() would return an item rather than throwing an error.)
    has_prev(): bool is {
        //same as iterator_index >0
        return iterator_pointer != NULL and iterator_pointer.prev != NULL;
    };

    //Return the next element in the linked_list and advances the cursor position. This method may be called repeatedly 
    //to iterate through the linked_list, or intermixed with calls to prev() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    next(): <type> is {
        if !has_next() {
            error("There isn't next item, linked_list has only ", linked_list.size()," items - cannot access item ", iterator_index + 1);
        };
        if iterator_index == -1 {
            iterator_pointer = linked_list.head;
        }
        else {
            iterator_pointer = iterator_pointer.next ;
        };
        iterator_index += 1;
        return iterator_pointer.item;
    };
    
    //Return the prev item in the linked_list and moves the cursor position backwards. This method may be called repeatedly 
    //to iterate through the linked_list backwards, or intermixed with calls to next() to go back and forth. (Note that alternating calls 
    //to next and prev will return the same item repeatedly.)
    prev(): <type> is {
        if !has_prev() {
            error("There isn't prev item, linked_list has only ", linked_list.size()," items - cannot access item ", iterator_index + 1);
        };
        iterator_pointer = iterator_pointer.prev;
        iterator_index -= 1;
        return iterator_pointer.item;
    };
    
    //Return the index of the cursor position, this is the index of the current item. This index of the current iten is the index 
    //of the item that last returned by call to either next() or prev().Note that it doesn't have meaning to use it before traversing 
    //on the linked_list.
    index(): int is {
        return iterator_index;
    };
    
    //Insert the specified item into the linked_list. The item is inserted immediately before the item that would be returned by next(), 
    //if any, and after the item that was returned by prev call to next(), if any. (If the linked_list had no items, the new item becomes 
    //the sole item.) A subsequent call to next would be unaffected, and a subsequent call to prev would return the item that returned 
    //by prev call to next(), if any.
    insert(item: <type>) is {
        if (iterator_index != -1) && (iterator_index > linked_list.size()) {
            error("Cannot inser at index ", iterator_index, " of a linked_list: linked_list has ", linked_list.size(), " items");
        };
        if iterator_index == - 1 {
            linked_list.add0(item);
            iterator_pointer = linked_list.head;
            iterator_index += 1;
            return;
        };
        if iterator_pointer == linked_list.tail {
            linked_list.add(item);
        }
        else {
            var temp_node: llist_node of <type> = linked_list.get_new_node();
            temp_node.item = item;
            temp_node.next = iterator_pointer.next;
            (temp_node.next).prev = temp_node;
            temp_node.prev = iterator_pointer;
            iterator_pointer.next = temp_node;
            linked_list.size += 1;
        };
        iterator_pointer = iterator_pointer.next;
        iterator_index += 1;
    };
    
    //Remove the current item from the linked_list. An error message is thrown if remove() is called before next() is invoked.
    remove() is {
        if iterator_index < 0 or iterator_index >= linked_list.size() {
            error("Cannot delete at index ", iterator_index, " of a linked_list: linked_list has ", linked_list.size(), " items");
        };
        if iterator_index == 0 {
            compute linked_list.pop0();  
            iterator_pointer = iterator_pointer.prev;
        }
        else if iterator_index == linked_list.size() - 1 {
            iterator_pointer = iterator_pointer.prev;
            compute linked_list.pop();  
        }
        else {
            var temp: llist_node of <type>;
            temp = iterator_pointer;
            (iterator_pointer.prev).next = iterator_pointer.next;
            (iterator_pointer.next).prev = iterator_pointer.prev; 
            iterator_pointer = iterator_pointer.prev;
            linked_list.delete_node(temp);  
            linked_list.size -= 1;
        }; 
        iterator_index -= 1;
    };

    //Replace the current item with the specified item, This is the item last returned by call to either next() or prev().
    set(item: <type>) is {
        if iterator_index < 0 {
            error("Cannot access item ",iterator_index," of a linked_list - index must be >= 0.");
        };
        if linked_list.is_empty() {
            error("linked_list is empty - cannot access item ",iterator_index);
        };
        if iterator_index >= linked_list.size() {
            error("linked_list has only ", linked_list.size()," items - cannot access item ", iterator_index);
        };
        iterator_pointer.item = item;  
    };
};


'>
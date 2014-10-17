//----------------------------------------------------------------------
//   Copyright 2014 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License. You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

<'

package etl;

import e/container.e;

#define INCREASE_SIZE 2;
#define REDUCE_SIZE 4;

//Implements deque by circular array based on regular list.
//The point of this container is that head modification operations like add0/push0/pop0 in O(1),
//while for regular list they are O(N) operations. The price is that most regular operations 
//are a little more expensive, though asymptotically the same.
template struct deque of <type> like container of <type> {
    
    // Internal fields of deque
    // The buffer that contains all the items. Shouldn't be accessed and changed bypassing the API!
    package items: list of <type>;
    // State variables
    package front: uint;
    package rear: uint; 
    package size: uint;
    
    // API Methods
    
    //Return iterator instance of deque.
    get_iterator(): iterator of <type> is {
           result = new deque_iterator of <type> with {
            //Set the vector in the vector_iterator struct to point to the vector that inside the vector struct
            it.deque = me;
            //Set the index of the iterator.
            it.iterator_index = - 1;
        };
    };
    
    //Set an item at a specified index in O(1).
    set(index: uint,item: <type>) is {
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a deque - index must be >= 0.");
        };
        
        if is_empty() {
            error("Deque is empty - cannot access item ",index);
        };
        
        if index >= size {
            error("Deque has only ", size," items - cannot access item ", index);
        };
        
        items[(front + index) % items.size()] = item;
    };
    
    //Return an item at a specified index in O(1).
    get(index :uint): <type> is {
        if index.as_a(int) < 0 {
            error("Cannot access item ",index.as_a(int)," of a deque - index must be >= 0.");
        };
        if is_empty() {
            error("Deque is empty - cannot access item ",index);
        };
        if index >= size {
            error("Deque has only ", size," items - cannot access item ", index);
        };
        result = items[(front + index) % items.size()];
    };
    
    //Add an item to the end of deque in O(1).
    add(item: <type>) is {
        push(item);
    };
    
    //Add an item to the head of deque in O(1).
    add0(item: <type>) is {
        push0(item);
    };
    
    //Delete all items from deque.
    clear() is {
        items.clear();
        front = 0;
        rear = 0;
        size = 0;
    };
    
    //Delete an item from deque at a specified index in O(N).
    delete(index: uint) is {
        var default_value: <type>;
        
        if index >= size or index.as_a(int) < 0 {
            error("Cannot delete at index ", index.as_a(int), " of a deque: deque has ", size, " items");
        };
        
        if index == 0 {
            compute pop0();
            return;
        };
        
        if index == size - 1{
            compute pop();
            return;
        };
        
        if items.size() >= size * REDUCE_SIZE {
            copy_and_resize();
        };
        
        //Shift left the whole items from the given index.
        for i from front + index to front + size - 2 {
            items[i % items.size()] = items[(i + 1) % items.size()];
        };
        
        rear = rear == 0 ? items.size() - 1: rear - 1;
        //Delete the item from the deque.
        items[rear] = default_value;
        size -= 1;
    };
    
    //Insert an item to deque at a specified index in O(N).
    insert(index: uint, item: <type>) is {
        //Check if index is valid;
        if index > size or index.as_a(int) < 0 {
            error("Cannot insert at index ", index.as_a(int), " of a deque: deque has ", size, " items");
        };
        
        if index == 0 {
            push0(item);
            return;
        };
        
        if index == size {
            push(item);
            return;
        };
        
        //If the deque is full, a new double size memory block is allocated, and the deque is copied to it.
        if size == items.size() {
            copy_and_resize();
        };
        
        //Shift right the whole items from the given index.
        for i from front + size down to front + index {
            items[i % items.size()]=items[(i - 1) % items.size()]
        };
        
        items[(front + index) % items.size()] = item;
        rear = (rear + 1) % items.size();
        size += 1;
    };
    
    //Remove and return the last item of deque in O(1).
    pop(): <type> is {
        var default_value: <type>;
        
        if is_empty() {
            error("Cannot use 'pop()' method on an empty deque");
        };
        
        if items.size() >= size * REDUCE_SIZE {
            copy_and_resize();
        };
        
        size -= 1;
        rear = rear == 0 ? items.size() - 1: rear - 1;
        result = items[rear];
        
        //Delete the item from the deque.
        items[rear] = default_value;
    };
    
    //Remove and return the first item of deque in O(1).
    pop0(): <type> is {
        var default_value: <type>;
        
        if is_empty() {
            error("Cannot use 'pop0()' method on an empty deque.");
        };
        
        if items.size() >= size * REDUCE_SIZE{
            copy_and_resize();
        };
        
        result = items[front];
        size -= 1;
        
        //Delete the item from the deque.
        items[front] = default_value;
        front = (front + 1) % items.size();
    };  
    
    //Add an item to the end of deque (same as add(item)) in O(1).
    push(item: <type>) is { 
        //If the deque is full, a new double size memory block is allocated, and the deque is copied to it.
        if is_empty() == TRUE {
            items.resize(2);
        }
        else if size  == items.size(){  
            copy_and_resize();
        };
        
        size += 1;
        items[rear] = item;
        rear = (rear + 1) % items.size();
    };
    
    //Add an item to the head of a container (same as add0(item)) in O(1).
    push0(item: <type>) is {
         //If the deque is full, a new double size memory block is allocated, and the deque is copied to it.
        if is_empty() == TRUE {
            items.resize(2);
            front = 1;
            rear = (rear + 1) % items.size();
        } 
        else if size  == items.size(){ 
            copy_and_resize();
        };
        
        size += 1;
        front = front == 0 ? items.size() - 1: front - 1; 
        items[front] = item;
    };
    
    //Check if deque is empty in O(1);
    is_empty(): bool is {
        return size == 0;
    };
    
    //Return the number or elements in deque in O(1).
    size(): uint is {
        return size;
    };
    
    //Return the last item in a container in O(1).
    top(): <type> is {
        if is_empty(){
            error("Cannot use 'top()' method on an empty deque.");
        };
        result = rear == 0 ? items[items.size() - 1]: items[(rear - 1)]; 
    };
    
    //Return the first item of a container in O(1).
    top0(): <type> is {
        if is_empty(){
            error("Cannot use 'top0()' method on an empty deque.");
        };
        return items[front];
    };
  
    //Return the index of the first item like the given item, or return UNDEF 
    //if there is no such item. Complexity O(N).
    first_index_of_item(item: <type>): int is {
        for i from 0 to size - 1 {
            if items[(front + i) % items.size()] == item {
                return i;
            }
        };
        return UNDEF;
    };
    
    //Return TRUE if the container contains at least one item like the given item, 
    //or returns FALSE if there is no such item. Complexity O(N).
    has_item(item: <type>): bool is {
         for i from 0 to size - 1 {
            if items[(front + i) % items.size()] == item {
                return TRUE;
            }
        };
        return FALSE;
    };

    //Return the index of the last item like the given item, or returns UNDEF 
    //if there is no such item. Complexity O(N).
    last_index_of_item(item: <type>): int is {
        for i from size - 1 down to 0 {
            if items[(front + i) % items.size()] == item {
                return i % items.size();
            };
        };
        return UNDEF;
    };
    
    //Return the items of the container in a list, Complexity O(N).
    get_list(): list of <type> is {
        if !is_empty(){
            for i from 0 to size - 1 {
                result.add(items[(front + i) % items.size()]);  
            };
        };
    };
    
    //Internal! Whenever a deque needs more memory, a new double-size memory block is allocated, 
    //and the deque is copied to it. When this method copies the old deque to the new one, 
    //it fixes the deque not to be circular. (The old memory block is freed at the next garbage collection.)
    package copy_and_resize() is {
        var tmp: list of <type>;
        tmp.resize(size * INCREASE_SIZE);
        
        for i from 0 to size - 1 {
            tmp[i] = items[(front + i) % items.size()];
        };
        
        front = 0;
        rear = size; 
        items.clear();
        items = tmp;
    };
};

// Iterator implementation for deque
template struct deque_iterator of <type> like iterator of <type> {
    
    //Internal field - point to the deque that inside the deque struct.
    package deque: deque of <type>;
    package iterator_index: int;
    
    //Return true if this deque has more items when traversing the deque in the forward direction. 
    //(In other words, returns true if next() would return an item rather than throwing an error.)
    has_next(): bool is {
        return (not deque.is_empty()) and (iterator_index == - 1 or iterator_index < deque.size() - 1);
    };
    
    //Return true if this deque has more items when traversing the deque in the reverse direction. 
    //(In other words, returns true if prev() would return an item rather than throwing an error.)
    has_prev(): bool is {
        return iterator_index > 0;
    };

    //Return the next element in the deque and advances the cursor position. This method may be called 
    //repeatedly to iterate through the deque, or intermixed with calls to prev() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    next(): <type> is {
        if !has_next() {
            error("There isn't next item, Deque has only ", deque.size(), " items - cannot access item ", iterator_index + 1);
        };
        iterator_index += 1;
        return deque.items[(iterator_index + deque.front) % deque.items.size()];
    };
    
    //Return the prev item in the deque and moves the cursor position backwards. This method may be called 
    //repeatedly to iterate through the deque backwards, or intermixed with calls to next() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    prev(): <type> is {
        if !has_prev() {
            error("There isn't prev item, Deque has only ", deque.size(), " items - cannot access item ", iterator_index + 1);
        };
        iterator_index -= 1;
        return deque.items[(iterator_index + deque.front) % deque.items.size()];
    };
    
    //Return the index of the cursor position, this is the index of the current item. This index 
    //of the current iten is the index of the item that last returned by call to either next() or prev().
    //Note that it doesn't have meaning to use it before traversing on the deque.
    index(): int is {--To check if to do error message.
        return iterator_index;
    };
    
    //Insert the specified item into the deque. The item is inserted immediately before the item 
    //that would be returned by next(), if any, and after the item that was returned by prev call to next(), 
    //if any. (If the deque had no items, the new item becomes the sole item.) A subsequent call to next 
    //would be unaffected, and a subsequent call to prev would return the item that returned 
    //by prev call to next(), if any.
    insert(item: <type>) is {
        iterator_index += 1;
        deque.insert(iterator_index,item);
    };
    
    //Remove the current item from the deque. An error message is thrown if remove() is called 
    //before next() is invoked.
    remove() is {
        deque.delete(iterator_index);
        iterator_index -= 1;
    };

    //Replace the current item with the specified item, This is the item last returned by call 
    //to either next() or prev().
    set(item: <type>) is {
        deque.set(iterator_index,item);  
    };
};

#undef INCREASE_SIZE;
#undef REDUCE_SIZE;
    
'>  
 
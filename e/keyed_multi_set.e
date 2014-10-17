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

// Used for internal data structure.
package template struct klist_node of <type> like base_struct {
    value: <type>;
    indices: list of int;
};

// Implements keyed_multi_set, based on regular list and keyed list of indices per key. 
// Similar to regular "list (key:it) of <type>". (A data structure similar to "list (key:<field>) of <type>"
// will be implemented as keyed_multi_map.) The main difference is that in case that there are multiple 
// equal key, behaviour is well defined: key operations return the last known index, and if the last 
//is removed, previous known is found, and so on, in stack fasion.
// There is some significan memory overhead related to that, which can be minimized by enhancing the mechanism 
// and plugging in a pool of klist_node. Some CPU overhead also exists, but asymptotically it's just as good as
// keyed list.
template struct keyed_multi_set of <type> like container of <type> {
    
    // List that represents the contents of keyed_set. In theory, can be read directly. However, since any change 
    // of it will probably break the consistency, ANY access should be avoided.
    package vec: list of <type>; 
    // List of indices per key. A little too heavy, out of assumption that most keys are unique can be optimized 
    // by splitting into two lists: first of pair <key, singe_index>, much lighter, and the second like this, 
    // <key, multiple_indices>. TBD.
    package !klist: list (key:value) of klist_node of <type>;
     
    // API methods
    
    // Return iterator of keyed_multi_set.
    get_iterator(): iterator of <type> is {
        result = new keyed_multi_set_iterator of <type> with {
            //Set keyed_multi_set pointer for the iterator
            it. keyed_multi_set_ins = me;
            //Set the index of the iterator.
            it.iterator_index = -1;
        };
    };
    
    // Set an item at a specified index in O(M), where M is number of equal keys.
    set(my_index: uint, item: <type>) is {
        var item_node: klist_node of <type>;
        var klist_index: uint;
        var set_index: int;
      
        if my_index.as_a(int) < 0 {
            error("Cannot access item ", my_index.as_a(int), " of keyed_multi_set - index must be >= 0.");
        };
            
        if is_empty() {
            error("keyed_multi_set is empty - cannot access item ", my_index)      
        };
        
        if my_index >= vec.size() {
            error("keyed_multi_set has only ", vec.size(), " items - cannot access item ", my_index);
        };
        
        klist_index = klist.key_index(vec[my_index]);
        
        if klist_index == UNDEF {
            error("Inconsistency, the item at index ", my_index, " is not in the internal list of keys.");
        };
        
        vec[my_index] = item;
        set_index = klist[klist_index].indices.first_index(it == my_index);
                                  
        if set_index != UNDEF {
            if klist[klist_index].indices.size() == 1 {
                var tmp_node := klist[klist_index];
                klist.fast_delete(klist_index);
                delete_node(tmp_node);
            }
            else {
                klist[klist_index].indices.delete(set_index);
            };
        }  
        else {
            error("Inconsistency, the index ", my_index, " is not in the internal list of indices for the key.");
        };
        
        klist_index = klist.key_index(item);
        if klist_index != UNDEF {
            klist[klist_index].indices.add(my_index);
        }
        else {
            item_node = get_new_node();
            item_node.value = item;
            item_node.indices.add(my_index);
            klist.add(item_node);
        };
    };
    
    // Return an item at a specified index in O(1).
    get(index: uint): <type> is {
        if index.as_a(int) < 0 {
            error("Cannot access item ", index.as_a(int), " of keyed_multi_set - index must be >= 0.");
        };
        
        if is_empty() {
            error("keyed_multi_set is empty - cannot access item ", index);
        };
              
        if index >= vec.size() {
            error("keyed_multi_set has only ", vec.size()," items - cannot access item ", index);
        };    
        
        return vec[index];
    };
    
    // Add an item to the end of keyed_multi_set in O(alpha) - a little over O(1) keyed list operation overhead.
    add(item: <type>) is {
        var item_node: klist_node of <type>;
        var klist_index: uint;
        vec.add(item);
        
        klist_index = klist.key_index(item);
        if klist_index != UNDEF {
            klist[klist_index].indices.add(vec.size()-1);
        }
        else {
            item_node = get_new_node();
            item_node.value = item;
            item_node.indices.add(vec.size()-1);
            klist.add(item_node);
        };
    }; 
    
    // Add a list to the end of keyed_multi_set in O(N * alpha) - a little over O(N) keyed list operation overhead.
    add_list(my_list: list of <type>) is {
        for i from 0 to my_list.size()-1 {  
            add(my_list[i]); 
        };
    };
    
    // Add an item to the head of keyed_multi_set in O(N).
    add0(item: <type>) is {
        var item_node: klist_node of <type>;
        var klist_index: uint;
        vec.add0(item);
        modify_indices(0,1);
        
        klist_index = klist.key_index(item);
        if klist_index != UNDEF {
            klist[klist_index].indices.add(0);
        }
        else {
            item_node = get_new_node();
            item_node.value = item;
            item_node.indices.add(0);
            klist.add(item_node);
        };
    }; 
    
    // Add a list to the head of keyed_multi_set in O(N * alpha) - a little over O(N) keyed list operation overhead.
    add0_list(my_list: list of <type>) is {
        var item_node: klist_node of <type>;
        var klist_index: uint;
        vec.add0(my_list);
        modify_indices(0, my_list.size()); 
        
        for each (item) in my_list {
            klist_index = klist.key_index(item);
            
            if klist_index != UNDEF {
                klist[klist_index].indices.add(index);
            }
            else {
                item_node = get_new_node();
                item_node.value = item;
                item_node.indices.add(index);
                klist.add(item_node);
            };
        };
    };

    // Delete items from keyed_multi_set in O(N).
    clear() is {
        vec.clear();
        for each in klist {
            delete_node(it)
        };
        klist.clear();
    };

    // Delete an item from keyed_multi_set at a specified index in O(N).
    delete(my_index: uint) is {
        var klist_index: uint;
        var delete_index: int;
        
        if vec.size() > 0 {
            if (my_index >= 0) and (my_index < vec.size()) {
                klist_index =  klist.key_index(vec[my_index]);
                
                if klist_index == UNDEF {
                    error("Inconsistency, the item at index ", my_index," is not in the internal list of keys.");
                };
                
                delete_index = klist[klist_index].indices.first_index(it == my_index);
                
                if delete_index == UNDEF {
                    error("Inconsistency, the index ", my_index, " is not in the internal list of indices for the key.");
                };
                
                if klist[klist_index].indices.size() == 1 {
                    var tmp_node := klist[klist_index];
                    klist.fast_delete(klist_index);
                    delete_node(tmp_node);
                }
                else {
                    klist[klist_index].indices.delete(delete_index);
                };

                modify_indices(my_index, -1);
                vec.delete(my_index);
            }
            else {
                error("keyed_multi_set has only ", vec.size(), " items - cannot access item ", my_index.as_a(int)); 
            }; 
        }
        else {
            error("keyed_multi_set is empty - cannot access item ", my_index.as_a(int)); 
        };
    };
  
 
    // Insert an item in keyed_multi_set at a specified index in O(N).
    insert(index: uint, item: <type>) is {
        var klist_index: uint;
        var item_node: klist_node of <type>;
            
        if (index >= 0) and (index <= vec.size()) { 
            if index == vec.size() {      
                add(item);
            }
            else {   
                modify_indices(index, 1);
                
                klist_index = klist.key_index(item);
                if klist_index != UNDEF {
                    klist[klist_index].indices.add(index);
                }
                else {
                    item_node = get_new_node();
                    item_node.value = item;
                    item_node.indices.add(index);
                    klist.add(item_node);
                };
                    
                vec.insert(index, item); 
            };  
        }
        else {
            error("keyed_multi_set has only ", vec.size()," items - cannot insert at index ", index.as_a(int)); 
        }; 
    };

    // Insert a list in keyed_multi_set starting at a specified index in O(N * alpha) - a little over O(N).
    insert_list(index: uint, my_list: list of <type>) is {
        
        var klist_index: uint;
        var item_node: klist_node of <type>;
       
        if (index >= 0) and (index <= vec.size()) { 
            if index == vec.size() { 
                add_list(my_list);
            }
            else {           
                modify_indices(index, my_list.size());  
                
                for each (item) using index (idx) in my_list {
                    klist_index = klist.key_index(item);
            
                    if klist_index != UNDEF {
                        klist[klist_index].indices.add(index + idx);
                    }
                    else {
                        item_node = get_new_node();
                        item_node.value = item;
                        item_node.indices.add(index + idx);
                        klist.add(item_node);
                    };
                };
                
                vec.insert(index, my_list);         
            };
        }
        else {
            error("keyed_multi_set has only ", vec.size()," items - cannot insert list at index ",index.as_a(int)); 
        }; 
       
    };
    
    // Remove and return the last keyed_multi_set item in O(M), where M is number of equal keys.
    pop(): <type> is {
        var klist_index: uint;
        var pop_index: int;
        var size := vec.size();
        
        if size > 0 {
            klist_index = klist.key_index(vec[size-1]);
            
            if klist_index == UNDEF {
                error("Inconsistency, the item at index ", size-1, " is not in the internal list of keys.");
            };
            
            pop_index = klist[klist_index].indices.last_index(it == size-1);
            
            if pop_index != UNDEF {
                if klist[klist_index].indices.size() == 1 {
                    var tmp_node := klist[klist_index];
                    klist.fast_delete(klist_index);
                    delete_node(tmp_node);
                }
                else {
                    klist[klist_index].indices.delete(pop_index);
                };
            }
            else {
                error("Inconsistency, the index ", size-1, " is not in the internal list of indices for the key.");
            };    
        }
        else {
            error("Cannot use 'pop()' method on an empty keyed_multi_set");  
        };

        return vec.pop();
    };
    
    // Remove and return the first keyed_multi_set item in O(N).
    pop0(): <type> is {     
        var klist_index: uint;
        var pop0_index: int;
    
        if vec.size() > 0 {
            klist_index = klist.key_index(vec[0]);
            
            if klist_index == UNDEF {
                error("Inconsistency, the item at index 0 is not in the internal list of keys.");
            };
            
            pop0_index = klist[klist_index].indices.first_index(it == 0);
              
            if pop0_index != UNDEF {
                if klist[klist_index].indices.size() == 1 {
                    var tmp_node := klist[klist_index];
                    klist.fast_delete(klist_index);
                    delete_node(tmp_node);
                }
                else { 
                    klist[klist_index].indices.delete(pop0_index);
                };
            }
            else {
                error("Inconsistency, the index 0 is not in the internal list of indices for the key.");
            };
        }
        else {
            error("Cannot use 'pop0()' method on an empty keyed_multi_set");  
        };

        modify_indices(0, -1);
        return vec.pop0()
    };
    
    // Add an item to the end of keyed_multi_set in O(alpha).
    push(item: <type>) is {
        add(item);
    };    
        
    // Add an item to the head of keyed_multi_set in O(N).
    push0(item: <type>) is {    
        add0(item);
    };
    
    // Check if keyed_multi_set is empty in O(1).
    is_empty(): bool is {    
        return vec.is_empty();
    };
	
    // Return the number of items of keyed_multi_set in O(1). 
    size(): uint is {
        return vec.size();  
    };
    
    // Return the last item of keyed_multi_set in O(1).
    top(): <type> is {      
        if vec.size() > 0 {
            return vec.top();
        }
        else {   
            error("Cannot use 'top()' method on an empty keyed_multi_set"); 
        };
    };
    
    // Return the first item of keyed_multi_set in O(1).
    top0(): <type> is {
        if vec.size() > 0 {
            return vec.top0();
        }
        else {
            error("Cannot use 'top()' method on an empty keyed_multi_set"); 
        };
    };
    
    // Return the index of the first item that is equal to the given item in O(M + alpha).
    first_index_of_item(item: <type>): int is {
        var klist_index: int = klist.key_index(item);
        
        if klist_index == UNDEF {
            return UNDEF;
        }
        else {
            return klist[klist_index].indices.min(it);
        };
    };
    
    // Return the index of the last item that is equal to the given item in O(M + alpha).
    last_index_of_item(item: <type>): int is {
        var klist_index: int = klist.key_index(item);
        
        if klist_index == UNDEF {
            return UNDEF;
        }
        else {
            return klist[klist_index].indices.max(it);
        };
    };
     
    // Check that keyed_multi_set has at least one item that is equal to the given item in O(alpha).
    has_item(item: <type>): bool is {
        return klist.key_exists(item);
    };
    
    // Return all the items of tne keyed_multi_set as a list in O(N).
    get_list(): list of <type> is {
        return vec.copy();
    }; 
    
    // Return the key if such key exists in keyed_multi_set, otherwise returns default value for the <type> in O(alpha).
    key(key_item: <type>):  <type> is {
        return vec[klist.key(key_item).indices.top()];
    };
    
    // Return the last (by insertion time) index of a particular key, in O(alpha).
    key_index(key_item: <type>): int is {
        var klist_index: int = klist.key_index(key_item);
        
        if klist_index != UNDEF {
            return klist[klist_index].indices.top(); 
        }
        else {
            return UNDEF; 
        };
    };
    
    // Return all the indices of a particular key, in O(alpha + M).
    all_key_indices(key_item: <type>): list of int is {
        var klist_index: int = klist.key_index(key_item);
        
        if klist_index != UNDEF {
            result.add(klist[klist_index].indices); 
        };
    };
    
    // Check that a particular key exists in keyed_multi_set, in O(alpha).
    key_exists(key_item: <type>): bool is {
        return klist.key_exists(key_item);  
    };
    
    // Internal methods
    
    // Memory allocation hook. Pool should be plugged in here.
    package get_new_node(): klist_node of <type> is {
        result = new;
    };
    
    // Memory allocation hook. Pool should be plugged in here.
    package delete_node(item: klist_node of <type>) is empty;
    
    // Increase or Decrease in spesific value all indices of each value in keyed_multi_set 
    // that is large or equal to index of vec in O(N).
    package modify_indices(index: int, value: int) is {
        if(vec.size() > 0) {
            if (index >= 0) and (index < vec.size()) { 
                for i from 0 to klist.size()-1 {
                    for j from 0 to klist[i].indices.size()-1 {
                        if klist[i].indices[j] >= index {
                            klist[i].indices[j] += value;       
                        };
                    };
                };
            }
            else {
                error("keyed_multi_set has only ", vec.size(), " items - cannot access item ", index.as_a(int));
            };
        }
        else {
            error("keyed_multi_set is empty - cannot access item ", index.as_a(int));  
        }; 
    };
};

// Iterator implementation for keyed_multi_set
template struct keyed_multi_set_iterator of <type> like iterator of <type> {
    //Internal field - point to the keyed_multi_set that inside the keyed_multi_set struct.
    package keyed_multi_set_ins: keyed_multi_set of <type>;
    package iterator_index: int;
    
    //Return true if this keyed_multi_set has more items when traversing the keyed_multi_set in the forward direction. 
    //(In other words, return true if next() would return an item rather than throwing an error.)
    has_next(): bool is {
        return (not keyed_multi_set_ins.is_empty()) and (iterator_index == - 1 or iterator_index < keyed_multi_set_ins.size() - 1);
    };
    
    //Return true if this keyed_multi_set has more items when traversing the keyed_multi_setin the reverse direction. 
    //(In other words, return true if prev() would return an item rather than throwing an error.)
    has_prev(): bool is {
        return iterator_index > 0;
    };

    //Return the next element in the keyed_multi_set and advances the cursor position. This method may be called 
    //repeatedly to iterate through the keyed_multi_set, or intermixed with calls to prev() to go back and forth. 
    //(Note that alternating calls to next and prev will return the same item repeatedly.)
    next(): <type> is {
        if !has_next() {
            error("There isn't next item, keyed_multi_set has only ", keyed_multi_set_ins.size(), " items - cannot access item ", iterator_index + 1);
        };
        iterator_index += 1;
        return keyed_multi_set_ins.vec[iterator_index];
    };
    
    //Return the prev item in the keyed_multi_set and moves the cursor position backwards. This method may be called 
    //repeatedly to iterate through the keyed_multi_set backwards, or intermixed with calls to next() to go back
    //and forth. (Note that alternating calls to next and prev will return the same item repeatedly.)
    prev(): <type> is {
        if !has_prev() {
            error("There isn't prev item, keyed_multi_set has only ", keyed_multi_set_ins.size(), " items - cannot access item ", iterator_index + 1);
        };
        iterator_index -= 1;
        return keyed_multi_set_ins.vec[iterator_index];
    };
    
    //Return the index of the cursor position, this is the index of the current item. This index of the current item 
    //is the index of the item that last returned by call to either next() or prev().Note that it doesn't have meaning 
    //to use it before traversing on the keyed_multi_set.
    index(): int is {--To check if to do error message.
        return iterator_index;
    };
    
    //Insert the specified item into the keyed_multi_set. The item is inserted immediately before the item that would be 
    //returned by next(), if any, and after the item that was returned by prev call to next(), if any. 
    //(If the keyed_multi_set had no items, the new item becomes the sole item.) A subsequent call to next would be 
    //unaffected, and a subsequent call to prev would return the item that returned by prev call to next(), if any.
    insert(item: <type>) is {
        iterator_index += 1;
        keyed_multi_set_ins.insert(iterator_index,item);
    };
    
    //Remove the current item from the keyed_multi_set. An error message is thrown if remove() is called before 
    //next() is invoked.
    remove() is {
        keyed_multi_set_ins.delete(iterator_index);
        iterator_index -= 1;
    };

    //Replace the current item with the specified item, This is the item last returned by call to either next() or prev().
    set(item: <type>) is {
        keyed_multi_set_ins.set(iterator_index,item);  
    };
};


'>
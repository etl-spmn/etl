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
import e/iterator.e;

// Abstract ordered container template. 
// It declares an API, similar to API of regular list, which is implemented by specific containers.
// It inherits from base_struct, this means that it's not generatable, and can't have temporal struct members.
template struct container of <type> like base_struct {
    
    //Return iterator instance of container.
    get_iterator(): iterator of <type> is undefined;
    
    //Set an item at a specified index.
    set(index: uint, item: <type>) is undefined;
    
    //Return an item at a specified index.
    get(index: uint): <type> is undefined;
    
    //Add an item to the end of container.
    add(item: <type>) is undefined;
    
    //Add a list to the end of container.
    add_list(list: list of <type>) is undefined;
    
    //Add an item to the head of container.
    add0(item: <type>) is undefined;
    
    //Add a list to the head of container.
    add0_list(list: list of <type>) is undefined;
    
    //Delete all items from container.
    clear() is undefined;
    
    //Delete an item from container at a specified index.
    delete(index: uint) is undefined;
    
    //Delete an item without adjusting all indexes: 
    //replace item at specified index with the last item of container and decrease the size. 
    //All items following the deleted item keep their original indices except that 
    //the original last index is now out of reach.
    fast_delete(index: uint) is undefined;
    
    //Insert an item to container at specified index.
    insert(index: uint, item: <type>) is undefined;
    
    //Insert a list to container starting at a specified index.
    insert_list(index: uint, list: list of <type>) is undefined;
    
    //Remove and return the last container item.
    pop(): <type> is undefined;
    
    //Remove and return the first container item.
    pop0(): <type> is undefined;
    
    //Add an item to the end of container (same as add(item)).
    push(item: <type>) is undefined;
    
    //Add an item to the head of container (same as add0(item)).
    push0(item: <type>) is undefined;
    
    //Change the size of container.
    resize(size: uint) is undefined;
    
    //Check if container doesn't have any items.
    is_empty(): bool is undefined;
    
    //Return the size of container.
    size(): uint is undefined;
    
    //Return the last item in container.
    top(): <type> is undefined;
    
    //Return the first item of container.
    top0(): <type> is undefined;
    
    //Return the index of the first item equal (==) to the given item, 
    //or return UNDEF if there is no such item.
    first_index_of_item(item: <type>): int is undefined;
    
    //Return TRUE if container contains at least one item equal (==) to the given item, 
    //or returns FALSE if there is no such item.
    has_item(item: <type>): bool is undefined;
    
    //Return the index of the last item equal (==) to the given item, 
    //or returns UNDEF if there is no such item.
    last_index_of_item(item: <type>): int is undefined;
    
    //Return the items of container as a list.
    get_list(): list of <type> is undefined;
    
};
    
'> 
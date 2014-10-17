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

//Abstract iterator for containers.
//It declares iterator API implemented by iterators of specific containers.
template struct iterator of <type> like base_struct {
    
    //Return true if there is a next item. Otherwise, returns false.
    has_next(): bool is undefined;
    
    //Return true if there is a prev item. Otherwise, returns false.
    has_prev(): bool is undefined;

    //Return the next item. An error message is thrown if there is no next item.
    next(): <type> is undefined;
    
    //Return the prev item. An error message is thrown if there is no prev item.
    prev(): <type> is undefined;
    
    //Return the index of the current item.
    index(): int is undefined;
    
    //Insert an item into the container in front of the item that will be returned by the next call to next().
    insert(item: <type>) is undefined;
    
    //Remove an item from the container in front of the item that will be returned by the next call to next().
    remove() is undefined;
 
    //Assign value to the current item. This is the item last returned by a call to either next() or prev().
    set(item: <type>) is undefined;

};
'>
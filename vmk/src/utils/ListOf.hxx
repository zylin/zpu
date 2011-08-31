/*
 *  Copyright 2007  Janick Bergeron
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

//
// Class definiton macros for specialized ListOfBase class
//

#include "ListOfBs.hxx"


class LISTOF : private ListOfBase {
public:
	LISTOF(): ListOfBase() {};
	~LISTOF() {};

	unsigned length()
		{ return ListOfBase::length(); };

	void  prepend(LISTOF_TYPE* obj)
		{ ListOfBase::prepend((void*)obj); };
	void  append(LISTOF_TYPE* obj)
		{ ListOfBase::append((void*)obj); };

	LISTOF_TYPE* pop()
		{ return (LISTOF_TYPE*) ListOfBase::pop(); };
	void  push(LISTOF_TYPE* obj) { prepend(obj); };
	void  flush(void (*destroy)(LISTOF_TYPE* obj) = NULL)
		{ ListOfBase::flush((Destroyer) destroy); };
};

class LISTOF_ITERATOR : private ListOfIteratorBase {
public:
	LISTOF_ITERATOR(LISTOF* onList)
	: ListOfIteratorBase((ListOfBase*) onList) {};
	~LISTOF_ITERATOR() {};

	LISTOF_TYPE* operator()()
		{ return (LISTOF_TYPE*) ListOfIteratorBase::operator()(); };
	LISTOF_TYPE* operator++()
		{ return (LISTOF_TYPE*) ListOfIteratorBase::operator++(); };

	LISTOF_TYPE* atHead()
		{ return (LISTOF_TYPE*) ListOfIteratorBase::atHead(); };
	LISTOF_TYPE* reset()
		{ return atHead(); };

	unsigned itemsLeft()
		{ return ListOfIteratorBase::itemsLeft(); };

	LISTOF_TYPE* replace(LISTOF_TYPE* obj)
		{ return (LISTOF_TYPE*) ListOfIteratorBase::replace((void*)obj); };
};

#undef LISTOF_TYPE
#undef LISTOF
#undef LISTOF_ITERATOR

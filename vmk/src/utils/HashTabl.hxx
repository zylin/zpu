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
// Class definition macros for HashTableBase
//

#if defined(HASHTABLE) && defined(HASHTABLE_ENTRY)

#include "HshTblBs.hxx"

class HASHTABLE : private HashTableBase {
public:
	HASHTABLE(unsigned size)
		: HashTableBase(size)
		{};

	~HASHTABLE()
		{};

#ifdef HPUX
        // Bug in g++ on HPUX: not calling the constructor
        // of file-level objects.
	void init(unsigned size)
		{
		    HashTableBase::init(size);
		};
#endif

	HASHTABLE_ENTRY* lookup(const char* key)
		{
			return (HASHTABLE_ENTRY*) HashTableBase::lookup(key);
		};
	void  insert(const char*      key,
		     HASHTABLE_ENTRY* entry)
		{
			HashTableBase::insert(key, (void*) entry);
		};
	HASHTABLE_ENTRY* replace(const char*      key,
		     		 HASHTABLE_ENTRY* entry)
		{
			return (HASHTABLE_ENTRY*) HashTableBase::replace(key, (void*) entry);
		};

	void flush(void (*destroy)(HASHTABLE_ENTRY* entry) = NULL)
		{
			HashTableBase::flush((void (*)(void*)) destroy);
		};
};

#ifdef HASHTABLE_ITERATOR

class HASHTABLE_ITERATOR : private HashTableIteratorBase {
public:
	HASHTABLE_ITERATOR(HASHTABLE* table)
		: HashTableIteratorBase((HashTableBase*) table)
		{};
	~HASHTABLE_ITERATOR()
		{};

	const char* reset()
		{ return HashTableIteratorBase::reset(); };
	const char* key()
		{ return HashTableIteratorBase::key(); };
	HASHTABLE_ENTRY* entry()
		{ return (HASHTABLE_ENTRY*) HashTableIteratorBase::entry(); };
	const char* operator++()
		{ return HashTableIteratorBase::operator++(); };
};

#undef HASHTABLE_ITERATOR
#endif

#undef HASHTABLE
#undef HASHTABLE_ENTRY
#endif

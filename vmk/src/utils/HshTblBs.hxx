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
// Base class for hash table
//

//
// String hash table class
//

#ifndef HASHTABLEBASE_HPP
#define HASHTABLEBASE_HPP

#ifndef NULL
#define NULL 0
#endif

class TableEntry {
private:
	TableEntry(const char* newKey,
		   void*       newEntry);
	~TableEntry();

	char*       key;
	void*       entry;
	TableEntry* next;

	friend class HashTableBase;
	friend class HashTableIteratorBase;
};


class HashTableBase {
protected:
	HashTableBase(unsigned size);
	~HashTableBase();

#ifdef HPUX
        void init(unsigned size);
#endif

	void* lookup(const char* key);
	void  insert(const char* key,
		     void*       entry);
	void* replace(const char* key,
		      void*       entry);

	void flush(void (*destroy)(void* entry) = NULL);

private:
	unsigned	tableSize;
	TableEntry**	table;

	unsigned hash(const char* key);

	friend class HashTableIteratorBase;
};


class HashTableIteratorBase {
protected:
	HashTableIteratorBase(HashTableBase* onTable);
	~HashTableIteratorBase();

	const char* reset();
	const char* key();
	void*       entry();
	const char* operator++();

private:
	HashTableBase* table;
	unsigned       index;
	TableEntry*    position;
};

#endif

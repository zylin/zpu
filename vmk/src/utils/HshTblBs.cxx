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

#include <string.h>
#include <stdio.h>

#include "HshTblBs.hxx"

//
// Class TableEntry
//
TableEntry::TableEntry(const char* newKey,
		       void*       newEntry)
	: key(strcpy(new char [strlen(newKey) + 1], newKey)),
	  entry(newEntry), next(NULL)
	{}

TableEntry::~TableEntry()
	{
		delete [] key;
	};

//
// Class HashTableBase
//
HashTableBase::HashTableBase(unsigned size)
	: tableSize((size > 256) ? 256 : size),
	  table(new TableEntry* [tableSize])
	{
		for (int i = 0; i < tableSize; table[i++] = NULL);
	}


HashTableBase::~HashTableBase()
	{
		for (int i = 0; i < tableSize; i++) {
			TableEntry* n;
			for (TableEntry* p = table[i]; p != NULL; p = n) {
				n = p->next;
				delete p;
			}
		}
		delete [] table;
	}

#ifdef HPUX
void
HashTableBase::init(unsigned size)
{
    tableSize = (size > 256) ? 256 : size;
    table = new TableEntry* [tableSize];
    for (int i = 0; i < tableSize; table[i++] = NULL);
}
#endif

void*
HashTableBase::lookup(const char* key)
	{
		TableEntry* e = table[hash(key)];
		while (e != NULL) {
			if (strcmp(e->key, key) == 0) return e->entry;
			e = e->next;
		}
		return NULL;
	}

void
HashTableBase::insert(const char* key,
		      void*       entry)
	{
		TableEntry* e = new TableEntry(key, entry);
		unsigned hashedKey = hash(key);
		e->next = table[hashedKey];
		table[hashedKey] = e;
	}

void*
HashTableBase::replace(const char* key,
		       void*       entry)
	{
		TableEntry* e = table[hash(key)];
		while (e != NULL) {
			if (strcmp(e->key, key) == 0) {
				void* oldEntry = e->entry;
				e->entry = entry;
				return oldEntry;
			}
			e = e->next;
		}
		insert(key, entry);
		return NULL;
	}

void
HashTableBase::flush(void (*destroy)(void* entry))
	{
		for (int i = 0; i < tableSize; i++) {
			TableEntry* n;
			for (TableEntry* p = table[i]; p != NULL; p = n) {
				n = p->next;
				if (destroy != NULL) destroy(p->entry);
				delete p;
			}
			table[i] = NULL;
		}
	}

unsigned
HashTableBase::hash(const char* key)
	{
		unsigned hashedKey = 0;
		for (const char* p = key; *p != '\0'; p++) {
			hashedKey ^= *p;
		}
		return hashedKey % tableSize;
	}


//
// Class HashTableIteratorBase
//
HashTableIteratorBase::HashTableIteratorBase(HashTableBase* onTable)
	: table(onTable), index(0), position(NULL)
	{}

HashTableIteratorBase::~HashTableIteratorBase()
	{}

const char*
HashTableIteratorBase::reset()
	{
		for (index = 0; index < table->tableSize; index++) {
			if (table->table[index] != NULL) {
				position = table->table[index];
				return position->key;
			}
		}
		return NULL;
	}

const char*
HashTableIteratorBase::key()
	{
		return (position == NULL) ? NULL : position->key;
	}

void*
HashTableIteratorBase::entry()
	{
		return (position == NULL) ? NULL : position->entry;
	}

const char*
HashTableIteratorBase::operator++()
	{
		while (index < table->tableSize) {
			while (position != NULL) {
				position = position->next;
				if (position != NULL) {
					return position->key;
				}
			}
			index++;
			if (index >= table->tableSize) {
				return NULL;
			}
			position = table->table[index];
			if (position != NULL) {
				return position->key;
			}
		}
		position = NULL;
		return NULL;
	}

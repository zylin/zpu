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
// Class declaration for ListOfBase
//
// A list of pointers to objects
//

#include "ListOfBs.hxx"

//
// Class ListElement
//
ListElement::ListElement(void* obj)
: content(obj), next(NULL)
	{}
ListElement::~ListElement()
	{}


//
// Class ListOfBase
//
ListOfBase::ListOfBase()
: head(NULL), tail(NULL), itemCount(0)
	{}

ListOfBase::~ListOfBase()
	{
		ListElement* next_el;
		for (ListElement* el = head; el != NULL; el = next_el) {
			next_el = el->next;
			delete el;
		}
	}

unsigned
ListOfBase::length()
	{
		return itemCount;
	}

void
ListOfBase::prepend(void* obj)
	{
		itemCount++;
		if (head != NULL && head->content == NULL) {
			head->content = obj;
		} else {
			ListElement* el = new ListElement(obj);
			el->next = head;
			if (head == NULL) tail = el;
			head = el;
		}
	}

void
ListOfBase::append(void* obj)
	{
		itemCount++;
		if (tail != NULL && tail->content == NULL) {
			tail->content = obj;
		} else {
			ListElement* el = new ListElement(obj);
			el->next = NULL;
			if (tail == NULL) head = el;
			else tail->next = el;
			tail = el;
		}
	}

void*
ListOfBase::pop()
	{
		if (head == NULL) return NULL;
		itemCount--;
		ListElement* el = head;
		void* obj = el->content;
		head = head->next;
		delete el;
		return obj;
	}

void
ListOfBase::flush(void (*destroy)(void* obj))
	{
		itemCount = 0;
		ListElement* next_el;
		for (ListElement* el = head; el != NULL; el = next_el) {
			if (destroy != NULL && el->content != NULL) {
				destroy(el->content);
			}
			next_el = el->next;
			delete el;
		}
		head = NULL;
		tail = NULL;
	}


//
// Class ListOfIteratorBase
//
ListOfIteratorBase::ListOfIteratorBase(ListOfBase* onList)
: list(onList), position(list->head)
	{
		while (position != NULL && position->content == NULL) {
			position = position->next;
		}
	}

ListOfIteratorBase::~ListOfIteratorBase()
	{}

void*
ListOfIteratorBase::operator()()
	{
		return (position == NULL) ? NULL : position->content;
	}

void*
ListOfIteratorBase::operator++()
	{
		if (position == NULL) return NULL;
		do {
			position = position->next;
		} while (position != NULL && position->content == NULL);
		return (position == NULL) ? NULL : position->content;
	}

void*
ListOfIteratorBase::atHead()
	{
		position = list->head;
		while (position != NULL && position->content == NULL) {
			position = position->next;
		}
		return (position == NULL) ? NULL : position->content;
	}

unsigned
ListOfIteratorBase::itemsLeft()
	{
		ListElement* el = position;
		unsigned     count = 0;
		while (el != NULL) {
			if (el->content != NULL) count++;
			el = el->next;
		}
		return count;
	}

void*
ListOfIteratorBase::replace(void* obj)
	{
		if (position == NULL) return NULL;
		void* oldObj = position->content;
		position->content = obj;
		if (obj == NULL) list->itemCount--;
		return oldObj;
	}

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

#ifndef LISTOFBASE
#define LISTOFBASE

#ifndef NULL
#define NULL 0
#endif

typedef void (*Destroyer)(void* obj);


class ListElement {
private:
	ListElement(void* obj);
	~ListElement();

	void*        content;
	ListElement* next;

	friend class ListOfBase;
	friend class ListOfIteratorBase;
};

class ListOfBase {
protected:
	ListOfBase();
	~ListOfBase();

	void  prepend(void* obj);
	void  append(void* obj);

	unsigned length();

	void* pop();
	void  push(void* obj) { prepend(obj); };
	void  flush(void (*destroy)(void* obj) = NULL);

private:
	ListElement* head;
	ListElement* tail;
	unsigned     itemCount;

	friend class ListOfIteratorBase;
};

class ListOfIteratorBase {
protected:
	ListOfIteratorBase(ListOfBase* onList);
	~ListOfIteratorBase();

	void* operator()();
	void* operator++();

	void* atHead();
	unsigned itemsLeft();

	void* replace(void* obj);

private:
	ListOfBase*  list;
	ListElement* position;
};
#endif

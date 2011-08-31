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

#include <stdio.h>

#ifndef BITARRAY_HXX
#define BITARRAY_HXX


class BitArray {
public:
	BitArray(unsigned size);
	~BitArray();

	void set(unsigned from, unsigned to, unsigned long value);
	unsigned long operator()(unsigned from, unsigned to);

	void print(FILE* fp = stdout);
	void print(unsigned from, unsigned to, FILE* fp = stdout);
private:
	unsigned length;
	unsigned* data;
	unsigned buflen;
};

#endif

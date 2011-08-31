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

#include "BitArray.hxx"

inline unsigned
word(unsigned pos)
{
	return pos / (sizeof(unsigned) * 8);
}
inline unsigned
bit(unsigned pos)
{
	return pos % (sizeof(unsigned) * 8);
}

BitArray::BitArray(unsigned size)
{
	length = size;
	buflen = size / (sizeof(unsigned) * 8) + 1;
	data = new unsigned [buflen];
	for (int i = 0; i < buflen; data[i++] = 0);
}

BitArray::~BitArray()
{
	delete [] data;
}

void
BitArray::set(unsigned from, unsigned to, unsigned long value)
{
	unsigned mask = 1;

	for (int i = from; i <= to; i++) {
		if (mask == 0) break;
		if (value & mask) data[word(i)] |= 1 << bit(i);
		else data[word(i)] &= ~(1 << bit(i));
		mask = mask << 1;
	}
}

unsigned long
BitArray::operator()(unsigned from, unsigned to)
{
	unsigned long v = 0;
	unsigned mask = 1;

	for (int i = from; i <= to; i++) {
		if (mask == 0) break;
		if (data[word(i)] & (1 << bit(i))) v |= mask;
		mask = mask << 1;
	}
	return v;
}

void
BitArray::print(FILE* fp)
{
	int c = 0;
	for (int i = 0; i < buflen; i++) {
		for (int j = 0; j < sizeof(unsigned) * 8; j++) {
			if (c >= length) break;
			fputc((data[i] & (1 << j)) ? '1' : '0', fp);
			c++;
		}
	}
	fputc('\n', fp);
}

void
BitArray::print(unsigned from, unsigned to, FILE* fp)
{
	for (unsigned i = from; i <= to; i++) {
		fputc((operator()(i, i)) ? '1' : '0', fp);
	}
	fputc('\n', fp);
}

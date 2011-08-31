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

#ifdef HPUX
# include <sys/sigevent.h>
#endif
#include <stdlib.h>
#define NMALLOC(n,t) ((t*) malloc((n) * sizeof(t)))
#include <string.h>
#include <dirent.h>
#include <stdio.h>


/*
 * Private functions defined in this file
 */
static int match(char* filename, char* pattern);


/*
 * String pool table for the array of filenames that matched the pattern
 */
static size_t  indexSize = 0;
static char**  table;
static size_t  poolSize  = 0;
static char*   strPool;
static int     idx     = 0;
static char*   pool;
void addToTable(char* str)
{
	/* Check if there is room in the pool index */
	if (idx == indexSize) {
		/* Grow the index to the string pool */
		if (indexSize == 0) {
			indexSize = 32;
			table = NMALLOC(indexSize, char*);
		} else {
			indexSize *= 2;
			table = (char**) realloc(table,
						 indexSize * sizeof(char*));
		}
	}
	if (str == NULL) {
		table[idx++] = NULL;
		return;
	}

	/* Check if there is room in the pool */
	if (poolSize == 0 || pool + strlen(str) + 1 - strPool > poolSize) {
		int i;

		/* Grow the string pool */
		if (poolSize == 0) {
			poolSize = indexSize * 16 * sizeof(char);
			strPool = NMALLOC(poolSize, char);
		} else {
			poolSize *= 2;
			strPool = (char*) realloc(strPool, poolSize);
		}
		/* Rebuild the index table */
		for (i = 0, pool = strPool; i < idx; i++) {
			table[i] = pool;
			pool += strlen(pool) + 1;
		}
	}

	/* Add the string to the pool */
	table[idx++] = pool;
	strcpy(pool, str);
	pool += strlen(pool) + 1;
}


/*
 * Find all filnames that match the specified pattern
 */
char**
glob(const char* path, const char* pattern)
{
	char fullPath[1024];
	char* p;
	FILE* ls;

	/* Initialize the string pool */
	idx = 0;
	pool = strPool;

	/* Get the list of files macthing the pattern */
#ifdef HPUX
	sprintf(fullPath, "cd %s; /bin/ls -1d %s", path, pattern);
#else
	sprintf(fullPath, "cd %s; /usr/bin/ls -1d %s", path, pattern);
#endif
	ls = popen(fullPath, "r");
	if (ls == NULL) {
	    fprintf(stderr, "Cannot get files matching pattern %s: ", fullPath+16);
	    perror(0);
	    addToTable(NULL);
	    return table;
	}
	
	/* Read the output of the 'ls' command, line by line */
	while (1) {
	    for (p = fullPath; (*p = fgetc(ls)) != '\n' && *p != EOF; p++);
	    if (p == fullPath) break;
	    *p = '\0';
	    addToTable(fullPath);
	}

	pclose(ls);

	addToTable(NULL);
	return table;
}


#ifdef TEST
#include <stdlib.h>

int
main(int argc, char* argv[])
{
	int i;
	for (i = 2; i < argc; i++) {
		int j;
		char** globbed;

		globbed = glob(argv[1], argv[i]);
		for (j = 0; globbed[j] != NULL; j++) {
			printf("%s\n", globbed[j]);
		}
	}
	return 0;
}
#endif

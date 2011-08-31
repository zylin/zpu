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
// Expand a string containing environment variables
//

#include <ctype.h>
#ifdef HPUX
# include <sys/sigevent.h>
#endif
#include <stdlib.h>
#include <stdio.h>

#include "envexp.h"

//|@environment variables@
//| Environment variables to be replaced are denoted by a '$' and may
//| be optionally enclosed between "{}" if they 
//| are not delimited by a non-alphanumeric character.
//| To specify a single '$', escape it by using '$$'. e.g.:
//|.ce 3
//| $VMKHOME/lib/vmkrc
//| /home/${MOUNT_POINT}a1/here
//| /the/dollar$$sign/is/escaped
const char*
expand_env(const char* orig)
{
	static char expanded[1024];
	char* to = expanded;
	char* from;
	char var[64];
	char* v;

	for (from = (char*) orig; *from != '\0'; ) {

		if (*from != '$') {
			*to++ = *from++;
			continue;
		}

		if (*++from == '$') {
			// $$
			*to++ = *from++;
			continue;
		}

		v = var;
		if (*from == '{') {
			// ${var}
			while (*++from != '}' && *from != '\0') *v++ = *from;
			if (*from != '\0') from++;
		} else {
			// $var
			while (isalnum(*from) || *from == '_') *v++ = *from++;
		}
		*v = '\0';
		if ((v = getenv(var)) == NULL) continue;
		while (*v != '\0') *to++ = *v++;
	}
	*to = '\0';

	return expanded;
}

#ifdef TEST
int
main(int argc, char** argv)
{
	printf("\"%s\"\n", expand_env(argv[1]));

	return 0;
}
#endif

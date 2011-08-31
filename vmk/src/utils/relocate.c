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

#include <string.h>

#include "relocate.h"


const char*
relocate(const char* from,
	 const char* path)
{
    static char fullName[1024];
    char* dirend;
    char separator;
    
#ifdef MSDOS
    // If the pathname starts with '\' or "X:\", then
    // this is an absolute pathname. No need to relocate.
    if (path[0] == '\\' ||
        (path[1] == ':' && path[2] == '\\')) return path;
    separator = '\\';
#else
    // If the pathname starts with a '/', then
    // this is an absolute pathname. No need to relocate.
    if (path[0] == '/') return path;
    separator = '/';
#endif

    // If the pathname starts with a '@', then
    // this is an as-is relative pathname. No need to relocate.
    if (path[0] == '@') return path+1;

    // The pathname is relative
    // prepend the directory leading to the 'from' file
    // to the path
    strcpy(fullName, from);
    dirend = strrchr(fullName, separator);
    if (dirend == NULL) {
        // The 'from' file is in the current directory
        // Therefore no need to relocate the relative path
        return path;
    }

    strcpy(dirend+1, path);
    
    // Remove any leading "./"
    for (dirend = fullName; dirend[0] == '.' && dirend[1] == separator;
	 dirend += 2);
    return dirend;
}

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
// Global definitions and variables for VMK
//

#ifndef GLOBALS_HPP
#define GLOBALS_HPP

#define LISTOF_TYPE     char
#define LISTOF          StringList
#define LISTOF_ITERATOR StringListIterator
#include "ListOf.hxx"

#define HASHTABLE_ENTRY 	char
#define HASHTABLE		StringHashTable
#define HASHTABLE_ITERATOR	StringHashTableIter
#include "HashTabl.hxx"

extern int exitCode;
extern unsigned debugLevel;
extern unsigned displayItems;
extern unsigned printDict;
extern unsigned allTops;
extern unsigned useLongNames;
extern unsigned multiLibrary;
extern unsigned warnOpenDefConf;
extern unsigned noMakefile;
extern unsigned noSimTarget;
extern unsigned useIEEE;
extern unsigned inferVlog;
extern const char* stampDirPattern;
extern const char* stampDirSuffix;
extern const char* genConfLibrary;
extern const char* genConfEntity;
extern const char* genConfArch;
extern const char* genConfUnitPattern;
extern const char* genConfFilePattern;
extern unsigned config_all;
extern unsigned config_to_config;

extern double version;
extern const char* license_file;
extern const char* preprocess;

extern StringHashTable queryNames;
extern const char* headerFile;
extern const char* includeFile[3];

#endif

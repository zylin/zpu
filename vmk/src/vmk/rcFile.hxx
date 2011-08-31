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
// Utility class to parse and read an RC file
//

#ifndef RCFILE_HPP
#define RCFILE_HPP

#include <stdio.h>

#include "VHDLprse.hxx"

class rcFile {
public:
    rcFile(const char* dirName,
           const char* fileName,
           Library*    workLib,
           unsigned    mustBeThere = 0);
    ~rcFile();
    
private:
    char     fullName[1024];
    char*    argv[64];
    int      argc;
    
    FILE*	 rc;
    unsigned lineNo;
    
    int	 GetLine();
};

#endif

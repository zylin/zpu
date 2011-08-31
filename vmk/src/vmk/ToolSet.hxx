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
// Definitions for each toolset
//

#ifndef TOOLSET_HPP
#define TOOLSET_HPP

class CommandSpec {

public:
    CommandSpec(const char* anafile,
                const char* vlogfile,
                const char* elabarch,
                const char* elabconf,
                const char* simarch,
                const char* simconf);

private:
    const char*	analyzeCommand;
    const char*	vlogCommand;
    const char*	elabArchCommand;
    const char*	elabConfCommand;
    const char*	simArchCommand;
    const char*	simConfCommand;

    friend class ToolSet;
};


class ToolDescriptor {
    
public:
    ToolDescriptor(const char*  full,
                   const char*  abbrev,
                   const char*  descr,
                   unsigned     bind,
                   CommandSpec* singleLibCmd,
                   CommandSpec* multiLibCmd);

private:
    const char*  description;
    const char*	 shortName;
    const char*	 longName;
    unsigned     binding;
    CommandSpec* singleLib;
    CommandSpec* multiLib;

    friend class ToolSet;
};


class ToolSet {

public:
    ToolSet();
    
    // Binding types
    enum {Hard, Soft};

    static void define(const char* longName, const char* shortName,
                       const char* descr, unsigned binding,
                       CommandSpec* singleLib, CommandSpec* multiLib);
    static unsigned select(const char* name);
    static unsigned selected(const char* name = NULL);

    static void setBindings(unsigned HardOrSoft);
    static void setAnalyzeCommand(const char* cmd);
    static void setVlogCommand(const char* cmd);
    static void setElaborateCommand(unsigned ArchOrConfig, const char* cmd);
    static void setSimulateCommand(unsigned ArchOrConfig, const char* cmd);

    static const char* getLongName();
    static const char* getShortName();
    static unsigned getBindings();
    static const char* getAnalyzeCommand();
    static const char* getVlogCommand();
    static const char* getElaborateCommand(unsigned ArchOrConfig);
    static const char* getSimulateCommand(unsigned ArchOrConfig);

    static void printToolSets(FILE* fp, const char* name);
};

#endif

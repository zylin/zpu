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

#include <stdio.h>
#include <string.h>

#include "globals.hxx"
#include "VHDLprse.hxx"
#include "ToolSet.hxx"


//
// Constructors for the toolset descriptors
//
CommandSpec::CommandSpec(const char* anafile,
                         const char* vlogfile,
                         const char* elabarch,
                         const char* elabconf,
                         const char* simarch,
                         const char* simconf)
    : analyzeCommand(anafile), vlogCommand(vlogfile),
      elabArchCommand(elabarch), elabConfCommand(elabconf),
      simArchCommand(simarch), simConfCommand(simconf)
{
}

ToolDescriptor::ToolDescriptor(const char*  full,
                               const char*  abbrev,
                               const char*  descr,
                               unsigned     bind,
                               CommandSpec* singleLibCmd,
                               CommandSpec* multiLibCmd)
    : description(descr), shortName(abbrev), longName(full),
      binding(bind),
      singleLib(singleLibCmd), multiLib(multiLibCmd)
{
}


//
// Table of known toolsets
//
#define LISTOF_TYPE     ToolDescriptor
#define LISTOF          ToolDescrList
#define LISTOF_ITERATOR ToolDescrListIterator
#include "ListOf.hxx"

static ToolDescrList knownToolSets;

//
// Constructor - used to initialize the
// list of known toolsets through a dummy
// static object instance
//
static ToolSet elab;

ToolSet::ToolSet()
{
    knownToolSets.append(new ToolDescriptor(
	"debussy",
	"dbsy",
	"Novas Debussy",
	ToolSet::Soft,
	new CommandSpec(
            "vhdlcom $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo No simulation for %e %a",
            "@echo No simulation for %c"),
	new CommandSpec(
            "vhdlcom -work %w $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo No simulation for %w.%e %a",
            "@echo No simulation for %w.c")));

    knownToolSets.append(new ToolDescriptor(
	"modelsim",
	"msim",
	"Model Technology's ModelSim",
	ToolSet::Soft,
	new CommandSpec(
            "vcom -explicit $(ANAFLAGS) %f",
            "vlog $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run -all;quit\" | vsim -c $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | vsim -c $(SIMFLAGS) %c"),
	new CommandSpec(
            "vcom -explicit -work %w $(ANAFLAGS) %f",
            "vlog -work %w $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run -all;quit\" | vsim -c -lib %w $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | vsim -c -lib %w $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"inca",
	"nc",
	"Cadence's NC",
	ToolSet::Hard,
	new CommandSpec(
            "ncvhdl $(ANAFLAGS) %f",
            "ncvlog $(VLOGFLAGS) %p%m.v",
            "ncelab $(ELABFLAGS) %e:%a",
            "ncelab $(ELABFLAGS) %c",
            "ncsim -batch -run $(SIMFLAGS) %e:%a",
            "ncsim -batch -run $(SIMFLAGS) %c"),
	new CommandSpec(
            "ncvhdl -work %w $(ANAFLAGS) %f",
            "ncvlog -work %w $(VLOGFLAGS) %p%m.v",
            "ncelab -work %w $(ELABFLAGS) %e:%a",
            "ncelab -work %w $(ELABFLAGS) %c",
            "ncsim -batch -run $(SIMFLAGS) %w.%e:%a",
            "ncsim -batch -run $(SIMFLAGS) %w.%c")));

    knownToolSets.append(new ToolDescriptor(
	"leapfrog",
	"lf",
	"Cadence's Leapfrog",
	ToolSet::Hard,
	new CommandSpec(
            "cv $(ANAFLAGS) %f",
            NULL,
            "ev $(ELABFLAGS) %e:%a",
            "ev $(ELABFLAGS) %c",
            "sv -batch -run $(SIMFLAGS) %e:%a",
            "sv -batch -run $(SIMFLAGS) %c"),
	new CommandSpec(
            "cv -work %w $(ANAFLAGS) %f",
            NULL,
            "ev -work %w $(ELABFLAGS) %e:%a",
            "ev -work %w $(ELABFLAGS) %c",
            "sv -work %w -batch -run $(SIMFLAGS) %e:%a",
            "sv -work %w -batch -run $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"scirocco",
	"sc",
	"Synopsys's Scirocco",
	ToolSet::Hard,
	new CommandSpec(
            "vhdlan -nc $(ANAFLAGS) %f",
            "vcs $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run;quit\" | scsim $(SIMFLAGS) %e %a",
            "echo \"run;quit\" | scsim $(SIMFLAGS) %c"),
	new CommandSpec(
            "vhdlan -nc -work %w $(ANAFLAGS) %f",
            "vcs -work %w $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run;quit\" | scsim $(SIMFLAGS) %w.%e %a",
            "echo \"run;quit\" | scsim $(SIMFLAGS) %w.%c")));

    knownToolSets.append(new ToolDescriptor(
	"synopsys",
	"vss",
	"Synopsys's VSS",
	ToolSet::Hard,
	new CommandSpec(
            "vhdlan -nc $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "echo \"run;quit\" | vhdlsim -t ns $(SIMFLAGS) %e %a",
            "echo \"run;quit\" | vhdlsim -t ns $(SIMFLAGS) %c"),
	new CommandSpec(
            "vhdlan -nc -work %w $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "echo \"run;quit\" | vhdlsim -t ns $(SIMFLAGS) %w.%e %a",
            "echo \"run;quit\" | vhdlsim -t ns $(SIMFLAGS) %w.%c")));

    knownToolSets.append(new ToolDescriptor(
	"voyager",
	"iks",
	"Ikos Voyager",
	ToolSet::Soft,
	new CommandSpec(
            "analyze $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vsh 'elaborate $(ELABFLAGS) -p %e -s %a; run $(SIMFLAGS)'",
            "vsh 'elaborate $(ELABFLAGS) -p %c; run $(SIMFLAGS)'"),
	new CommandSpec(
            "analyze -l %w -stO $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vsh 'elaborate -l %w $(ELABFLAGS) -p %e -s %a; run $(SIMFLAGS)'",
            "vsh 'elaborate -l %w $(ELABFLAGS) -p %c ; run $(SIMFLAGS)'")));

    knownToolSets.append(new ToolDescriptor(
	"dc_shell",
	"dc",
	"Synopsys's Design Compiler",
	ToolSet::Hard,
	new CommandSpec(
            "dc_shell -x \"analyze -format vhdl %f; exit\"",
            "dc_shell -x \"analyze -format verilog %f; exit\"",
            NULL,
            NULL,
            "dc_shell -f %e_%a.dcsh",
            "@echo Configurations not supported by Design Compiler"),
	new CommandSpec(
            "dc_shell -x \"analyze -format vhdl %f; exit\"",
            "dc_shell -x \"analyze -format verilog %f; exit\"",
            NULL,
            NULL,
            "dc_shell -f %e_%a.dcsh",
            "@echo Configurations not supported by Design Compiler")));

    knownToolSets.append(new ToolDescriptor(
	"vantage",
	"vas",
	"Vantage Analysis Systems",
	ToolSet::Soft,
	new CommandSpec(
            "analyze $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vbsim $(SIMFLAGS) %e %a",
            "vbsim $(SIMFLAGS) %c"),
	new CommandSpec(
            "analyze $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vbsim $(SIMFLAGS) %e %a",
            "vbsim $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"vhdl-xl",
	"xl",
	"Cadence's VHDL-XL",
	ToolSet::Soft,
	new CommandSpec(
            "vsh -c analyze $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vsh -c simulate $(SIMFLAGS) %e %a",
            "vsh -c simulate $(SIMFLAGS) %c"),
	new CommandSpec(
            "vsh -c analyze $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "vsh -c simulate $(SIMFLAGS) %e %a",
            "vsh -c simulate $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"dasix",
	"dx",
	"Dasix",
	ToolSet::Soft,
	new CommandSpec(
            "dvhdl -ace  $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c"),
	new CommandSpec(
            "dvhdl -ace  $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c")));

    knownToolSets.append(new ToolDescriptor(
	"racal-redac",
	"rr",
	"Racal-Redac",
	ToolSet::Soft,
	new CommandSpec(
            "analyze -d -o $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "simulate -c -p $(SIMFLAGS) %e %a",
            "simulate -c -p $(SIMFLAGS) %c"),
	new CommandSpec(
            "analyze -d -o $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "simulate -c -p $(SIMFLAGS) %e %a",
            "simulate -c -p $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"viewlogic",
	"vl",
	"ViewLogic",
	ToolSet::Soft,
	new CommandSpec(
            "analyze $(ANAFLAGS) -src %f -libfile vsslib.ini -dbg 2",
            NULL,
            NULL,
            NULL,
            "viewsim $(SIMFLAGS) \"%e(%a)\" -/dev/null",
            "viewsim $(SIMFLAGS) %c -/dev/null"),
	new CommandSpec(
            "analyze $(ANAFLAGS) -src %f -libfile vsslib.ini -dbg 2",
            NULL,
            NULL,
            NULL,
            "viewsim $(SIMFLAGS) \"%e(%a)\" -/dev/null",
            "viewsim $(SIMFLAGS) %c -/dev/null")));

    knownToolSets.append(new ToolDescriptor(
	"system1076",
	"m1076",
	"Mentor's System 1076",
	ToolSet::Soft,
	new CommandSpec(
            "hdl $(ANAFLAGS) %f work -lib .s1076",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c"),
	new CommandSpec(
            "hdl $(ANAFLAGS) %f work -lib .s1076",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c")));

    knownToolSets.append(new ToolDescriptor(
	"quickvhdl",
	"qck",
	"Mentor's quickVHDL",
	ToolSet::Soft,
	new CommandSpec(
            "qvcom $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "echo \"run -all;quit\" | qvsim -c $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | qvsim -c $(SIMFLAGS) %c"),
	new CommandSpec(
            "qvcom -work %w $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "echo \"run -all;quit\" | qvsim -c -lib %w $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | qvsim -c -lib %w $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"quickhdl",
	"qh",
	"Mentor's quickHDL",
	ToolSet::Soft,
	new CommandSpec(
            "qvhcom $(ANAFLAGS) %f",
            "qvlog $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run -all;quit\" | qhsim -c $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | qhsim -c $(SIMFLAGS) %c"),
	new CommandSpec(
            "qvhcom -work %w $(ANAFLAGS) %f",
            "qvlog -work %w $(VLOGFLAGS) %p%m.v",
            NULL,
            NULL,
            "echo \"run -all;quit\" | qhsim -c -lib %w $(SIMFLAGS) %e %a",
            "echo \"run -all;quit\" | qhsim -c -lib %w $(SIMFLAGS) %c")));

    knownToolSets.append(new ToolDescriptor(
	"vulcan",
	"vul",
	"Veda's Vulcan",
	ToolSet::Soft,
	new CommandSpec(
            "vc $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c"),
	new CommandSpec(
            "vc $(ANAFLAGS) %f",
            NULL,
            NULL,
            NULL,
            "@echo VMK does not know how to simulate %e %a",
            "@echo VMK does not know how to simulate %c")));

};


//
// Cache the tool to be used...
//
static ToolDescriptor* useTool = new ToolDescriptor(
    "User-Defined", "user", "User Defined Commands", ToolSet::Soft,
    new CommandSpec("$(ANALYZE) %f",
                    "$(VLOG) %m.v",
                    NULL,
                    NULL,
                    "$(SIMULATE) %e %a",
                    "$(SIMULATE) %c"),
    new CommandSpec("$(ANALYZE) -lib %w %f",
                    "$(VLOG) -lib %w %m.v",
                   NULL,
                   NULL,
                   "$(SIMULATE) %w.%e %a",
                   "$(SIMULATE) %w.%c"));


void
ToolSet::define(const char*  longName,
                const char*  shortName,
                const char*  descr,
                unsigned     binding,
                CommandSpec* singleLib,
                CommandSpec* multiLib)
{
    knownToolSets.append(
        new ToolDescriptor(longName, shortName, descr, binding,
                           singleLib, multiLib));
}


unsigned
ToolSet::select(const char* name)
{
    // Compare specified name if short and long names for
    // the known toolsets and return zero on success.
    // If cannot find specified toolset return non-zero.

    ToolDescrListIterator scanTools(&knownToolSets);
    for (scanTools.reset(); scanTools() != NULL; ++scanTools) {
	if (strcmp(name, scanTools()->shortName) == 0 ||
	    strcmp(name, scanTools()->longName) == 0) {
	    useTool = scanTools();
	    return 0;
	}
    }

    return 1;
}

unsigned
ToolSet::selected(const char* name)
{
    // If name is NULL, check if a valid tool has been selected
    if (name == NULL)
	return useTool->singleLib->analyzeCommand != NULL;

    return 
	(strcmp(name, useTool->shortName) == 0 ||
	 strcmp(name, useTool->longName) == 0);
}

void
ToolSet::setBindings(unsigned HardOrSoft)
{
    useTool->binding = HardOrSoft;
}

void
ToolSet::setAnalyzeCommand(const char* cmd)
{
    useTool->singleLib->analyzeCommand = cmd;
    useTool->multiLib->analyzeCommand = cmd;
}

void
ToolSet::setVlogCommand(const char* cmd)
{
    useTool->singleLib->vlogCommand = cmd;
    useTool->multiLib->vlogCommand = cmd;
}

void
ToolSet::setElaborateCommand(unsigned ArchOrConfig, const char* cmd)
{
    if (ArchOrConfig == LibraryUnit::Architecture) {
	useTool->singleLib->elabArchCommand = cmd;
	useTool->multiLib->elabArchCommand = cmd;
    } else {
	useTool->singleLib->elabConfCommand = cmd;
	useTool->multiLib->elabConfCommand = cmd;
    }
}

void
ToolSet::setSimulateCommand(unsigned ArchOrConfig, const char* cmd)
{
    if (ArchOrConfig == LibraryUnit::Architecture) {
	useTool->singleLib->simArchCommand = cmd;
	useTool->multiLib->simArchCommand = cmd;
    } else {
	useTool->singleLib->simConfCommand = cmd;
	useTool->multiLib->simConfCommand = cmd;
    }
}


const char*
ToolSet::getLongName()
{
    return useTool->longName;
}


const char*
ToolSet::getShortName()
{
    return useTool->shortName;
}

unsigned
ToolSet::getBindings()
{
    //|@default bindings@
    //| By default, the default binding requirements from the
    //| selected toolset is used.
    //| If no toolset is selected, \fIsoft\fP bindings
    //| are used.
    return useTool->binding;
}

const char*
ToolSet::getAnalyzeCommand()
{
    if (multiLibrary) {
        return useTool->multiLib->analyzeCommand;
    }
    
    return useTool->singleLib->analyzeCommand;

}

const char*
ToolSet::getVlogCommand()
{
    if (multiLibrary) {
        return useTool->multiLib->vlogCommand;
    }
    
    return useTool->singleLib->vlogCommand;

}

const char*
ToolSet::getElaborateCommand(unsigned ArchOrConfig)
{
    if (ArchOrConfig == LibraryUnit::Architecture) {
        
        if (multiLibrary) {
            return useTool->multiLib->elabArchCommand;
        }

        return useTool->singleLib->elabArchCommand;
    }
    
    if (multiLibrary) {
        return useTool->multiLib->elabConfCommand;
    }

    return useTool->singleLib->elabConfCommand;
}

const char*
ToolSet::getSimulateCommand(unsigned ArchOrConfig)
{
    if (ArchOrConfig == LibraryUnit::Architecture) {
        
        if (multiLibrary) {
            return useTool->multiLib->simArchCommand;
        }

        return useTool->singleLib->simArchCommand;
    }
    
    if (multiLibrary) {
        return useTool->multiLib->simConfCommand;
    }

    return useTool->singleLib->simConfCommand;
}

void
ToolSet::printToolSets(FILE* fp,
                       const char* name)
{
    ToolDescrListIterator scanTools(&knownToolSets);
    
    fprintf(fp, "Supported toolsets:\n");

    fprintf(fp, "\t%-8s%-16s%s\n", "Abbrev ", "Full Name", "       Description");
    fprintf(fp, "\t%-8s%-16s%s\n", "-------", "------------", "------------------------------");
    for (scanTools.reset(); scanTools() != NULL; ++scanTools) {
        fprintf(fp, "\t%-8s%-16s%s\n",
		scanTools()->shortName,
		scanTools()->longName,
		scanTools()->description);
    }

    // Print a description of the current
    fprintf(fp, "\n\nDetailed description for current toolset:\n\n");

    fprintf(fp, "Full Name   : %s\nAbbreviation: %s\nDescription : %s\nBinding     : %s\n\n",
	    useTool->longName, useTool->shortName, useTool->description,
	    (useTool->binding == ToolSet::Soft) ? "soft" : "hard");
    
    fprintf(fp, "Single-library commands:\n");
    fprintf(fp, "\tAnalysis : %s\n", useTool->singleLib->analyzeCommand);
    if (useTool->singleLib->vlogCommand != NULL) {
        fprintf(fp, "\tVerilog  : %s\n", useTool->singleLib->vlogCommand);
    }
    if (useTool->singleLib->elabArchCommand != NULL) {
        fprintf(fp, "\tArch Elab: %s\n", useTool->singleLib->elabArchCommand);
	fprintf(fp, "\tConf Elab: %s\n", useTool->singleLib->elabConfCommand);
    }
    fprintf(fp, "\tArch Sim : %s\n", useTool->singleLib->simArchCommand);
    fprintf(fp, "\tConf Sim : %s\n", useTool->singleLib->simConfCommand);
    
    fprintf(fp, "\nMulti-library commands:\n");
    fprintf(fp, "\tAnalysis : %s\n", useTool->multiLib->analyzeCommand);
    if (useTool->multiLib->vlogCommand != NULL) {
        fprintf(fp, "\tVerilog  : %s\n", useTool->multiLib->vlogCommand);
    }
    if (useTool->multiLib->elabArchCommand != NULL) {
        fprintf(fp, "\tArch Elab: %s\n", useTool->multiLib->elabArchCommand);
	fprintf(fp, "\tConf Elab: %s\n", useTool->multiLib->elabConfCommand);
    }
    fprintf(fp, "\tArch Sim : %s\n", useTool->multiLib->simArchCommand);
    fprintf(fp, "\tConf Sim : %s\n", useTool->multiLib->simConfCommand);
}

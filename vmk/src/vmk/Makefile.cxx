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
// Create a makefile from a partial parse tree
//

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#ifdef HPUX
# include <sys/sigevent.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>


#include "globals.hxx"
#include "Makefile.hxx"
#include "ToolSet.hxx"


inline const char* maybe_null(const char* str)
{
    return (str == NULL) ? "(null)": str;
}


//
// Private objects and functions
//
static void genConfiguration(const char*       fname,
			     const char*       libName,
			     const char*       entName,
			     const char*       archName,
			     LibraryHashTable* libs);
static void genBlockConfig(FILE*        fp,
			   Block*       block,
                           LibraryUnit* unit,
			   unsigned     nest = 0);
static void include(FILE* mkf,
		    const char* fname,
		    const char* filetype);
static const char* getWorkLibName(void);
static FILE* dictFile = NULL;
static const char* toolString = NULL;
static const char* makeStampName(const char* libName,
				 const char* unitName,
				 const char* parentUnitName,
				 const char* postfix = NULL);
static const char* stampDirName(const char* libName);

static unsigned isWork(Library* lib,
		       const char* libName);
static LibraryUnit* lookupUnit(Library*    lib,
			       const int   unitType,
			       const char* name,
			       const char* sName = NULL,
			       const int   missingOK = 0);

static void resolveGenealogy(LibraryHashTable* libs);
static void resolveGenealogy(LibraryUnit*      unit,
                             LibraryHashTable* libs);

static void resolveReferences(LibraryHashTable* libs);
static void resolveReferences(LibraryUnit*      unit,
			      LibraryHashTable* libs);
static void resolveReferences(Block*            block,
			      LibraryHashTable* libs);
static LibraryUnit* resolveReference(const char*       libName,
				     const char*       mainName,
				     const char*       secName,
				     LibraryUnit*      unit,
				     LibraryHashTable* libs,
				     unsigned          missingOK);

static void checkConfiguration(LibraryHashTable* files);

static void print_target(FILE*        mkf,
			 const char*  libName,
			 LibraryUnit* unit,
			 int          width = 0,
                         int          lower = 0);
static void print_stamp(FILE*        mkf,
			LibraryUnit* unit,
			const char*  before  = "",
			const char*  after   = "",
			const char*  special = NULL);
static void print_dependencies(FILE*       mkf,
			       SourceFile* file);
static void print_dependencies(FILE*        mkf,
                               LibraryUnit* unit,
			       Dependency*  dep);
static void print_runtime_dependencies(FILE*	    mkf,
				       LibraryUnit* unit,
				       const char*  archName = NULL);
static void print_runtime_package_dependencies(FILE*	mkf,
					       LibraryUnit* unit);
static void print_runtime_external_dependency(FILE*       mkf,
                                              Dependency* dep);
static void print_file_command(FILE*       mkf,
                               Library*    lib,
			       const char* filename,
			       const char* override = NULL,
			       const char* args     = NULL);
static void print_vlog_command(FILE*       mkf,
                               Library*    lib,
			       const char* module,
			       const char* override = NULL,
			       const char* args     = NULL);
static void print_unit_command(FILE*        mkf,
			       const char*  command,
                               Library*     lib,
			       LibraryUnit* unit);
static const char* lowerOrUpperCase(const char*    string,
                                    unsigned lower);

static unsigned lineCount = 0;

#define HASHTABLE_ENTRY 	Dependency
#define HASHTABLE		DependHashTable
#define HASHTABLE_ITERATOR	DependHashTableIter
#include "HashTabl.hxx"
static DependHashTable vlogModules(13);


//
// MakeFile class
//

MakeFile::MakeFile(const char* fileName,
		   LibraryHashTable* libs)
{
    resolveGenealogy(libs);
    resolveReferences(libs);
    checkConfiguration(libs);

    // Maybe we have to generate a configuration unit too?
    if (genConfEntity != NULL) {
        char fname[1024];
        char* b = fname;
        for (const char* p = genConfFilePattern; *p != '\0'; p++) {
            if (*p == '%') {
                switch (*++p) {
                case '%':
                    *b++ = '%';
                    break;
		case 'e':
                    for (const char* q = genConfEntity; *q != '\0'; q++) {
                        *b++ = isupper(*q) ? tolower(*q) : *q;
                    }
		    break;
		case 'E':
                    for (const char* q = genConfEntity; *q != '\0'; q++) {
                        *b++ = islower(*q) ? toupper(*q) : *q;
                    }
		    break;
		case 'a':
                    for (const char* q = genConfArch; *q != '\0'; q++) {
                        *b++ = isupper(*q) ? tolower(*q) : *q;
                    }
		    break;
		case 'A':
                    for (const char* q = genConfArch; *q != '\0'; q++) {
                        *b++ = islower(*q) ? toupper(*q) : *q;
                    }
		    break;
                default:
                    fprintf(stderr, "Unknown marker '%%%c' in config file pattern\n", *p);
                    break;
                }
                continue;
            }
            *b++ = *p;
        }
        *b = '\0';
        genConfiguration(fname, genConfLibrary, genConfEntity, genConfArch, libs);
    }

    //
    // Quit here of no makefile is generated
    //
    if (noMakefile) return;

    //
    // Write the Makefile
    //
    FILE* mkf;
    if (strcmp(fileName, "-") == 0) mkf = stdout;
    else mkf = fopen(fileName, "w");
    if (mkf == NULL) {
	fprintf(stderr, "Cannot open \"%s\" for writing:", fileName);
	perror("");
        exitCode = -1;
	return;
    }

    // Open the dictionary file
    if (printDict) {
	//|@stamp dictionary@
	//| Print a dictionary of the timestamp filenames
	//| with their corresponding library unit names
	//| in the file \fI@(dictionary file name)@\fP.
	//| @(dictionary entries)@
	//|@dictionary file name@
	//| StmpDict.vmk
	const char* fileName = "StmpDict.vmk";
	dictFile = fopen(fileName, "w");
	if (dictFile == NULL) {
	    fprintf(stderr, "Cannot open \"%s\" for writing:", fileName);
	    perror("");
            exitCode = -1;
	}
    }

    // Generate stamps for all loaded units
    LibraryHashTableIter scanLibs(libs);
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	LibraryUnitIter scanUnits(*(scanLibs.entry()));
	for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	    // Since the parent name of package bodies is the same
	    // as their unit name, any package body with a name
	    // exactly 11 characters long would produce the
	    // stamp filename "AAAAAAAAA.AAA". Thus, use the
	    // constant "+body+" as the parent unit name for
	    // package bodies.

	    // Must not use the parent unit name for making up
	    // the stamp name of configuration because, in
	    // cross-library dependencies, I can only know the
	    // name of the configuration, not the name of the
	    // entity it is configuring. To ensure uniqueness
	    // with an entity or package which could have the
	    // same name, use "+conf+" as the parent name.

	    switch (scanUnits()->getType()) {
	    case LibraryUnit::PackageBody:
		scanUnits()->setId(makeStampName(scanLibs.entry()->getName(),
						 scanUnits()->getName(),
						 "+body+"));
		break;
	    case LibraryUnit::Configuration:
		scanUnits()->setId(makeStampName(scanLibs.entry()->getName(),
						 scanUnits()->getName(),
						 "+conf+"));
		break;
	    default:
		scanUnits()->setId(makeStampName(scanLibs.entry()->getName(),
						 scanUnits()->getName(),
						 scanUnits()->getParentName()));
		break;
	    }
	}
    }

    // Optional user-defined header
    include(mkf, headerFile, "header");

    // Banner
    fprintf(mkf, "# Makefile generated by VMK %1.3f\n\n", version);

    lineCount++;
    fprintf(mkf, "all: all_units\n\n");

    // Print a summary of what is available

    int simTargets = 0;
    int is_help_target = 0;
    if (noSimTarget) {
        // Produce a help target anyway
        fprintf(mkf, "help available avail:\n\t@echo No available simulatable targets.\n");
        fprintf(mkf, "\t@echo Use 'make all'.\n");
	is_help_target = 1;
    }

    if (!noSimTarget) {
	LibraryHashTableIter scanLibs(libs);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
	    if (!scanLibs.entry()->inMakefile()) continue;

            // Skip aliases
            if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	    LibraryUnitIter scanUnits(*(scanLibs.entry()));
	    for (scanUnits.reset(); scanUnits(); ++scanUnits) {
		if (scanUnits()->getType() != LibraryUnit::Entity) {
		    continue;
		}
		Entity* ent = (Entity*) scanUnits();
		if (!ent->canBeTop()) continue;

		if (!simTargets) {
		    fprintf(mkf, "help available avail:\n\t@echo Available simulatable targets:\n");
		    is_help_target = 1;
		    fprintf(stderr, "\nAvailable simulatable targets:\n");
		    simTargets = 1;
		}

		fprintf(mkf, "\t@echo\n\t@echo For entity %s.%s:\n",
			scanLibs.entry()->getName(),
			scanUnits()->getName());
		fprintf(stderr, "\nFor entity %s.%s:\n",
			scanLibs.entry()->getName(),
			scanUnits()->getName());
		EntityChildrenIter scanChild(ent);
		for (scanChild.reset(); scanChild(); ++scanChild) {
		    fprintf(mkf, "\t@echo \"");
		    print_target(mkf, scanLibs.entry()->getName(),
				 scanChild(), 20);
		    fprintf(mkf, " %s %s\"\n",
			    LibraryUnit::unitTypeImage(scanChild()->getType()),
			    scanChild()->getName());

		    print_target(stderr, scanLibs.entry()->getName(),
				 scanChild(), 20);
		    fprintf(stderr, " %s %s\n",
			    LibraryUnit::unitTypeImage(scanChild()->getType()),
			    scanChild()->getName());
		    scanChild()->isReferenced();
		}
	    }
	}
    }

    
    //|@default item display@
    //| If there are no simulatable targets to display,
    //| the list of top-level units is displayed.
    if (!noSimTarget) {
        if (simTargets == 0) displayItems = 1;

        if (displayItems) {
	    if (!is_help_target) {
                fprintf(mkf, "help avail available:\n");
	    } else {
                fprintf(mkf, "\t@echo\n");
	    }
            fprintf(mkf, "\t@echo Available top-level units:\n\t@echo\n");
            fprintf(stderr, "\nAvailable top-level units:\n");
        }
        {
            LibraryHashTableIter scanLibs(libs);
            for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
                if (!scanLibs.entry()->inMakefile()) continue;

                // Skip aliases
                if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
                LibraryUnitIter scanUnits(*scanLibs.entry());
                for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                    if (!scanUnits()->isLoose()) continue;

                    fprintf(mkf, "\t@echo \"");
                    print_target(mkf, scanLibs.entry()->getName(), scanUnits(), 20);
                    fprintf(mkf, "   ");
                    scanUnits()->printDesc(mkf);
                    fprintf(mkf, "\"\n");

                    if (displayItems) {
                        print_target(stderr, scanLibs.entry()->getName(), scanUnits(), 20);
                        fprintf(stderr, "   ");
                        scanUnits()->printDesc(stderr);
                        fprintf(stderr, "\n");
                    }
                }
            }
            fprintf(mkf, "\n\n");
        }
    }

    // If we are using the user-defined command,
    // provide default definitions for ANALYZE and SIMULATE
    if (strcmp(ToolSet::getShortName(), "user") == 0) {
        fprintf(mkf, "ANALYZE  = @echo Please define ANALYZE for\n");
        fprintf(mkf, "SIMULATE = @echo Please define SIMULATE for\n\n");
    }

    // Include include file #1 if required
    fprintf(mkf, "# Start of optional include file #1\n");
    include(mkf, includeFile[0], "include");
    fprintf(mkf, "# End of optional include file #1\n\n");

    fprintf(mkf, "VMK_TOUCH = touch\n");
    fprintf(mkf, "VMK_MKDIR = mkdir -p\n\n");

    // Print the macro definitions for the known libraries stamp dirs
    fprintf(mkf, "\n\n# Known libraries in this Makefile:\n");
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {

	fprintf(mkf, "VMK_%s_LIB = ", scanLibs.key());

        const char* stampDir = stampDirName(scanLibs.entry()->getName());

	char stampPath[1024];
	// If the stampdir pattern is relative,
	// prefix with the directory to the library
	if (stampDir[0] != '/') {
	    sprintf(stampPath, "%s/%s", scanLibs.entry()->getPath(), stampDir);
	} else {
            strcpy(stampPath, stampDir);
        }
	fprintf(mkf, "%s\n", stampPath);
    }
    fprintf(mkf, "\n\n");


    // Include include file #2 if required
    fprintf(mkf, "# Start of optional include file #2\n");
    include(mkf, includeFile[1], "include");
    fprintf(mkf, "# End of optional include file #2\n\n");

    
    fprintf(mkf, "clean: ");
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        if (!scanLibs.entry()->inMakefile() ||
            strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	fprintf(mkf, "\n\trm -rf $(VMK_%s_LIB)", scanLibs.key());
    }
    fprintf(mkf, "\n\n");

    if (!noSimTarget) {
        // Print the simulation rules for the tops
        fprintf(mkf, "# Simulation targets for potential tops\n");
        {
            LibraryHashTableIter scanLibs(libs);
            for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
                if (!scanLibs.entry()->inMakefile()) continue;
                
                // Skip aliases
                if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
                
                LibraryUnitIter scanUnits(*scanLibs.entry());
                for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                    if (scanUnits()->getType() != LibraryUnit::Entity) {
                        continue;
                    }
                    Entity* ent = (Entity*) scanUnits();
                    if (!ent->canBeTop()) continue;

                    EntityChildrenIter scanChild(ent);
                    for (scanChild.reset(); scanChild(); ++scanChild) {
                        print_target(mkf, scanLibs.key(), scanChild());
                        fprintf(mkf, " ");
                        print_target(mkf, scanLibs.key(), scanChild(), 0, 1);
                        fprintf(mkf, ": ");
                        print_target(mkf, scanLibs.key(), scanChild());
                        fprintf(mkf, "-NOSIM\n");
                        print_unit_command(mkf,
                                           ToolSet::getSimulateCommand(scanChild()->getType()),
                                           scanLibs.entry(), scanChild());
                    }
                }
            }
            fprintf(mkf, "\n\n");
        }
    }

    // Print the rules for the top-level units
    if (!noSimTarget) {
	LibraryHashTableIter scanLibs(libs);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
	    if (!scanLibs.entry()->inMakefile()) continue;

            // Skip aliases
            if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	    LibraryUnitIter scanUnits(*scanLibs.entry());
	    for (scanUnits.reset(); scanUnits(); ++scanUnits) {
		if (scanUnits()->isLoose()) {
		    lineCount++;
		    print_target(mkf, scanLibs.key(), scanUnits());
		    fprintf(mkf, " ");
		    print_target(mkf, scanLibs.key(), scanUnits(), 0, 1);
		    fprintf(mkf, ": ");
		    print_stamp(mkf, scanUnits(), "", "\n");
		    continue;
		}

		if (scanUnits()->getType() != LibraryUnit::Entity) {
		    continue;
		}
		Entity* ent = (Entity*) scanUnits();
		if (!ent->canBeTop()) continue;

		EntityChildrenIter scanChild(ent);
		for (scanChild.reset(); scanChild(); ++scanChild) {
		    lineCount++;
		    print_target(mkf, scanLibs.key(), scanChild());
		    fprintf(mkf, "-NOSIM ");
		    print_target(mkf, scanLibs.key(), scanChild(), 0, 1);
		    fprintf(mkf, "-nosim:");
		    // Optional elaboration phase
		    if (ToolSet::getElaborateCommand(scanChild()->getType()) != NULL) {
			print_stamp(mkf, scanChild(), " ", "\n", "+elab+");
			lineCount++;
			print_stamp(mkf, scanChild(), "", ":", "+elab+");
			print_runtime_dependencies(mkf, scanChild());
			fprintf(mkf, "\n");
			print_unit_command(mkf,
					   ToolSet::getElaborateCommand(scanChild()->getType()),
                                           scanLibs.entry(), scanChild());
			print_stamp(mkf, scanChild(),
				    "\t@$(VMK_TOUCH) ", "\n\n", "+elab+");
		    } else {
			print_runtime_dependencies(mkf, scanChild());
			fprintf(mkf, "\n\n");
		    }
		}
	    }
	}
	lineCount++;
	fprintf(mkf, "\n\n");
    }

    fprintf(mkf, "# List of all targets in Makefile\n");
    
    lineCount++;
    fprintf(mkf, "all_units:  ");
    {
	LibraryHashTableIter scanLibs(libs);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
	    if (!scanLibs.entry()->inMakefile()) continue;

            // Skip aliases
            if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	    SourceFileIter scanFiles(*scanLibs.entry());
	    for (scanFiles.reset(); scanFiles(); ++scanFiles) {
		SourceFileUnitIter scanUnits(*scanFiles());
		for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                    fprintf(mkf, "\\\n\t%s", scanUnits()->getId());
		}
	    }

	    // Elaboration targets of top-level units should also be part of "all"
	    LibraryUnitIter scanUnits(*scanLibs.entry());
	    for (scanUnits.reset(); scanUnits(); ++scanUnits) {
		if (scanUnits()->getType() != LibraryUnit::Entity) {
		    continue;
		}
		Entity* ent = (Entity*) scanUnits();
		if (!ent->canBeTop()) continue;

		EntityChildrenIter scanChild(ent);
		for (scanChild.reset(); scanChild(); ++scanChild) {
		    // Optional elaboration phase
		    if (ToolSet::getElaborateCommand(scanChild()->getType()) != NULL) {
		        print_stamp(mkf, scanChild(), "\\\n\t", "", "+elab+");
		    }
		}
	    }
	}
        fprintf(mkf, "\n\n");
    }

    fprintf(mkf, "# Dependency rules for the source files\n");

    {
	LibraryHashTableIter scanLibs(libs);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
	    if (!scanLibs.entry()->inMakefile()) continue;
            
            // Skip aliases
            if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	    SourceFileIter scanFiles(*scanLibs.entry());
            for (scanFiles.reset(); scanFiles(); ++scanFiles) {
                fprintf(mkf, "\n");
                SourceFileUnitIter scanUnits(*scanFiles());
                int first = 1;
                lineCount++;
                // Write one rule for all the units in the same file
                for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                    print_stamp(mkf, scanUnits(), (first) ? "" : " ");
                    first = 0;
                    // If this is a bodyless package, fake the target for the body
                    if (scanUnits()->getType() == LibraryUnit::Package) {
                        Package* pkg = (Package*) scanUnits();
                        if (pkg->getBody() == NULL) {
                            fprintf(mkf, " %s", makeStampName(scanLibs.key(),
                                                              pkg->getName(),
                                                              "+body+"));
                        }
                    }
                }
                // Depends on the source file...
                fprintf(mkf, ": %s", scanFiles()->getName());
                // Depends on other units
                print_dependencies(mkf, scanFiles());
                fprintf(mkf, "\n");
                
                // Add the update command
                {
                    char key[32];
                    sprintf(key, "%s analyze", ToolSet::getLongName());
                    const char* override = scanFiles()->getDirective(key);
                    const char* args = scanFiles()->getDirective("compile args");
                    print_file_command(mkf,
                                       scanLibs.entry(),
                                       scanFiles()->getName(),
                                       override,
				       args);
                }
                
                // Force the creation of the stamp directories to make
                // sure they exist
                StringHashTable makeLibrary(13);
                for (scanUnits.reset(); scanUnits(); ++scanUnits) {

                    const char* libName =
                        scanUnits()->getLibrary()->getName();
                    
                    // Do we already depend in this library?
                    if (makeLibrary.lookup(libName) != NULL) continue;

                    makeLibrary.insert(libName, "made");
                    fprintf(mkf, "\t@$(VMK_MKDIR) $(VMK_%s_LIB)\n", libName);
                }
                
                // Update the stamp files
                for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                    lineCount++;
                    print_stamp(mkf, scanUnits(), "\t@$(VMK_TOUCH) ", "\n");
                    // If this is a bodyless package, fake the target for the body
                    if (scanUnits()->getType() == LibraryUnit::Package) {
                        Package* pkg = (Package*) scanUnits();
                        if (pkg->getBody() == NULL) {
                            fprintf(mkf, "\t@$(VMK_TOUCH) %s\n",
                                    makeStampName(scanLibs.key(),
                                                  pkg->getName(), "+body+"));
                        }
                    }
                }
	    }
	}
    }
    fprintf(mkf, "\n");

    // Include inferred Verilog targets
    if (inferVlog) {
        fprintf(mkf, "\n#\n# Inferred Verilog modules\n#\n");
            
        if (ToolSet::getVlogCommand() == NULL) {
            fprintf(stderr, "ERROR: No verilog command defined.\n");
            exitCode = -1;
        } else {
            DependHashTableIter scanModules(&vlogModules);
            for (scanModules.reset(); scanModules.key(); ++scanModules) {
                fprintf(mkf, "\n%s:\n", scanModules.key());
                Dependency *dep = scanModules.entry();
                print_vlog_command(mkf,
                                   libraries.lookup(dep->libName()),
                                   dep->mainName(),
                                   NULL,
                                   NULL);
                fprintf(mkf, "\t@$(VMK_TOUCH) %s\n", scanModules.key());
            }
        }
    }

    // Include include file #3 if required
    fprintf(mkf, "\n\n# Start of optional include file #3\n");
    include(mkf, includeFile[2], "include");
    fprintf(mkf, "# End of optional include file #3\n\n");

    if (mkf != stdout) fclose(mkf);

    if (dictFile != NULL) fclose(dictFile);
}

MakeFile::~MakeFile()
{}


//
// Implementation of the private functions
//

static void
include(FILE* mkf,
	const char* fname,
	const char* filetype)
{
    if (fname == NULL) return;

    FILE* fp = fopen(fname, "r");
    if (fp == NULL) {
	fprintf(stderr, "ERROR: Cannot open %s file \"%s\" for reading: ",
		filetype, fname);
	perror("");
        exitCode = -1;
	return;
    }

    char c;
    while ((c = fgetc(fp)) != EOF) fputc(c, mkf);

    fclose(fp);
}


//
// Make sure identifier characters used in Makefiles are valid.
//
// If the character is not alphanumeric (in extended identifiers)
// replace it with '+' followed by its ASCII value in hex,
// except for '\'s which are replaced with '+'s only.
// No confusion is possible with a '+' since a '+' will be
// replaced with '+' followed by its ASCII value.
static char*
append_char(char* t,
	    char  c)
{
    if (c == '\\') {
        *t++ = '+';
    } else if (!isalnum(c) && c != '_') {
        *t++ = '+';
	sprintf(t, "%02X", c);
	t += 2;
    } else {
      *t++ = c;
    }
    return t;
}


//
// Mangle a primary and a secondary unit name
// into a timestamp filename (XXXXXXXX.XXX)
// There is a many-to-one mapping, but, with luck, we shouldn't
// get collisions.
//
static const char*
makeStampName(const char* libName,
	      const char* unitName,
	      const char* parentUnitName,
	      const char* postfix)
{
    // Use long filenames for timestamps
    // Format: $(VMK_libname_LIB)/[parentUnitName-]unitName[-postfix]
    static char buffer[1024];
    sprintf(buffer, "$(VMK_%s_LIB)/", libName);
    char* t = buffer + strlen(buffer);
    // Remember where the filename starts for the potential
    // hashing into an 8.3 filename.
    char* fname = t;
    const char* p = parentUnitName;
    for (; p != NULL && *p != '\0'; p++) {
        t = append_char(t, *p);
    }
    if (parentUnitName != NULL) {
        *t++ = '-';
    }
    p = unitName;
    for (; *p != '\0'; p++) {
        t = append_char(t, *p);
    }
    if (postfix != NULL) *t++ = '-';
    for (p = postfix; p != NULL && *p != '\0'; p++) {
	*t++ = *p;
    }
    *t = '\0';
    
    if (useLongNames) {
	return buffer;
    }

    // Hash long name into an 8.3 filename
    static char fileName[13];
    {
        static char* alphabet =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
        static unsigned alphabetLength = 37;
        static char buf[12];
        int i;
        
        for (i = 0; i < 12; buf[i++] = 0);
        i = 0;
        const char* p;
        for (p = fname; *p != '\0'; p++) {
            buf[i] ^= *p;
            i = (i + 1) % 11;
        }
        for (i = 0; i < 11; i++) {
            buf[i] = alphabet[buf[i] % alphabetLength];
        }
        
        strncpy(fileName, buf, 8);
        strcpy(fileName + 9, buf + 8);
        fileName[8] = '.';
        strcpy(fname, fileName);
    }

    // Remember a description for files we are queried about
    if (queryNames.lookup(fileName) != NULL) {
	char *desc = new char [strlen(libName) + strlen(unitName) +
			      ((parentUnitName == NULL) ? 0 : strlen(parentUnitName)) + 5];
	if (parentUnitName != NULL && parentUnitName[0] != '\0') {
	    sprintf(desc, "%s of %s in %s", unitName, parentUnitName, libName);
	} else sprintf(desc, "%s in %s", unitName, libName);
	queryNames.replace(fileName, desc);
    }

    // Optionaly print the dictionary
    if (dictFile != NULL) {
	//|@dictionary entries@
	//| Some entries may be duplicated.
	//| On Unix systems, use the command
	//| "sort @(dictionary file name)@ | uniq"
	//| to remove duplicated entries.
	fprintf(dictFile, "%s\t%s", fileName, unitName);
	if (parentUnitName != NULL && parentUnitName[0] != '\0') {
	    fprintf(dictFile, " of %s", parentUnitName);
	}
	if (postfix != NULL) fprintf(dictFile, "(%s)", postfix);
	fprintf(dictFile, " in %s\n", libName);
    }

    return fileName;
}


//
// Return the name of the stamp directory for the
// specified library
//
static const char*
stampDirName(const char* libName)
{
    static char buffer[1024];
    const char* tool = ToolSet::getShortName();
    if (tool == NULL) tool = "user";

    unsigned wFound = 0;
    char* b = buffer;
    for (const char* p = stampDirPattern; *p != '\0'; p++) {
	if (*p == '%') {
	    switch (*++p) {
	    case '%':
		*b++ = '%';
		break;
	    case 't':
		strcpy(b, tool);
		b += strlen(b);
		break;
	    case 'w':
	    case 'W':
                wFound = 1;
                if (strcmp(libName, "WORK") == 0) {
                    libName = getWorkLibName();
                }
                strcpy(b, lowerOrUpperCase(libName, *p == 'w'));
		b += strlen(b);
		break;
	    default:
		fprintf(stderr, "Unknown marker '%%%c' in stamp directory\n", *p);
		break;
	    }
	    continue;
	}
	*b++ = *p;
    }
    
    // Append the name of the library to the stamp directory
    // if this is in the multi-library mode and there
    // is no '%w' field in the pattern
    if (multiLibrary && !wFound) {
        if (strcmp(libName, "WORK") == 0) {
            libName = getWorkLibName();
        }
        sprintf(b, ".%s", libName);
        b += strlen(b);
    }
    strcpy(b, stampDirSuffix);

    return buffer;
}


//
// Check if a library name corresponds to the current WORK library
//
static unsigned
isWork(Library* lib,
       const char* libName)
{
    // The obvious case!
    if (strcmp(libName, "WORK") == 0) return 1;

    // Other libraries which were declared synonyms of WORK
    return lib->isLib(libName);
}


//
// Lookup the identifier in the specified library WORK
//
static LibraryUnit*
lookupUnit(Library*    lib,
	   const int   unitType,
	   const char* name,
	   const char* sName,
	   const int   missingOK)
{
    LibraryUnit* maybe  = NULL;

    if (debugLevel > 2) {
        printf("      Looking for %s %s(%s) in library %s\n",
	       LibraryUnit::unitTypeImage(unitType),
               name, maybe_null(sName), lib->getName());
    }

    LibraryUnitIter scanUnits(*lib);
    for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	
	if (unitType != LibraryUnit::Unknown &&
	    scanUnits()->getType() != unitType) {
	    continue;
	}

	switch (scanUnits()->getType()) {
	case LibraryUnit::PackageBody:
	    // When looking for an unknown unit,
	    // i.e. trying to resolve 'use name.name'
	    // references, it can NEVER be a reference
	    // to a package body
	    if (unitType == LibraryUnit::Unknown) {
		break;
	    }
	case LibraryUnit::Package:
	case LibraryUnit::Entity:
	case LibraryUnit::Configuration:
	    if (strcmp(name, scanUnits()->getName()) == 0) {
		maybe = scanUnits();
	    }
	    break;
	case LibraryUnit::Architecture:
	    if (sName != NULL &&
                strcmp(name, scanUnits()->getParentName()) == 0 &&
		strcmp(sName, scanUnits()->getName()) == 0) {
		return scanUnits();
	    }
	    break;
	}
    }
    if (maybe != NULL) return maybe;

    // Identifer was not found
    if (debugLevel > 2) {
        printf("         *Not FOUND* (%sOK)\n", (missingOK) ? "" : "*not* ");
    }
    if (!missingOK) {

	fprintf(stderr, "Warning: cannot find %s ",
		LibraryUnit::unitTypeImage(unitType));
	if (sName != NULL) {
	    fprintf(stderr, "%s of %s", sName, name);
	} else {
	    fprintf(stderr, "%s", name);
	}
	fprintf(stderr, " in library %s", lib->getName());
        if (inferVlog) {
            fprintf(stderr, ": infering as a Verilog module");
        }
        fputc('\n', stderr);
    }

    return NULL;
}


//
// Resolve the primary/secondary unit relationships
//
static void
resolveGenealogy(LibraryHashTable* libs)
{
    LibraryHashTableIter scanLibs(libs);
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	LibraryUnitIter scanUnits(*scanLibs.entry());
	for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	    resolveGenealogy(scanUnits(), libs);
	}
    }
}
static void
resolveGenealogy(LibraryUnit*      unit,
                 LibraryHashTable* libs)
{
    if (debugLevel > 2) {
        printf("    Resolving genealogy in ");
	unit->printDesc(stdout);
	printf(" in library %s\n", unit->getLibrary()->getName());
    }

    LibraryUnit* parent = NULL;
    switch (unit->getType()) {
    case LibraryUnit::Architecture:
	parent = lookupUnit(unit->getLibrary(), LibraryUnit::Entity, unit->getParentName());
	break;
    case LibraryUnit::PackageBody:
	parent = lookupUnit(unit->getLibrary(), LibraryUnit::Package, unit->getParentName());
	break;
    case LibraryUnit::Configuration:
        {
            Dependency* dep = new Dependency(LibraryUnit::Entity, ((Configuration*) unit)->getLibName(),
					     unit->getParentName(), NULL);
	    parent = resolveReference(dep->libName(), dep->mainName(),
				      NULL, unit, libs, 0);
	    break;
        }
    }
    if (parent != NULL) {
	unit->setParent(parent);
	if (parent->getType() == LibraryUnit::Entity) {
	    Entity* ent = (Entity*) parent;
	    ent->addChild(unit);
	} else if (parent->getType() == LibraryUnit::Package) {
	    Package* pkg = (Package*) parent;
	    pkg->setBody((PackageBody*) unit);
	}
	parent->isReferenced();
    }
}


//
// Resolve all references by-name to their actual library unit
// (where possible)
//
static void
resolveReferences(LibraryHashTable* libs)
{
    LibraryHashTableIter scanLibs(libs);
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	LibraryUnitIter scanUnits(*scanLibs.entry());
	for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	    resolveReferences(scanUnits(), libs);
	}
    }
}
static void
resolveReferences(LibraryUnit*      unit,
		  LibraryHashTable* libs)
{
    if (debugLevel > 2) {
        printf("    Resolving reference in ");
	unit->printDesc(stdout);
	printf(" in library %s\n", unit->getLibrary()->getName());
    }

    switch (unit->getType()) {
    case LibraryUnit::Architecture:
	resolveReferences((Block*) ((Architecture*) unit), libs);
	break;
    }

    LibraryUnitDependsIter scanDepends(unit);
    for (scanDepends.reset(); scanDepends(); ++scanDepends) {
	scanDepends()->setUnit(resolveReference(scanDepends()->libName(),
						scanDepends()->mainName(),
						scanDepends()->secName(),
						unit, libs, 0));
    }
    LibraryUnitDefConfsIter scanDefConfs(unit);
    for (scanDefConfs.reset(); scanDefConfs(); ++scanDefConfs) {
	scanDefConfs()->setUnit(resolveReference(scanDefConfs()->libName(),
						 scanDefConfs()->mainName(),
						 scanDefConfs()->secName(),
						 unit, libs, 1));
    }
}
static void
resolveReferences(Block*            block,
		  LibraryHashTable* libs)
{
    if (debugLevel > 2) {
        printf("        Resolving reference in block %s\n", block->getName());
    }

    BlockConfigIter scanConfigs(block);
    for (scanConfigs.reset(); scanConfigs(); ++scanConfigs) {
        LibraryUnit* unit = resolveReference(scanConfigs()->libName(),
                                             scanConfigs()->mainName(),
                                             scanConfigs()->secName(),
                                             block->getUnit(), libs, 1);

        // Resolve default configuration to a single architecture
        // if possible
        if (unit != NULL && unit->getType() == LibraryUnit::Entity &&
            scanConfigs()->secName() == NULL) {
            EntityChildrenIter scanArchs((Entity *) unit);

            if (debugLevel > 6) {
                printf("    Resolving default config to entity %s\n",
                       ((Entity *) unit)->getName());
            }
            
            LibraryUnit* arch;
            unsigned nArchs = 0;
            for (scanArchs.reset(); scanArchs(); ++scanArchs) {

                // Skip configuration units
                if (scanArchs()->getType() != LibraryUnit::Architecture) {
                    continue;
                }

                scanArchs()->isReferenced();
                arch = scanArchs();
                nArchs++;
            }

            if (nArchs != 1) {
                fprintf(stderr, "Warning: %s architecture for default configuration to entity \"%s\" in ",
                        (nArchs > 1) ? "More than 1" : "No",
                        unit->getName());
                block->getUnit()->printDesc(stderr);
                fprintf(stderr, ".\n");
            } else {
                unit = arch;
            }
        }
        scanConfigs()->setUnit(unit);
    }
    SubBlockIter scanSubBlocks(block);
    for (scanSubBlocks.reset(); scanSubBlocks(); ++scanSubBlocks) {
	resolveReferences(scanSubBlocks(), libs);
    }
}
static LibraryUnit*
resolveReference(const char*       libName,
		 const char*       mainName,
                 const char*       secName,
		 LibraryUnit*      unit,
		 LibraryHashTable* libs,
		 unsigned          missingOK)
{
    unsigned unitType = LibraryUnit::Unknown;
    
    //
    // If the main name is "ALL", this was a 'use LIB.all'
    // statement. No dependencies on those...
    //
    if (strcmp(mainName, "ALL") == 0) return NULL;

    //
    // If the secondary name is "ALL", this was a 'use LIB.PKG.all'
    // statement. We're looking for a package
    //
    if (secName != NULL && strcmp(secName, "ALL") == 0) {
        unitType = LibraryUnit::Package;
        secName = NULL;
    }

    if (debugLevel > 2) {
        printf("    Resolving reference to %s.%s(%s)\n",
	       libName, mainName, maybe_null(secName));
    }
    
    //
    // If the dependency is in library "WORK?",
    // the library was not explicitely stated in the use clause.
    //
    if (strcmp(libName, "WORK?") == 0) {
        // First look into WORK
        LibraryUnit* depUnit = lookupUnit(unit->getLibrary(),
                                          unitType,
                                          mainName,
                                          secName, 1);
        // The list (in order) can be found in the known
        // libraries list on the unit and on it's parent (if applicable)
        if (unit->getParent() != NULL) {
            LibraryDeclIter scanLibraries(unit->getParent());
            for (scanLibraries.atHead(); scanLibraries(); ++scanLibraries) {
                Library* lib = libraries.lookup(scanLibraries());
                if (lib == NULL || !lib->inMakefile()) continue;
                
                LibraryUnit* libUnit = lookupUnit(lib,
                                                  unitType,
                                                  mainName,
                                                  secName, 1);
                
                // Units hide previously visible units
                if (libUnit != NULL) depUnit = libUnit;
            }
        }
	LibraryDeclIter scanLibraries(unit);
        for (scanLibraries.atHead(); scanLibraries(); ++scanLibraries) {
            Library* lib = libraries.lookup(scanLibraries());
            if (lib == NULL || !lib->inMakefile()) continue;
            
            LibraryUnit* libUnit = lookupUnit(lib,
                                              unitType,
                                              mainName,
                                              secName, 1);
            
            // Units hide previously visible units
            if (libUnit != NULL) depUnit = libUnit;
        }

        if (depUnit == NULL) {
	    if (missingOK) {
		// This probably was an attemp to resolve a
		// a default configuration
		if (unit->getType() == LibraryUnit::Architecture) {
		    if (warnOpenDefConf) {
			fprintf(stderr, "Warning: No default configuration for component %s in %s.%s(%s).\n",
				mainName, unit->getLibrary()->getName(),
				unit->getParentName(), unit->getName());
		    }
		}
		return NULL;
	    }
            fprintf(stderr, "Warning: Cannot locate unit %s in WORK or any included used library in ", mainName);
            unit->printDesc(stderr);
            fprintf(stderr, " in library %s\n", unit->getLibrary()->getName());
        } else {
            depUnit->isReferenced();
        }
        return depUnit;
    }

    //
    // Check if the dependency is in a library included
    // in the makefile - or that we even know about!
    // If not, ignore.
    //
    Library* lib;
    if (strcmp(libName, "WORK") == 0) {
        lib = unit->getLibrary();
    } else {
        lib = libraries.lookup(libName);
        if (lib == NULL || !lib->inMakefile()) return NULL;
    }

    //
    // Lookup the specified library for the unit in question
    //
    LibraryUnit* depUnit = lookupUnit(lib,
                                      unitType,
                                      mainName,
                                      secName, missingOK);
    if (depUnit != NULL) depUnit->isReferenced();
    return depUnit;
}


//
// Check the configuration of the model structure
//
static void
checkConfiguration(LibraryHashTable* libs)
{
    LibraryHashTableIter scanLibs(libs);
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
        SourceFileIter scanFiles(*scanLibs.entry());
        for (scanFiles.reset(); scanFiles(); ++scanFiles) {
            if (debugLevel > 1) {
                printf("Checking \"%s\"\n", scanFiles()->getName());
            }
            SourceFileUnitIter scanUnits(*scanFiles());
            for (scanUnits.reset(); scanUnits(); ++scanUnits) {
                if (debugLevel > 1) {
                    printf("   Checking \"%s\"\n", scanUnits()->getName());
                }
                LibraryUnitDefConfsIter scanDefConfs(scanUnits());
                for (scanDefConfs.reset(); scanDefConfs(); ++scanDefConfs) {
                    if (debugLevel > 1) {
                        printf("      Checking \"%s.%s.%s\"\n",
                               scanDefConfs()->libName(),
                               scanDefConfs()->mainName(),
                               maybe_null(scanDefConfs()->secName()));
                    }
                    // Maybe the potential default configuration may not
                    // be resolved in the current working library
                    if (scanDefConfs()->getUnit() == NULL) continue;
                    
                    // All architectures of the entity used in default configurations
                    // are assumed to be referenced (i.e. not top-level units)
                    EntityChildrenIter scanArchs((Entity *) scanDefConfs()->getUnit());
                    for (scanArchs.reset(); scanArchs(); ++scanArchs) {
                        if (scanArchs()->getType() == LibraryUnit::Architecture) {
                            scanArchs()->isReferenced();
                        }
                    }
                }
            }
        }
    }
}


//
// Print a target name
//
static void
print_target(FILE*        mkf,
	     const char*  libName,
	     LibraryUnit* unit,
	     int          width,
             int          lower)
{
    const char *p;
    
    if (strcmp(libName, "WORK") != 0) {
        for (p = libName; *p != '\0'; p++) {
            if (*p == '\\') {
                fputc('+', mkf);
		width--;
                continue;
            }
            if (!isalnum(*p) && *p != '_') {
                fprintf(mkf, "+%02X", *p);
		width -= 3;
                continue;
            }
            fputc((lower && isupper(*p)) ? tolower(*p) : *p, mkf);
	    width--;
        }
	fputc('.', mkf);
        width--;
    }
    if (unit->getParentName() != NULL) {
        for (p = unit->getParentName(); *p != '\0'; p++) {
            if (*p == '\\') {
                fputc('+', mkf);
		width--;
                continue;
            }
            if (!isalnum(*p) && *p != '_') {
                fprintf(mkf, "+%02X", *p);
		width =- 3;
                continue;
            }
            fputc((lower && isupper(*p)) ? tolower(*p) : *p, mkf);
	    width--;
        }
	fputc('+', mkf);
        width--;
    }
    for (p = unit->getName(); *p != '\0'; p++) {
        if (*p == '\\') {
            fputc('+', mkf);
	    width--;
            continue;
        }
	if (!isalnum(*p) && *p != '_') {
	    fprintf(mkf, "+%02X", *p);
	    width -= 3;
	    continue;
	}
        fputc((lower && isupper(*p)) ? tolower(*p) : *p, mkf);
        width--;
    }

    while (width > 0) {
        fputc(' ', mkf);
        width--;
    }
}


//
// Print a stamp file
//
static void
print_stamp(FILE*        mkf,
	    LibraryUnit* unit,
	    const char*	 before,
	    const char*	 after,
	    const char*  special)
{
    // Do not print a dependency if it has already been printed
    // on the makefile line
    // Takes care of multiple dependencies on the same unit and
    // of dependencies on units in the same file
    if (special == NULL && unit->isOnLine(lineCount, 1)) return;

    fprintf(mkf, "%s", before);
    if (special != NULL) {
	// Special stamp. Recompute stamp name, overlaying
	// the special postfix.
	const char* stamp;
	switch (unit->getType()) {
	case LibraryUnit::PackageBody:
	    stamp = makeStampName(unit->getLibrary()->getName(), unit->getName(),
				  "+body+", special);
	    break;	
	case LibraryUnit::Configuration:
	    stamp = makeStampName(unit->getLibrary()->getName(), unit->getName(),
				  "+conf+", special);
	    break;
	default:
	    stamp = makeStampName(unit->getLibrary()->getName(), unit->getName(),
				  unit->getParentName(), special);
	    break;
	}
	fprintf(mkf, "%s", stamp);
    } else {
	fprintf(mkf, "%s", unit->getId());
    }

    if (debugLevel > 0) {
	fprintf(mkf, "=[");
	unit->printDesc(mkf);
	if (special != NULL) fprintf(mkf, "%s", special);
	fprintf(mkf, "]");
	return;
    }

    fprintf(mkf, "%s", after);

}


//
// Print the list of stamp files the units in the file depend on
//
static void
print_dependencies(FILE*       mkf,
		   SourceFile* file)
{
    SourceFileUnitIter scanUnits(*file);
    for (scanUnits.reset(); scanUnits(); ++scanUnits) {

	LibraryUnit* parent = scanUnits()->getParent();
	if (parent != NULL) print_stamp(mkf, parent, " ");

	LibraryUnitDependsIter scanDepends(scanUnits());
	for (scanDepends.reset(); scanDepends(); ++scanDepends) {
            // Don't print if the dependency represents a
            // use LIB.all; statement
            if (strcmp(scanDepends()->mainName(), "ALL") == 0) continue;
            
	    print_dependencies(mkf, scanUnits(), scanDepends());
	}
	LibraryUnitDefConfsIter scanDefConfs(scanUnits());
	for (scanDefConfs.reset(); scanDefConfs(); ++scanDefConfs) {
	    print_dependencies(mkf, scanUnits(), scanDefConfs());
	}
    }

}
static void
print_dependencies(FILE*        mkf,
                   LibraryUnit* unit,
		   Dependency*  dep)
{
    if (dep->getUnit() != NULL) {
	print_stamp(mkf, dep->getUnit(), "\\\n\t\t");
	return;
    }

    // Ignore dependencies on libraries
    if (dep->getType() == LibraryUnit::LibraryAll) return;

    // Ignore dependencies in WORK or WORK?
    // (If they get to this point, they are unresolved default
    //  configurations)
    if (strcmp(dep->libName(), "WORK?") == 0 ||
	isWork(unit->getLibrary(), dep->libName())) return;

    // If the dependency is in a library we know about,
    // and not included in the makefile,
    // generate a stamps file name based on the name of the
    // unit we depend on.
    Library* lib = libraries.lookup(dep->libName());
    if (lib == NULL) {
	static StringHashTable warnLibraries(13);

	if (warnLibraries.lookup(dep->libName()) == NULL &&
	    strcmp(dep->libName(), "STD") != 0 &&
            // The IEEE library is sometimes not ignored
            (strcmp(dep->libName(), "IEEE") != 0 || useIEEE)) {
            warnLibraries.insert(dep->libName(), "seen");
            fprintf(stderr, "WARNING: Reference to unknown library %s\n",
                    dep->libName());
	}
	return;
    }

    {
	const char* parentName = NULL;
	const char* unitName = dep->mainName();

	// There can be a dependency on an architecture in another
	// library
	if (dep->getType() == LibraryUnit::Architecture) {
	    parentName = unitName;
	    unitName = dep->secName();
	} else if (dep->getType() == LibraryUnit::Configuration) {
	    parentName = "+conf+";
	} else if (inferVlog) {
            // Optionally assume that unresolved dependencies
            // refer to Verilog modules
            vlogModules.replace(makeStampName(dep->libName(),
                                              unitName, NULL), dep);
        }

	fprintf(mkf, "\\\n\t\t%s",
                makeStampName(dep->libName(), unitName, parentName));
	if (debugLevel > 0) {
	    if (dep->getType() == LibraryUnit::Architecture) {
		fprintf(mkf, "=[%s.%s(%s)]", dep->libName(), parentName, unitName);
	    } else {
		fprintf(mkf, "=[%s.%s]", dep->libName(), unitName);
	    }
	}
    }
}

// Print the list of dependencies this unit requires to simulate
//
static void
print_runtime_dependencies(FILE*	mkf,
			   LibraryUnit* unit,
			   const char*  archName)
{
    // If this unit has already been visited as a runtime dependency
    // for this target, ignore it.
    if (unit->isOnLine(lineCount, 0)) return;

    switch (unit->getType()) {
    case LibraryUnit::Configuration:
    case LibraryUnit::Architecture:
    case LibraryUnit::PackageBody:
        print_stamp(mkf, unit, "\\\n\t");
        break;
    case LibraryUnit::Entity:
      {
        Entity* ent = (Entity*) unit;
        EntityChildrenIter scanArchs(ent);
        if (archName == NULL) {
            // Default configuration or configuration
            // with unspecified architecture
            for (scanArchs.reset(); scanArchs(); ++scanArchs) {
                if (scanArchs()->getType() == LibraryUnit::Architecture) {
                    print_runtime_dependencies(mkf, scanArchs());
                }
            }
        } else {
            LibraryUnit* arch = NULL;
            for (scanArchs.reset(); scanArchs(); ++scanArchs) {
                if (strcmp(scanArchs()->getName(), archName) == 0) {
                    arch = scanArchs();
                    break;
                }
            }
            if (arch == NULL) {
                fprintf(stderr, "Cannot find architecture \"%s\" of entity \"%s\"\n",
                        archName, unit->getName());
            } else {
                print_runtime_dependencies(mkf, arch);
            }
        }
      }
      break;
    case LibraryUnit::Package:
      {
        Package* pkg = (Package*) unit;
        print_stamp(mkf, pkg, "\\\n\t");
        if (pkg->getBody() != NULL) {
	  print_runtime_dependencies(mkf, pkg->getBody(), NULL);
        }
      }
      break;
    default:
      return;
    }

    // The packages and their bodies used by the parent are needed
    if (unit->getParent() != NULL) {
        print_runtime_package_dependencies(mkf, unit->getParent());
    }

    // The units this unit depends on are also required
    LibraryUnitDependsIter scanDepends(unit);
    for (scanDepends.reset(); scanDepends(); ++scanDepends) {
        // If this is a unit in another library...
        if (scanDepends()->getUnit() == NULL) {
            print_runtime_external_dependency(mkf, scanDepends());
            continue;
        }
            
        print_runtime_dependencies(mkf, scanDepends()->getUnit(),
                                   scanDepends()->secName());
    }
    LibraryUnitDefConfsIter scanDefConfs(unit);
    for (scanDefConfs.reset(); scanDefConfs(); ++scanDefConfs) {
        if (scanDefConfs()->getUnit() == NULL) continue;

        print_runtime_dependencies(mkf, scanDefConfs()->getUnit());
    }
}
static void
print_runtime_package_dependencies(FILE*	mkf,
				   LibraryUnit* unit)
{
    LibraryUnitDependsIter scanDepends(unit);
    for (scanDepends.reset(); scanDepends(); ++scanDepends) {
        if (scanDepends()->getType() != LibraryUnit::Package) continue;

        if (scanDepends()->getUnit() == NULL) {
            print_runtime_external_dependency(mkf, scanDepends());
            continue;
        }

        print_runtime_dependencies(mkf, scanDepends()->getUnit());
    }
}


static void
print_runtime_external_dependency(FILE*       mkf,
                                  Dependency* dep)
{
    // We can't if we don't know about the libary...
    if (libraries.lookup(dep->libName()) == NULL) return;

    // We might be able to add dependencies to some of them...
    switch (dep->getType()) {
    case LibraryUnit::Configuration:
        fprintf(mkf, "\\\n\t%s", makeStampName(dep->libName(),
                                               dep->mainName(), "+conf+"));
        break;
    case LibraryUnit::Entity:
        fprintf(mkf, "\\\n\t%s", makeStampName(dep->libName(),
                                               dep->mainName(), NULL));
        break;
    case LibraryUnit::Architecture:
        fprintf(mkf, "\\\n\t%s",makeStampName(dep->libName(),
                                              dep->secName(), dep->mainName()));
        break;
    case LibraryUnit::Package:
        fprintf(mkf, "\\\n\t%s", makeStampName(dep->libName(),
                                               dep->mainName(), NULL));
        // Assume there will always be a package body
        fprintf(mkf, "\\\n\t%s", makeStampName(dep->libName(),
                                               dep->mainName(), "+body+"));
        break;
    }
}


//
// Print a file-oriented command
//
static void
print_file_command(FILE*       mkf,
                   Library*    lib,
		   const char* filename,
		   const char* override,
		   const char* args)
{
    if (override == NULL) override = ToolSet::getAnalyzeCommand();

    // Replace '%f' in command string by args + filename
    // Replace '%w' in command string by library name (required)
    // or append filename if no file marker
    fputc('\t', mkf);
    unsigned f_marker_seen = 0;
    static unsigned w_marker_seen = 0;
    for (const char* p = override; *p != '\0'; p++) {
	if (*p == '%') {
	    switch (*++p) {
	    case '%':
		fputc('%', mkf);
		break;
	    case 'f':
		f_marker_seen = 1;
		if (args != NULL) fprintf(mkf, "%s ", args);
		fprintf(mkf, "%s", filename);
		break;
	    case 'w':
	    case 'W':
	    {
		w_marker_seen = 1;
                
                const char* libName = lib->getName();
                // If this is the WORK library,
                // use an alias for the %w marker
                if (strcmp(libName, "WORK") == 0) {
                    LibraryAliasIter scanAliases(*lib);
                    scanAliases.reset();
                    libName = scanAliases.key();
                    if (libName == NULL) {
                        libName = "WORK";
                    }
                }
		fprintf(mkf, "%s", lowerOrUpperCase(libName, *p == 'w'));
	    }
	    break;
	    default:
		fprintf(stderr, "Unknown marker '%%%c' in analyze command\n", *p);
		break;
	    }
	    continue;
	}
	fputc(*p, mkf);
    }
    if (!f_marker_seen) {
	if (args != NULL) fprintf(mkf, " %s", args);
	fprintf(mkf, " %s", filename);
    }
    if (!w_marker_seen && multiLibrary) {
        fprintf(stderr, "ERROR: Must use analyze command with a '%%w' marker in multi library mode\n");
        fprintf(stderr, "       Command was: \"%s\"\n", override);
        
        w_marker_seen = 1;
        exitCode = -1;
    }
    fputc('\n', mkf);
}


//
// Print a vlog-oriented command
//
static void
print_vlog_command(FILE*       mkf,
                   Library*    lib,
		   const char* module,
		   const char* override,
		   const char* args)
{
    if (override == NULL) override = ToolSet::getVlogCommand();

    // Replace '%m/%M' in command string by module name
    // Replace '%w' in command string by library name (required)
    // or append modulename.v if no file marker
    fputc('\t', mkf);
    unsigned m_marker_seen = 0;
    static unsigned w_marker_seen = 0;
    for (const char* p = override; *p != '\0'; p++) {
	if (*p == '%') {
	    switch (*++p) {
	    case '%':
		fputc('%', mkf);
		break;
	    case 'p':
		if (lib != NULL) {
                    fprintf(mkf, "%s", lib->getPath());
                    fputc('/', mkf);
                }
		break;
	    case 'm':
	    case 'M':
		m_marker_seen = 1;
		if (args != NULL) fprintf(mkf, "%s ", args);
		fprintf(mkf, "%s", lowerOrUpperCase(module, *p == 'm'));
		break;
	    case 'w':
	    case 'W':
	    {
		w_marker_seen = 1;
                
                const char* libName = lib->getName();
                // If this is the WORK library,
                // use an alias for the %w marker
                if (strcmp(libName, "WORK") == 0) {
                    LibraryAliasIter scanAliases(*lib);
                    scanAliases.reset();
                    libName = scanAliases.key();
                    if (libName == NULL) {
                        libName = "WORK";
                    }
                }
		fprintf(mkf, "%s", lowerOrUpperCase(libName, *p == 'w'));
	    }
	    break;
	    default:
		fprintf(stderr, "Unknown marker '%%%c' in analyze command\n", *p);
		break;
	    }
	    continue;
	}
	fputc(*p, mkf);
    }
    if (!m_marker_seen) {
	if (args != NULL) fprintf(mkf, " %s", args);
	fprintf(mkf, " %s.v", lowerOrUpperCase(module, 1));
    }
    if (!w_marker_seen && multiLibrary) {
        fprintf(stderr, "ERROR: Must use verilog command with a '%%w' marker in multi library mode\n");
        fprintf(stderr, "       Command was: \"%s\"\n", override);
        
        w_marker_seen = 1;
        exitCode = -1;
    }
    fputc('\n', mkf);
}


//
// Print a library unit-oriented command
//
static void
print_unit_command(FILE*        mkf,
		   const char*  command,
                   Library*     lib,
		   LibraryUnit* unit)
{
    unsigned        marker_seen = 0;
    static unsigned w_marker_seen = 0;
    const char*     p;

    switch (unit->getType()) {
    case LibraryUnit::Architecture:

	// Replace '%w', '%e' and '%a' in command string with
	// library, entity and architecture name respectively.
	// Append "%e %a" if they are missing.
	fputc('\t', mkf);
	for (p = command; *p != '\0'; p++) {
	    if (*p == '%') {
		switch (*++p) {
		case '%':
		    fputc('%', mkf);
		    break;
                case 'w':
                case 'W':
                {
                    w_marker_seen = 1;
                    const char* libName = lib->getName();
                    // If this is the WORK library,
                    // use an alias for the %w marker
                    if (strcmp(libName, "WORK") == 0) {
                        LibraryAliasIter scanAliases(*lib);
                        scanAliases.reset();
                        libName = scanAliases.key();
                        if (libName == NULL) {
                            libName = "WORK";
                        }
                    }
                    fprintf(mkf, "%s", lowerOrUpperCase(libName, *p == 'w'));
                }
		break;
		case 'e':
		    fprintf(mkf, "%s", unit->getParentName());
		    marker_seen = 1;
		    break;
		case 'a':
		    fprintf(mkf, "%s", unit->getName());
		    marker_seen = 1;
		    break;
		default:
		    fprintf(stderr, "Unknown marker '%%%c' in analyze command\n", *p);
		    break;
		}
		continue;
	    }
	    fputc(*p, mkf);
	}
	if (!marker_seen) {
	    fprintf(mkf, " %s %s", unit->getParentName(), unit->getName());
	}
        if (!w_marker_seen && multiLibrary) {
            fprintf(stderr, "ERROR: Must use elaborate/simulate architecture command with a '%%w' marker in multi library mode\n");
            fprintf(stderr, "       Command was: \"%s\"\n", command);
        
            w_marker_seen = 1;
            exitCode = -1;
        }
	fputc('\n', mkf);
	break;

    case LibraryUnit::Configuration:

	// Replace '%w' and '%c' in command string with
	// library and configuration name
	// Append configuration name if '%c' is missing
	fputc('\t', mkf);
	for (p = command; *p != '\0'; p++) {
	    if (*p == '%') {
		switch (*++p) {
		case '%':
		    fputc('%', mkf);
		    break;
		case 'w':
                case 'W':
		{
                    w_marker_seen = 1;
                    const char* libName = lib->getName();
                    // If this is the WORK library,
                    // use an alias for the %w marker
                    if (strcmp(libName, "WORK") == 0) {
                        LibraryAliasIter scanAliases(*lib);
                        scanAliases.reset();
                        libName = scanAliases.key();
                        if (libName == NULL) {
                            libName = "WORK";
                        }
                    }
                    fprintf(mkf, "%s", lowerOrUpperCase(libName, *p == 'w'));
		}
		break;
		case 'c':
		    fprintf(mkf, "%s", unit->getName());
		    marker_seen = 1;
		    break;
		default:
		    fprintf(stderr, "Unknown marker '%%%c' in analyze command\n", *p);
		    break;
		}
		continue;
	    }
	    fputc(*p, mkf);
	}
	if (!marker_seen) {
	    fprintf(mkf, " %s", unit->getName());
	}
        if (!w_marker_seen && multiLibrary) {
            fprintf(stderr, "ERROR: Must use a user-defined elaborate/simulate architecture command with a '%%w' marker in multi library mode\n");
            w_marker_seen = 1;
            exitCode = -1;
        }
	fputc('\n', mkf);
	break;
    }
}


//
// Generate Configuration unit
//
static void
genConfiguration(const char*       fname,
		 const char*       libName,
		 const char*       entName,
		 const char*       archName,
		 LibraryHashTable* libs)
{
    Library* lib;
    Entity* ent = NULL;
    char uname[1024];
    
    // Locate the top-level entity+architecture
    if (libName != NULL) {

	// Look in a specific library

	lib = libs->lookup(libName);
	if (lib == NULL) {
	    fprintf(stderr, "ERROR: unknown library %s\n", libName);
	    exit(-1);
	}
	// Look for the entity in that library
	LibraryUnitIter scanUnits(*lib);
	for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	    if (scanUnits()->getType() == LibraryUnit::Entity &&
		strcmp(scanUnits()->getName(), entName) == 0) {
		// This should not happen, but just in case...
		if (ent != NULL) {
		    fprintf(stderr, "ERROR: more than one entity named %s in library %s.\n",
			    entName, libName);
                    exitCode = -1;
		    return;
		}
		ent = (Entity*) scanUnits();
	    }
	}
        if (ent == NULL) {
            fprintf(stderr, "ERROR: Cannot find entity %s in library %s.\n",
                    entName, libName);
            exitCode = -1;
            return;
        }
            
    } else {

	// Look in all known libraries

	LibraryHashTableIter scanLibs(libs);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
	    // Look for the entity in that library
	    LibraryUnitIter scanUnits(*scanLibs.entry());
	    for (scanUnits.reset(); scanUnits(); ++scanUnits) {
		if (scanUnits()->getType() == LibraryUnit::Entity &&
		    strcmp(scanUnits()->getName(), entName) == 0) {
                    lib = scanLibs.entry();
		    if (ent != NULL) {
			fprintf(stderr,
				"ERROR: more than one entity named %s.\n",
				entName);
			exit(-1);
		    }
		    ent = (Entity*) scanUnits();
		}
	    }
	}
        if (ent == NULL) {
            fprintf(stderr, "ERROR: Cannot find entity %s.\n", entName);
            exitCode = -1;
            return;
        }
    }

    // We have the top-level entity,
    // make sure we can find an architecture
    Architecture *arch = NULL;
    if (archName == NULL) {
	// No architecture was specified,
	// there better be a single one!
	EntityChildrenIter scanArchs(ent);
	for (scanArchs.reset(); scanArchs(); ++scanArchs) {
	    if (arch != NULL) {
		fprintf(stderr, "ERROR: more than one architecture for entity ");
		if (libName != NULL) fprintf(stderr, "%s.", libName);
		fprintf(stderr, "%s.\n", entName);
                exitCode = -1;
		return;
	    }
	    arch = (Architecture*) scanArchs();
            archName = scanArchs()->getName();
	}
        if (arch == NULL) {
            fprintf(stderr, "ERROR: No architecture for entity ");
            if (libName != NULL) fprintf(stderr, "%s.", libName);
            fprintf(stderr, "%s.\n", entName);
            exitCode = -1;
            return;
        }
    } else {
	// Locate the named architecture
	EntityChildrenIter scanArchs(ent);
	for (scanArchs.reset(); scanArchs(); ++scanArchs) {
	    if (strcmp(scanArchs()->getName(), archName) == 0) {
                arch = (Architecture*) scanArchs();
                break;
            }
	}
        if (arch == NULL) {
            fprintf(stderr, "ERROR: architecture %s for entity ", archName);
            if (libName != NULL) fprintf(stderr, "%s.", libName);
            fprintf(stderr, "%s does not exist.\n", entName);
            exitCode = -1;
            return;
        }
    }

    FILE* fp;
    if ((fp = fopen(fname, "w")) == NULL) {
        fprintf(stderr, "ERROR: Cannot open %s for writing: ", fname);
        perror(0);
        exitCode = -1;
        return;
    }
    
    fprintf(stderr, "Generating configuration in %s ...\n", fname);
    // Create a descriptor for the source file and library unit
    // we are about to create...
    SourceFile* file = new SourceFile(fname);
    lib->addFile(file);
    // Generate the configuration unit name based on the specified pattern
    {
        char* b = uname;
        for (const char* p = genConfUnitPattern; *p != '\0'; p++) {
            if (*p == '%') {
                switch (*++p) {
                case '%':
                    *b++ = '%';
                    break;
		case 'e':
                    for (const char* q = entName; *q != '\0'; q++) {
                        *b++ = isupper(*q) ? tolower(*q) : *q;
                    }
		    break;
		case 'E':
                    for (const char* q = entName; *q != '\0'; q++) {
                        *b++ = islower(*q) ? toupper(*q) : *q;
                    }
		    break;
		case 'a':
                    for (const char* q = archName; *q != '\0'; q++) {
                        *b++ = isupper(*q) ? tolower(*q) : *q;
                    }
		    break;
		case 'A':
                    for (const char* q = archName; *q != '\0'; q++) {
                        *b++ = islower(*q) ? toupper(*q) : *q;
                    }
		    break;
                default:
                    fprintf(stderr, "Unknown marker '%%%c' in config unit pattern\n", *p);
                    break;
                }
                continue;
            }
            *b++ = *p;
        }
        *b = '\0';
    }
    LibraryUnit* unit = new Configuration(uname, lib->getName(), entName, file, lib);
    file->addUnit(unit);
    unit->setParent(ent);
    ent->addChild(unit);
    unit->setId(makeStampName(lib->getName(), unit->getName(), "+conf+"));
    // We can produce the configuration unit's header...

    // Banner
    fprintf(fp, "--\n-- Configuration generated by VMK %1.3f\n--\n\n", version);

    // Declare all known libraries
    LibraryHashTableIter scanLibs(libs);
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        if (strcmp(scanLibs.key(), "WORK") == 0 ||
            strcmp(scanLibs.key(), "work") == 0) continue;
        fprintf(fp, "library %s;\n", scanLibs.key());
    }

    fprintf(fp, "\nconfiguration %s of ", uname);
    if (libName != NULL) fprintf(fp, "%s.", libName);
    fprintf(fp, "%s is\n", entName);

    Dependency* dep = new Dependency(LibraryUnit::Architecture,
                                     arch->getLibrary()->getName(),
                                     arch->getParentName(),
                                     arch->LibraryUnit::getName());
    dep->setUnit(arch);
    unit->addDependency(dep);

    // Everything is a block from here down...
    genBlockConfig(fp, arch, unit, 0);

    fprintf(fp, "end %s;\n", uname);
}


//
// Find a configuration unit associated with an entity
//
Configuration* findConfigurationUnit(Entity* ent)
{
    Configuration* conf = NULL;

    // Is a configuration unit for that entity available?
    EntityChildrenIter scanChilds(ent);
    for (scanChilds.reset(); scanChilds(); ++scanChilds) {
        
        // Skip architectures
        if (scanChilds()->getType() != LibraryUnit::Configuration) {
            continue;
        }
        
        if (conf != NULL) {
            fprintf(stderr, "Warning: More than 1 configuration unit for entity %s.%s.\n",
                    ent->getLibrary()->getName(), ent->getName());
            fprintf(stderr, "         Using configuration unit %s.\n",
                    conf->getName());
            
            break;
        }
        conf = (Configuration*) scanChilds();
    }

    return conf;
}


//
// Generate a block configuration at the specified nesting level
//
static void
genBlockConfig(FILE*        fp,
	       Block*       block,
               LibraryUnit* unit,
	       unsigned     nest)
{
    char *prefix;
    unsigned i;

    prefix = new char[nest * 3 + 1];
    for (i = 0; i < nest * 3; prefix[i++] = ' ');
    prefix[i] = '\0';

    fprintf(fp, "%sfor %s\n", prefix, block->getName());

    StringHashTable componentName(13);
    BlockConfigIter scanConfigs(block);
    for (scanConfigs.reset(); scanConfigs(); ++scanConfigs) {
        Dependency* dep = NULL;

        if (config_all) {
            // If doing a 'for all:comp' style, check that we
            // have not already configured a previous instance
            // of this component in this block
            if (componentName.lookup(scanConfigs()->compName()) != NULL) continue;
        }
        
	if (scanConfigs()->getUnit() == NULL) {
	    fprintf(fp, "%s-- for %s:%s use open;\n", prefix,
	    	    scanConfigs()->labelName(), scanConfigs()->compName());
            fprintf(fp, "%s-- end for;\n", prefix);
            continue;
        }

	// Explicit configuration found
        componentName.insert(scanConfigs()->compName(), "done");
        fprintf(fp, "%s   for %s:%s ", prefix,
	        (config_all) ? "all" : scanConfigs()->labelName(),
                scanConfigs()->compName());

	switch (scanConfigs()->getUnit()->getType()) {
            
	case LibraryUnit::Configuration:
	    fprintf(fp, "use configuration %s.%s;\n",
		    scanConfigs()->getUnit()->getLibrary()->getName(),
		    scanConfigs()->getUnit()->getName());
            dep = new Dependency(LibraryUnit::Configuration,
                                 scanConfigs()->getUnit()->getLibrary()->getName(),
                                 scanConfigs()->getUnit()->getParentName(),
                                 scanConfigs()->getUnit()->getName());
            dep->setUnit(scanConfigs()->getUnit());
	    break;
            
	case LibraryUnit::Entity:
            if (config_to_config) {
                Configuration* conf = findConfigurationUnit((Entity *) scanConfigs()->getUnit());
                if (conf != NULL) {
                    fprintf(fp, "use configuration %s.%s;\n",
                            conf->getLibrary()->getName(),
                            conf->getName());
                    dep = new Dependency(LibraryUnit::Configuration,
                                         conf->getLibrary()->getName(),
                                         conf->getName(),
                                         NULL);
                    dep->setUnit(conf);
                    break;
                }
            }
            fprintf(fp, "use entity %s.%s;\n",
                    scanConfigs()->getUnit()->getLibrary()->getName(),
                    scanConfigs()->getUnit()->getName());
            dep = new Dependency(LibraryUnit::Entity,
                                 scanConfigs()->getUnit()->getLibrary()->getName(),
                                 scanConfigs()->getUnit()->getName(),
                                 NULL);
            dep->setUnit(scanConfigs()->getUnit());
	    break;
            
	case LibraryUnit::Architecture:
            if (config_to_config) {
                Configuration* conf = findConfigurationUnit((Entity *) scanConfigs()->getUnit()->getParent());
                if (conf != NULL) {
                    fprintf(fp, "use configuration %s.%s;\n",
                            conf->getLibrary()->getName(),
                            conf->getName());
                    dep = new Dependency(LibraryUnit::Configuration,
                                         conf->getLibrary()->getName(),
                                         conf->getName(),
                                         NULL);
                    dep->setUnit(conf);
                    break;
                }
            }
	    fprintf(fp, "\n%s      use entity %s.%s(%s);\n", prefix,
		    scanConfigs()->getUnit()->getLibrary()->getName(),
		    scanConfigs()->getUnit()->getParentName(),
		    scanConfigs()->getUnit()->getName());
            dep = new Dependency(LibraryUnit::Architecture,
                                 scanConfigs()->getUnit()->getLibrary()->getName(),
                                 scanConfigs()->getUnit()->getParentName(),
                                 scanConfigs()->getUnit()->getName());
            dep->setUnit(scanConfigs()->getUnit());
	    genBlockConfig(fp, (Architecture*) scanConfigs()->getUnit(), unit, nest + 2);
	    break;
	}
	fprintf(fp, "%s   end for;\n", prefix);
        if (dep != NULL) unit->addDependency(dep);
    }
    SubBlockIter scanSubBlocks(block);
    for (scanSubBlocks.reset(); scanSubBlocks(); ++scanSubBlocks) {
	genBlockConfig(fp, scanSubBlocks(), unit, nest + 1);
    }

    fprintf(fp, "%send for;\n", prefix);

    delete [] prefix;
}


//
// Find out the real name for the WORK library
//
static const char*
getWorkLibName()
{
    const char* libName = NULL;

    Library* workLib = libraries.lookup("WORK");
    LibraryAliasIter scanAliases(*workLib);
    libName = scanAliases.reset();
    if (libName == NULL) {
        libName = "WORK";
    } else if (++scanAliases != NULL) {
        fprintf(stderr, "WARNING: %s used for WORK library name in stamp directory pattern.\n");
    }

    return libName;
}


//
// Convert a string to all-upper or all-lower case
//
static const char*
lowerOrUpperCase(const char* string,
                 unsigned    lower)
{
    static char buf[512];
    const char* p;
    char* q;

    if (string == NULL) return "(null)";
    
    for (p = string, q = buf; *p; p++, q++) {
        *q = (lower) ? tolower(*p) : toupper(*p);
    }
    *q = '\0';

    return buf;
}

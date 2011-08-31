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

//|@name@
//| vmk
//
//|@synopsis@
//| @(name)@ - Makefile maker for VHDL source
//
//|@description@
//| \fI@(name)@\fP peruses a collection of VHDL source files,
//| determines the analysis order dependencies
//| and produces a makefile for all the library units found in
//| all the files examined.
//| The generated makefile can be targetted toward any existing
//| commercial VHDL toolset.
//|.LP
//| Since \fI@(name)@\fP does not perform a complete analysis of the
//| source files, certain conditions must be met in order for the
//| dependencies to be correctly deduced.
//|.LP
//| \fI@(name)@\fP is VHDL-93 compatible.

//|@copyright@
//| (c) Copyrights 1996-2007  Janick Bergeron
//| Licensed under Apache V2.0
//
//|@authors@
//|.nf
//| Janick Bergeron
//| janick@bergeron.com
//|.fi
//
#include <ctype.h>
#include <sys/types.h>
#ifdef MSDOS
#include <dir.h>
#endif
#ifdef HPUX
# include <sys/sigevent.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

static char* snoop = "Curious about the strings in the binary, eh ?";

#ifdef MSDOS
#include <dos.h>
#endif
#ifdef LINUX
#include <unistd.h>
#endif
extern "C" {
    extern int optind;
};

#include "globals.hxx"
#include "ToolSet.hxx"
#include "rcFile.hxx"
#include "VHDLprse.hxx"
#include "Makefile.hxx"
#include "Conseq.hxx"

#include "relocate.h"
#include "envexp.h"

#include "../version.hxx"

//
// Global variables
//
int      exitCode       = 0;
unsigned debugLevel     = 0;
unsigned displayItems   = 0;
unsigned printDict      = 0;
unsigned allTops        = 0;
unsigned useLongNames   = 1;
unsigned multiLibrary   = 0;
unsigned warnOpenDefConf = 0;
unsigned noMakefile     = 0;
unsigned noSimTarget    = 0;
unsigned useIEEE        = 0;
unsigned inferVlog      = 0;
const char* stampDirPattern = NULL;
const char* stampDirSuffix = "";
const char* genConfLibrary = NULL;
const char* genConfEntity = NULL;
const char* genConfArch = NULL;
const char* genConfUnitPattern = "%e_%a_cfg";
const char* genConfFilePattern = "%e_cfg.vhd";
unsigned config_all       = 0;
unsigned config_to_config = 0;

const char* preprocess = NULL;

StringHashTable queryNames(13);
const char* headerFile = NULL;
const char* includeFile[3] = {NULL, NULL, NULL};


#ifdef MSDOS
static const char* vmkrc  = "vmk.rc";
#else
static const char* vmkrc  = ".vmkrc";
#endif


static char copyright[] =
"(c) copyrights  Janick Bergeron, 1996-2007\n    Licensed under Apache V2.0";

static void parseListOfFile(const char* filename,
                            Library* lib);
static void parseListOfLibFile(const char* filename);
static int isDuplicate(LibraryUnit* unit,
                       Library* lib,
                       SourceFile* stop);

int
main(int argc, char*const* argv)
{
    Library* workLib;

#ifdef HPUX
    queryNames.init(13);
#endif
    char version_string[10];
    sprintf(version_string, "%1.3f", version);
    fprintf(stderr, "VMK version %s\n", version_string);

    fprintf(stderr, "%s\n\n", copyright);

    // Create a default WORK library
    // if the -l option will not be used
    // to remain backward-compatible with VMK prior to version 5.x
    workLib = new Library("WORK", ".", NULL);

    //|@default rc files loaded@
    //| By default, \fI@(name)@\fP looks for 3 rc files in the
    //| following order:
    //| the file specified in the VMKRC environment variable,
    //| the file \fI.vmkrc\fP in the user's home directory
    //| (as specified by the HOME environment variable)
    //| and the file \fI.vmkrc\fP in the current working directory.
    const char* fileName = getenv("VMKRC");
    if (fileName != NULL) {
        rcFile VMKRC(NULL, fileName, workLib);
    }
    const char* homeDir = getenv("HOME");
    if (homeDir != NULL) {
        rcFile homeRc(homeDir, vmkrc, workLib);
    }
    {
        rcFile dotRc(".", vmkrc, workLib);
    }

    //
    //| Command-line options superceed any rc file setting
    //

    //|@default output@
    //| By default, the makefile is produced on the standard output.
    const char* makefileFilename = "-";
    
    char c;
    unsigned minusf                = 0;
    unsigned minusF                = 0;
    int      showMappingsOnly      = 0;
    unsigned showVersionOnly       = 0;
    unsigned queries               = 0;
    unsigned listToolsets          = 0;
    unsigned inferMakefileFilename = 0;
    char*    conseqFilename        = NULL;
    unsigned printUsage            = 0;
    char*    toolname              = NULL;
    
    const char* optSpec = "0:ab:C:df:F:hHil:LmMnNo:Oq:Q:r:S:t:TuvVw:";
    while ((c = getopt(argc, argv, optSpec)) != EOF) {
        switch (c) {

        case '0':
            //|@-0 option@
            //|.IP "-0 level"
            //| Set debug level to specified integer value.
            //| High levels will produce more detailed
            //| debug information.
            debugLevel = atoi(optarg);
            break;

        case 'a':
            config_all = 1;
            break;

        case 'b':
            //|@-b option@
            //|.IP "-b hard|soft"
            //| Specify whether hard or soft bindings will
            //| be used to determine dependencies from
            //| configuration specifications in architectures.
            //| @(default bindings)@
            if (strcmp(optarg, "soft")) {
                ToolSet::setBindings(ToolSet::Soft);
            } else if (strcmp(optarg, "hard")) {
                ToolSet::setBindings(ToolSet::Hard);
            } else {
                fprintf(stderr, "Invalid binding specification \"%s\".\n", optarg);
                printUsage = 1;
            }
            break;

        case 'C':
	{
	    char* p;
	    char* q;

	    p = strdup(optarg);
	    for (q = p; *q != '\0' && *q != '+'; q++) {
                if (islower(*q)) *q = toupper(*q);
            }
	    if (*q == '\0') {
		fprintf(stderr, "Error: No architecture specified for top-level entity to configure.\n");
		printUsage = 1;
		continue;
	    }
	    *q++ = '\0';
            genConfLibrary = NULL;
            genConfEntity  = p;
            genConfArch    = q;
	    // Make sure the architecture name is UPPER
	    for (; *q != '\0'; q++) {
                if (islower(*q)) *q = toupper(*q);
            }
	    // Maybe the entity is prefixed with a library name...
	    for (q = p; *q != '\0' && *q != '.'; q++) {
                if (islower(*q)) *q = toupper(*q);
            }
	    if (*q == '.') {
		*q++ = '\0';
		genConfLibrary = p;
		genConfEntity  = q;
	    }
	    // Implies -d
	    warnOpenDefConf = 1;
            break;
	}

        case 'd':
            warnOpenDefConf = 1;
            break;

        case 'D':
            printDict = 1;
            break;

        case 'f':
            minusf = 1;
            parseListOfFile(optarg, workLib);
            break;

        case 'F':
	    minusF = 1;
            multiLibrary = 1;  // Implies -l
            parseListOfLibFile(optarg);
            break;

        case 'h':
            //|@-h option@
            //|.IP "-h"
            //| Display the usage information only.
            printUsage = 1;
            break;

        case 'H':
            //|@-H option@
            //|.IP "-H"
            //| Display the list of supported toolsets
            listToolsets = 1;
            break;

        case 'i':
            //|@-i option@
            //|.IP "-i"
            //| Display the list of top-level units.
            //| By default, only the simulatable targets
            //| are displayed.
            //| @(default item display)@
            displayItems = 1;
            break;

        case 'l':
            //|@-l option@
            //|.IP "-l libname"
            //| Include all source files for the specified library
	    //| in the makefile.
	    //| Use '-l all' to include the source files from
	    //| all known libraries
            multiLibrary = 1;
	    if (strcmp(optarg, "all") == 0) {
		LibraryHashTableIter scanLibraries(&libraries);
		for (scanLibraries.reset(); scanLibraries.key(); ++scanLibraries) {
		    scanLibraries.entry()->make();
		}
	    } else {
                // Make sure the library is specified in UPPERCASE
                char libname[64];
                char* t = libname;
                const char* f;
                for(f = optarg; *f != '\0'; f++) {
                    *t++ = (islower(*f)) ? toupper(*f) : *f;
                }
                *t = '\0';
		Library* lib = libraries.lookup(libname);
		if (lib == NULL) {
		    fprintf(stderr, "Unknown library \"%s\".\n", optarg);
		} else {
		    lib->make();
		}
	    }
	    break;

	case 'L':
	    //|@-L option@
	    //|.IP "-L"
	    //| Use short timestamp filenames.
	    //| The generated makefile is useable on
	    //| architecture supporting 8.3 filenames only.
	    useLongNames = 0;
	    break;

	case 'm':
	    //|@-m option@
	    //|.IP -m
	    //| @(print library mappings)@
	    showMappingsOnly = 1;
	    break;

	case 'M':
	    showMappingsOnly = -1;
	    break;

	case 'n':
	    noSimTarget = 1;
	    break;

	case 'N':
	    noMakefile = 1;
	    break;

	case 'o':
	    //|@-o option@
	    //|.IP "-o \fIfname\fP"
	    //| Output makefile in the specified file.
	    //| @(default output)@
	    makefileFilename = optarg;
	    break;

	case 'O':
	    //|@-O option@
	    //|.IP "-O"
	    //| Output makefile in a file named
	    //| "Makefile.\fItoolset\fP" where \fItoolset\fP is
	    //| the abbreviated tool identifier used in the
	    //| '-t' option.
	    inferMakefileFilename = 1;
	    break;

	case 'q':
	    //|@-q option@
	    //|.IP "-q \fIsname\fP"
	    //| Display the library unit that corresponds
	    //| to the specified stamp filename.
	    //| The stamp filename must be specified
	    //| without the directory path
	    //| and is case sensitive.
	    //| "?unknown unit?" is printed when no unit
	    //| corresponds to the specified stamp filename.
	    //| There can be more than one -q option specified.
	    //| The makefile is still produced.
	    //|.RS
	    //|.LP
	    //| Example: vmk -q ALKJH78H.G43 -o /dev/null *.vhd
	    //|.RE
	    queryNames.insert(optarg, "?unknown unit?");
	    queries = 1;
	    break;

	case 'Q':
	    conseqFilename = optarg;
	    break;

	case 'r':
	    //|@-r option@
	    //|.IP "-r \fIfname\fP"
	    //| Read the specified rc file
	    //| after the default rc files.
	{
	    rcFile cmdline(NULL, optarg, workLib);
	}
	break;

	case 'S':
	    //|@-S option@
	    //|.IP -S \fIsuffix\fP
	    //| Append the specified suffix to the name of the
	    //| stamp file subdirectory (16 characters max).
	    //| Useful when using the same toolset and source tree
	    //| from different platforms.
	    stampDirSuffix = optarg;
	    break;

	case 't':
	    //|@-t option@
	    //|.IP "-t \fItoolset\fP"
	    //| Deduce dependencies and use analysis commands
	    //| for the specified toolset.
	    //| @(stamp directory name)@
	    //| @(supported toolsets (short))@
	    if (ToolSet::select(optarg)) {
		fprintf(stderr, "Unknown toolset: \"%s\".\n", optarg);
		printUsage = 1;
	    } else {
                toolname = optarg;
            }
	    break;

	case 'T':
	    //|@-T option@
	    //|.IP "-T"
	    //| All architectures and configurations can be
	    //| top-level units.
	    //| Produce a simulation target for all architectures
	    //| and configurations.
	    allTops = 1;
	    break;

	case 'u':
	    config_to_config = 1;
	    break;

	case 'v':
	    //|@-v option@
	    //|.IP -v
	    //| Display version number and licensing
	    //| information only.
	    //| The makefile is not produced.
	    showVersionOnly = 1;
	    break;

	case 'V':
	    inferVlog = 1;
	    break;

	case 'w':
	    //|@-w option@
	    //|.IP "-w \fIlibrary\fP"
	    //| Declare the logical library to be
	    //| another name for the WORK library.
	{
	    // Make sure library is in UPPERCASE
	    char libName[256];
	    char *t = libName;
	    for (const char *p = optarg; *p != '\0'; p++) {
		*t++ = (islower(*p)) ? toupper(*p) : *p;
	    }
	    *t = '\0';
	    workLib->addAlias(libName);
	}
	break;

	default:
	    printUsage = 1;
	}
    }

    if (listToolsets) {
	ToolSet::printToolSets(stderr, toolname);

	return -1;
    }

    if (printUsage) {
	//|@usage@
	//| vmk [options] {filename}

		//|@options@
	fprintf(stderr, "Usage: %s [options] filenames\n", argv[0]);
	fprintf(stderr, "Options:\n");
	//|@(-b option)@
	fprintf(stderr, "    -a             Use 'for all:...' when generating configuration units\n");
	fprintf(stderr, "    -b soft|hard   Use soft or hard configuration bindings\n");
	//|@(-c option)@
	fprintf(stderr, "    -C [L.]E+A     Generate configuration unit\n");
	fprintf(stderr, "    -d             Warn about open default configation\n");
	fprintf(stderr, "    -D             Store stamp name directory in 'StmpDict.vmk'\n");
	fprintf(stderr, "    -f fname       List of VHDL source files\n");
	fprintf(stderr, "    -F fname       List of VHDL libraries and source files. Implies -l.\n");
	//|@(-h option)@
	fprintf(stderr, "    -h             Display this help information.\n");
	//|@(-H option)@
	fprintf(stderr, "    -H             Display defined toolsets\n");
	//|@(-l option)@
	fprintf(stderr, "    -l lib|all     Add library to makefile\n");
	//|@(-L option)@
	fprintf(stderr, "    -L             Use short timestamp filenames\n");
	//|@(-m option)@
	fprintf(stderr, "    -m             Show library mappings with file pattern only.\n");
	//|@(-o option)@
	fprintf(stderr, "    -M             Show library mappings with filenames only.\n");
	fprintf(stderr, "    -n             No simulation targets in makefile.\n");
	fprintf(stderr, "    -N             Do not generate the makefile.\n");
	fprintf(stderr, "    -o fname       Write output in fname (stdout by default).\n");
	//|@(-O option)@
	fprintf(stderr, "    -O             Write makefile in \"Makefile.<toolset>\".\n");
	//|@(-q option)@
	fprintf(stderr, "    -q sname       Display library unit corresponding to specified stampname.\n");
	fprintf(stderr, "    -Q fname       Generate consequence makefile in specified file.\n");
	fprintf(stderr, "    -r rcfile      Load specified rc file.\n");
	//|@(-s option)@
	//|@(-t option)@
	fprintf(stderr, "    -t toolset     Write makefile for specified toolset.\n");
	fprintf(stderr, "                   Use -H option for list of supported toolsets\n");
	//|@(-T option)@
	fprintf(stderr, "    -T             All archs and confs can be top units.\n");
	//|@(-v option)@
	fprintf(stderr, "    -u             Configure to configuration units\n");
	fprintf(stderr, "    -v             Display version and licensing information only.\n");
	fprintf(stderr, "    -V             Assume unknown references are Verilog modules.\n");
	//|@(-w option)@
	fprintf(stderr, "    -w library     Make 'library' a synonym of 'WORK'\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "http://sourceforge.net/projects/vmk\n");

	return -1;
    }

    if (showVersionOnly) {
	return -1;
    }
    fprintf(stderr, "\n\n");

    if (multiLibrary) {
        // You can't specify filenames on the command line
        // or via the -f option
        // if you use the -l (multi-lib makefile) option
        if (minusf || optind < argc) {
            fprintf(stderr, "ERROR: Cannot specify filenames on the command line\n");
            fprintf(stderr, "       or with the -f option when using the -l option.\n");
            exit(-1);
        }
        if (stampDirPattern == NULL) stampDirPattern = ".stamps.%w.%t";
    } else {
        // We only use the default (WORK) library
        workLib->make();
        libraries.insert("WORK", workLib);
        LibraryAliasIter scanAliases(*workLib);
        for (scanAliases.reset(); scanAliases.key(); ++scanAliases) {
            // We may replace previously defined libraries but that's OK
            libraries.replace(scanAliases.key(), workLib);
        }

        if (stampDirPattern == NULL) stampDirPattern = ".stamps.%t";
    }

    for (int i = optind; i < argc; i++) {

#ifdef MSDOS
	// MS-DOS does not do filename globbing like C-sh
	// and only allows wildcards on the filename itself
	char filename[256];
	struct find_t glob;
	if (_dos_findfirst(argv[i], 0, &glob)) continue;

	strcpy(filename, argv[i]);
	char *tail = strrchr(filename, '\\');
	if (tail++ == NULL) tail = filename;
	do {
	    // Append the globbed name to the leading
	    // directory name, converting to lowercase,
	    // to make it easier for UNIX-targetted makefiles.
	    char* t = tail;
	    for (char* f = glob.name; *f != '\0'; f++) {
		*t++ = tolower(*f);
	    }
	    *t = '\0';
#else
	    const char* filename = argv[i];
#endif
	    SourceFile* file = new SourceFile(filename);
	    workLib->addFile(file);
#ifdef MSDOS
	} while (! _dos_findnext(&glob));
#endif
    }

    //
    // Find all source files that match the specified pattern
    // for all libraries included in the makefile
    // unless the -F option was used, in which case
    // the source files will be explicitely listed
    //
    
    LibraryHashTableIter scanLibs(&libraries);
    if (!minusF) {
      for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        if (!scanLibs.entry()->inMakefile() || scanLibs.entry()->getPattern() == NULL) continue;
	
        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	if (debugLevel > 1) {
	  printf("Locating source files for library %s:\n", scanLibs.entry()->getName());
        }

        // Use the built-in echo command in /bin/csh to glob patterns
        // Can't use sh 'coz it echoes the pattern itself when no match.
        char echo[4096];
        sprintf(echo, "/bin/csh -c 'echo ");
        char* start = echo + strlen(echo);
    
        const char* p;
        const char* q;
        // The pattern is a blank-separated list of shell patterns
        for (p = scanLibs.entry()->getPattern(); *p != '\0'; ) {
	  // Skip leading blanks
	  while (isspace(*p) && *p != '\0') p++;
	  // No patterns left?
	  if (*p == '\0') break;

          // If the pattern does not start with a '/'
          // (i.e. is relative), prepend the library
          // path
          char* append = start;
          if (*p != '/') {
              strcpy(append, scanLibs.entry()->getPath());
              strcat(append, "/");
              append += strlen(append);
          }

	  // Locate the end of the pattern
	  for (q = p; !isspace(*q) && *q != '\0'; q++);
	  char save = *q;
	  strncpy(append, p, q-p);

	  // Let the shell expand the pattern
	  strcpy(append + (q-p), "' 2>/dev/null");
	  if (debugLevel > 2) {
	    printf("Executing command %s\n", echo);
	  }
	  FILE* shell = popen(echo, "r");
	  if (shell == NULL) {
	    fprintf(stderr, "ERROR: Cannot execute \"%s\".\n",
		    echo);
	    exit(-1);
	  }
	  // What comes out is a blank-separated list of expanded filenames
	  char c;
	  char fname[1024];
	  char* f = fname;
	  while ((c = fgetc(shell)) != EOF) {
                
	    // Skip leading blanks
	    if (f == fname && isspace(c)) {
	      continue;
	    }

	    // Blanks anywhere else terminate the filename
	    if (isspace(c)) {
	      *f = '\0';
	      if (debugLevel > 2) {
		printf("Found file %s\n", fname);
	      }
	      SourceFile* file = new SourceFile(fname);
	      scanLibs.entry()->addFile(file);
	      f = fname;
	      continue;
	    }
                
	    // Any other character is part of the filename
	    *f++ = c;
	  }
	  pclose(shell);

	  // Look for the next pattern
	  p = q;
        }
      }
    }


    if (showMappingsOnly) {
	//|@print library mappings@
	//| Print the list of known libraries and their mapping
	//| as defined in the rc files that were loaded.
	LibraryHashTableIter scanLibs(&libraries);
	for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
            // Skip alias entries
            if (strcmp(scanLibs.key(), scanLibs.entry()->getName()) != 0) continue;
            
	    printf("%c %s (aliases:", (scanLibs.entry()->inMakefile()) ? '*' : ' ',
                   scanLibs.key());
	    //| Also print the list of alias library names
	    LibraryAliasIter scanAliases(*scanLibs.entry());
	    for (scanAliases.reset(); scanAliases.key(); ++scanAliases) {
		printf(" %s", scanAliases.key());
	    }
            const char* pattern = scanLibs.entry()->getPattern();
	    printf(")\n     %s %s\n", scanLibs.entry()->getPath(),
		   (pattern == NULL) ? "<command line>" : pattern);

            if (showMappingsOnly < 0) {
                printf("     Files:\n");
                SourceFileIter scanFiles(*scanLibs.entry());
                for (scanFiles.reset(); scanFiles(); ++scanFiles) {
                    printf("        %s\n", scanFiles()->getName());
                }
            }
	}
	//| The makefile is not produced.
	return 0;
    }

    //
    // Parse the source files of all libraries included
    // in the makefile
    //
    for (scanLibs.reset(); scanLibs.key(); ++scanLibs) {
        if (!scanLibs.entry()->inMakefile()) continue;

        // Skip aliases
        if (strcmp(scanLibs.entry()->getName(), scanLibs.key()) != 0) continue;
        
	if (debugLevel > 1) {
            printf("Parsing source files for library %s:\n",
                   scanLibs.entry()->getName());
        }

	SourceFileIter scanFiles(*scanLibs.entry());
	for (scanFiles.reset(); scanFiles(); ++scanFiles) {
	    if (debugLevel > 1) {
		printf("Parsing %s:\n", scanFiles()->getName());
	    }
	    VHDLparser parser(scanFiles(), scanLibs.entry());
	    LibraryUnit* unit;
	    unit = parser.nextUnit();
	    if (unit == NULL) {
		fprintf(stderr, "WARNING: No library units found in %s\n",
			scanFiles()->getName());
	    } else {
		if (!isDuplicate(unit, scanLibs.entry(), scanFiles())) {
		    scanFiles()->addUnit(unit);
		    scanLibs.entry()->addUnit(unit);
		}
	    }
	    while ((unit = parser.nextUnit()) != NULL) {
		if (!isDuplicate(unit, scanLibs.entry(), scanFiles())) {
		    scanFiles()->addUnit(unit);
		    scanLibs.entry()->addUnit(unit);
		}
	    }
	}
    }

    if (inferMakefileFilename) {
        const char* tool = ToolSet::getShortName();
        if (tool == NULL) {
            // User-defined toolset
            makefileFilename = "Makefile";
        } else {
            static char bfr[64];
            sprintf(bfr, "Makefile.%s", tool);
            makefileFilename = bfr;
        }
    }

    // Generate the dependency or consequence makefiles
    MakeFile makefile(makefileFilename, &libraries);
    if (conseqFilename != NULL) {
        Consequence makefile(conseqFilename, &libraries);
    }

    // Print the queried information
    if (queries) {
	fprintf(stderr, "\n\n");
	StringHashTableIter scanQueries(&queryNames);
	for (scanQueries.reset(); scanQueries.key(); ++scanQueries) {
	    fprintf(stderr, "Stamp file %s corresponds to %s\n", scanQueries.key(),
		    scanQueries.entry());
	}
    }

    return exitCode;
}


//
// Parse a list of source files to be parsed later
//
static void
parseListOfFile(const char* filename, Library* lib)
{
    FILE* fp;
    char buffer[1024];
    
    if ((fp = fopen(filename, "r")) == NULL) {
	fprintf(stderr, "ERROR: Cannot open \"%s\" for reading: ", filename);
	perror("");
        exitCode = -1;
	return;
    }
    
    // Parse each line
    int line = 0;
    for (char c = fgetc(fp); c != EOF; c = fgetc(fp)) {
	line++;
	
	// Skip leading blanks
	while (isspace(c) && c != EOF) c = fgetc(fp);
	
	char* p = buffer;
	
	// Skip comments
	if (c == '#') {
	    while (c != '\n' && c != EOF) {
		*p++ = c;
		c = fgetc(fp);
	    }
	    *p = '\0';
	    
	    // Is it a #include directive?
	    if (strncmp(buffer, "#include", 8) == 0) {
		// #include ["]filename["]
		char* start = buffer + 8;
		while (isspace(*start) && *start != '\0') start++;
		if (*start == '\0') {
		    fprintf(stderr,
			    "ERROR: Include file name missing in \"%s\", line %d\n",
			    filename, line);
                    exitCode = -1;
		    return;
		}
		if (*start == '"') start++;
		char* end = start;
		while (!isspace(*end) && *end != '\0') end++;
		if (*(end-1) == '"') *--end = '\0';
		parseListOfFile(strdup(relocate(filename, expand_env(start))),
				lib);
	    }
	    continue;
	}
	
	// Grab the first token as a pathname
	p = buffer;
	while (!isspace(c) && c != EOF) {
	    *p++ = c;
	    c = fgetc(fp);
	}
	*p = '\0';
	lib->addFile(new SourceFile(relocate(filename,
					     expand_env(buffer))));
    }
    
    fclose(fp);
}


//
// Parse a list of libraries and source files to be parsed later
//
static void
parseListOfLibFile(const char* filename)
{
    FILE* fp;
    char buffer[1024];

    if (strcmp(filename, "-") == 0) fp = stdin;
    else if ((fp = fopen(filename, "r")) == NULL) {
	fprintf(stderr, "ERROR: Cannot open \"%s\" for reading: ", filename);
	perror("");
        exitCode = -1;
	return;
    }
    
    // Parse each line
    int line = 0;
    for (char c = fgetc(fp); c != EOF; c = fgetc(fp)) {
	line++;
	
	// Skip leading blanks
	while (isspace(c) && c != EOF) c = fgetc(fp);
	
	char* p = buffer;
	
	// Skip any line that does not start with [a-zA-Z]
        // i.e. a valie library name
	if (!(('A' <= c && c <= 'Z') || ('a' <= c && c <= 'z'))) {
	    while (c != '\n' && c != EOF) {
		c = fgetc(fp);
	    }
            continue;
        }
	
	// Grab the first token as an (UPPERCASE) library name
	p = buffer;
	while (!isspace(c) && c != EOF) {
	    *p++ = (islower(c)) ? toupper(c) : c;
	    c = fgetc(fp);
	}
	*p = '\0';

        // Does the library already exist?
        Library* lib = libraries.lookup(buffer);
        if (lib == NULL) {
            // Create one if needed
            lib = new Library(buffer, ".", "");
            libraries.replace(buffer, lib);
        }
        lib->make();

	// Skip separating blanks
	while (isspace(c) && c != EOF) c = fgetc(fp);
        if (c == EOF) {
            fprintf(stderr, "ERROR: %s, line %d: missing filename\n",
                    filename, line);
            exitCode = -1;
        }
	
	// Grab the second token as a file name
	p = buffer;
	while (!isspace(c) && c != EOF) {
	    *p++ = c;
	    c = fgetc(fp);
	}
	*p = '\0';

	SourceFile* file = new SourceFile(relocate(filename,
					     expand_env(buffer)));
	lib->addFile(file);

	// If there is more stuff on the line,
	// they are command-line options
	while (isspace(c) && c != EOF && c != '\n') {
	    c = fgetc(fp);
	}
	// More stuff?
	if (!isspace(c)) {
	    strcpy(buffer, "compile args ");
	    p = buffer + strlen(buffer);
	    while (c != '\n' && c != EOF) {
		*p++ = c;
		c = fgetc(fp);
	    }
	    *p = '\0';
	    file->addDirective(buffer);
	}
    }
    
    fclose(fp);
}


//
// Lookup a unit in the previously parsed units to make sure
// there are no duplications
//
static int
isDuplicate(LibraryUnit* unit,
	    Library*     lib,
	    SourceFile* stop)
{
    SourceFileIter scanFiles(*lib);
    for (scanFiles.reset(); scanFiles(); ++scanFiles) {
	
	if (scanFiles() == stop) break;
	
	SourceFileUnitIter scanUnits(*scanFiles());
	for (scanUnits.reset(); scanUnits(); ++scanUnits) {
	    
	    if (scanUnits()->getType() != unit->getType()) {
		continue;
	    }
	    
	    switch (unit->getType()) {
	    case LibraryUnit::Package:
	    case LibraryUnit::PackageBody:
	    case LibraryUnit::Entity:
	    case LibraryUnit::Configuration:
		if (strcmp(unit->getName(), scanUnits()->getName()) == 0) {
		    fprintf(stderr, "ERROR: duplicate unit in library %s: ",
			    lib->getName());
		    unit->printDesc(stderr);
		    fprintf(stderr, "\n");
                    exitCode = -1;
		    return 0;
		}
		break;
	    case LibraryUnit::Architecture:
		if (strcmp(unit->getName(), scanUnits()->getName()) == 0 &&
		    strcmp(unit->getParentName(), scanUnits()->getParentName()) == 0) {
		    fprintf(stderr, "ERROR: duplicate unit in library %s: ",
			    lib->getName());
		    unit->printDesc(stderr);
		    fprintf(stderr, "\n");
                    exitCode = -1;
		    return 0;
		}
		break;
	    }
	}
    }
    
    return 0;
}

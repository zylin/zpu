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

//|@rc files@
//| Configuration (i.e. \fIrc\fP)files are used to provide run-time
//| information to \fI@(name)@\fP.
//| They are read in increasing precedence order
//| i.e. setting in a file will override any previous (or default) setting.
//| @(default rc files loaded)@


#include <string.h>
#include <ctype.h>

#include "relocate.h"
#include "envexp.h"

#include "globals.hxx"
#include "rcFile.hxx"
#include "ToolSet.hxx"
#include "VHDLprse.hxx"

//
// Read an RC file
//
rcFile::rcFile(const char* dirName,
	       const char* fileName,
               Library*    workLib,
	       unsigned    mustBeThere)
    : lineNo(0)
{
    if (dirName == NULL) strcpy(fullName, fileName);
#ifdef MSDOS
    else {
        // Must check if dirName already has a trailing '\'
        // because the HOME directory is often "C:\"
        if (dirName[strlen(dirName) - 1] == '\\') {
            sprintf(fullName, "%s%s", dirName, fileName);
        } else {
            sprintf(fullName, "%s\\%s", dirName, fileName);
        }
    }
#else
    else sprintf(fullName, "%s/%s", dirName, fileName);
#endif
    if (debugLevel > 0) {
        printf("Reading RC file \"%s\"\n", fullName);
    }

    rc = fopen(fullName, "r");
    if (rc == NULL) {
        if (mustBeThere) {
            fprintf(stderr, "Error: cannot open \"%s\" for reading:",
                    fullName);
            perror("");
        }
        return;
    }

    while (GetLine()) {

	if (strcmp(argv[0], "vmkrc") == 0) {

            // vmkrc /path/to/vmkrc/file
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid vmkrc directive\n",
			fullName, lineNo);
                continue;
	    }
	    
            rcFile(NULL, relocate(fullName, expand_env(argv[1])), workLib, 1);

        } else if (strcmp(argv[0], "toolset") == 0) {

            // toolset vsystem|vss|leapfrog|vantage|...
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid toolset directive\n",
			fullName, lineNo);
                continue;
	    }
	    
            if (ToolSet::select(argv[1])) {
                fprintf(stderr, "ERROR: %s, line %d: Unknown toolset \"%s\"\n",
                        fullName, lineNo, argv[1]);
            }

        } else if (strcmp(argv[0], "tooldef") == 0) {

            // tooldef fullname abbrev descrip soft|hard \
            //     single-lib-analysis-command \
            //     [single-lib-vlog-command] \
            //     [single-lib-arch-elab-cmd] \
            //     [single-lib-conf-elab-cmd] \
            //     single-lib-arch-sim-cmd \
            //     single-lib-conf-sim-cmd \
            //     multi-lib-analysis-command \
            //     [multi-lib-vlog-command] \
            //     [multi-lib-arch-elab-cmd] \
            //     [multi-lib-conf-elab-cmd] \
            //     multi-lib-arch-sim-cmd \
            //     multi-lib-conf-sim-cmd
	    if (argc != 15 && argc != 11 &&
                argc != 17 && argc != 13) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid tooldef directive (%d)\n",
			fullName, lineNo, argc);
                continue;
	    }

            unsigned HardOrSoft;
            if (strcmp(argv[4], "soft") == 0) {
                HardOrSoft = ToolSet::Soft;
            } else if (strcmp(argv[4], "hard") == 0) {
                HardOrSoft = ToolSet::Hard;
            } else {
                fprintf(stderr, "ERROR: %s, line %d: Unknown binding \"%s\"\n",
                        fullName, lineNo, argv[4]);
                continue;
            }

            if (argc == 11) {
                ToolSet::define(
                    strdup(argv[1]), strdup(argv[2]),
                    strdup(argv[3]), HardOrSoft,
                    new CommandSpec(strdup(argv[5]), NULL,
                                    NULL, NULL,
                                    strdup(argv[6]), strdup(argv[7])),
                    new CommandSpec(strdup(argv[8]), NULL,
                                    NULL, NULL,
                                    strdup(argv[9]), strdup(argv[10])));
            } else if (argc == 13) {
                ToolSet::define(
                    strdup(argv[1]), strdup(argv[2]),
                    strdup(argv[3]), HardOrSoft,
                    new CommandSpec(strdup(argv[5]), strdup(argv[6]),
                                    NULL, NULL,
                                    strdup(argv[7]), strdup(argv[8])),
                    new CommandSpec(strdup(argv[9]), strdup(argv[10]),
                                    NULL, NULL,
                                    strdup(argv[11]), strdup(argv[12])));
            } else if (argc == 15) {
                ToolSet::define(
                    strdup(argv[1]), strdup(argv[2]),
                    strdup(argv[3]), HardOrSoft,
                    new CommandSpec(strdup(argv[5]), NULL,
                                    strdup(argv[6]), strdup(argv[7]),
                                    strdup(argv[8]), strdup(argv[9])),
                    new CommandSpec(strdup(argv[10]), NULL,
                                    strdup(argv[11]), strdup(argv[12]),
                                    strdup(argv[13]), strdup(argv[14])));
            } else {
                ToolSet::define(
                    strdup(argv[1]), strdup(argv[2]),
                    strdup(argv[3]), HardOrSoft,
                    new CommandSpec(strdup(argv[5]), strdup(argv[6]),
                                    strdup(argv[7]), strdup(argv[8]),
                                    strdup(argv[9]), strdup(argv[10])),
                    new CommandSpec(strdup(argv[11]), strdup(argv[12]),
                                    strdup(argv[13]), strdup(argv[14]),
                                    strdup(argv[15]), strdup(argv[16])));
            }                

        } else if (strcmp(argv[0], "preprocess") == 0) {

            // preprocess "command to pre-process"
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid preprocess directive\n",
			fullName, lineNo);
                continue;
	    }
	    
            preprocess = strdup(argv[1]);

        } else if (strcmp(argv[0], "analyze") == 0) {

            // analyze "command to analyze"
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid analyze directive\n",
			fullName, lineNo);
                continue;
	    }

            ToolSet::setAnalyzeCommand(strdup(argv[1]));

        } else if (strcmp(argv[0], "verilog") == 0) {

            // verilog "command to verilog"
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid verilog directive\n",
			fullName, lineNo);
                continue;
	    }

            ToolSet::setVlogCommand(strdup(argv[1]));

        } else if (strcmp(argv[0], "elaborate") == 0) {

            // elaborate [architecture] "command to elaborate"
            // elaborate [configuration] "command to elaborate"
	    if (argc != 2 && argc != 3) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid elaborate directive\n",
			fullName, lineNo);
                continue;
	    }

            if (argc == 2) {
                ToolSet::setElaborateCommand(LibraryUnit::Architecture,
                                             strdup(argv[1]));
                ToolSet::setElaborateCommand(LibraryUnit::Configuration,
                                             strdup(argv[1]));
            } else {
                if (strcmp(argv[1], "architecture") == 0) {
                    ToolSet::setElaborateCommand(LibraryUnit::Architecture,
                                                 strdup(argv[2]));
                } else if (strcmp(argv[1], "configuration") == 0) {
                    ToolSet::setElaborateCommand(LibraryUnit::Configuration,
                                                 strdup(argv[2]));
                }
            }

        } else if (strcmp(argv[0], "simulate") == 0) {

            // simulate [architecture] "command to simulate"
            // simulate [configuration] "command to simulate"
	    if (argc != 2 && argc != 3) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid simulate directive\n",
			fullName, lineNo);
                continue;
	    }

            if (argc == 2) {
                ToolSet::setSimulateCommand(LibraryUnit::Architecture,
                                            strdup(argv[1]));
                ToolSet::setSimulateCommand(LibraryUnit::Configuration,
                                            strdup(argv[1]));
            } else {
                if (strcmp(argv[1], "architecture") == 0) {
                    ToolSet::setSimulateCommand(LibraryUnit::Architecture,
                                                strdup(argv[2]));
                } else if (strcmp(argv[1], "configuration") == 0) {
                    ToolSet::setSimulateCommand(LibraryUnit::Configuration,
                                                strdup(argv[2]));
                }
            }

        } else if (strcmp(argv[0], "header") == 0) {

            // header /path/to/makefile/header
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid header directive\n",
			fullName, lineNo);
                continue;
	    }

            headerFile = strdup(relocate(fullName, expand_env(argv[1])));

        } else if (strcmp(argv[0], "include1") == 0) {

            // include1 /path/to/makefile/include1
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid include1 directive\n",
			fullName, lineNo);
                continue;
	    }

            includeFile[0] = strdup(relocate(fullName, expand_env(argv[1])));

        } else if (strcmp(argv[0], "include2") == 0) {

            // include2 /path/to/makefile/include2
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid include2 directive\n",
			fullName, lineNo);
                continue;
	    }

            includeFile[1] = strdup(relocate(fullName, expand_env(argv[1])));

        } else if (strcmp(argv[0], "include3") == 0) {

            // include3 /path/to/makefile/include3
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid include3 directive\n",
			fullName, lineNo);
                continue;
	    }

            includeFile[2] = strdup(relocate(fullName, expand_env(argv[1])));

        } else if (strcmp(argv[0], "library") == 0) {

            // library libname /path/to/library/files [pattern]
	    if (argc != 3 && argc != 4) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid library directive\n",
			fullName, lineNo);
                continue;
	    }

            char* key = strdup(argv[1]);
            // Translate library name to UPPERCASE
            for (char* p = key; *p != '\0'; p++) {
                *p = (islower(*p)) ? toupper(*p) : *p;
            }

            char* path = strdup(relocate(fullName, expand_env(argv[2])));
            // A pattern may follow, assume "*.vhd" otherwise
            Library* lib = new Library(key, path, (argc == 4) ? argv[3] : "*.vhd");
            if (debugLevel > 2) {
                printf("Defining library %s\n", key);
            }
            if ((lib = libraries.replace(key, lib)) != NULL) {
                fprintf(stderr, "ERROR: %s, Line %d: Library %s already defined.\n",
                        fullName, lineNo, key);
            }
            delete [] path;

        } else if (strcmp(argv[0], "work") == 0) {

            // work libname
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid work directive\n",
			fullName, lineNo);
                continue;
	    }

            // Make sure library is in UPPERCASE
            for (char *p = argv[1]; *p != '\0'; p++) {
                if (islower(*p)) *p = toupper(*p);
            }

            workLib->addAlias(argv[1]);

        } else if (strcmp(argv[0], "alias") == 0) {

            // alias aliasname libname
	    if (argc != 3) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid alias directive\n",
			fullName, lineNo);
                continue;
	    }

            // Make sure alias is in UPPERCASE
            for (char *p = argv[1]; *p != '\0'; p++) {
                if (islower(*p)) *p = toupper(*p);
            }
            char* alias = strdup(argv[1]);

            // Make sure library is in UPPERCASE
            for (char *p = argv[2]; *p != '\0'; p++) {
                if (islower(*p)) *p = toupper(*p);
            }

            Library* lib = libraries.lookup(argv[2]);
            if (lib == NULL) {
                fprintf(stderr, "ERROR: %s, Line %d: Unknown library \"%s\"\n",
                        fullName, lineNo, argv[2]);
            } else {
                lib->addAlias(alias);
                if (debugLevel > 2) {
                    printf("Defining alias %s to library %s\n", alias, argv[2]);
                } 
               if (libraries.replace(argv[1], lib) != NULL) {
                    fprintf(stderr,
                            "ERROR: %s, Line %d: Library %s already defined.\n",
                            fullName, lineNo, alias);
                }

            }

        } else if (strcmp(argv[0], "bindings") == 0) {

            // binding soft | hard
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid binding directive\n",
			fullName, lineNo);
                continue;
	    }

            if (strcmp(argv[1], "soft") == 0) {
                ToolSet::setBindings(ToolSet::Soft);
            } else if (strcmp(argv[1], "hard") == 0) {
                ToolSet::setBindings(ToolSet::Hard);
            } else {
                fprintf(stderr, "ERROR: %s, line %d: Unknown binding \"%s\"\n",
                        fullName, lineNo, argv[1]);
            }

        } else if (strcmp(argv[0], "xrefieee") == 0) {

            // xrefieee on|off
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid xrefieee directive\n",
			fullName, lineNo);
                continue;
	    }

            if (strcmp(argv[1], "on") == 0) {
                useIEEE = 1;
            } else if (strcmp(argv[1], "off") == 0) {
                useIEEE = 0;
            } else {
                fprintf(stderr, "ERROR: %s, line %d: Invalid xrefieee directive: \"%s\". Expected \"on\" or \"off\".\n",
                        fullName, lineNo, argv[1]);
            }


        } else if (strcmp(argv[0], "longnames") == 0) {

            // longnames
	    if (argc != 1) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid longnames directive\n",
			fullName, lineNo);
                continue;
	    }

            useLongNames = 1;

        } else if (strcmp(argv[0], "shortnames") == 0) {

            // shortnames
	    if (argc != 1) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid shortnames directive\n",
			fullName, lineNo);
                continue;
	    }

            useLongNames = 0;

        } else if (strcmp(argv[0], "stampdir") == 0) {

            // stampdir pattern
	    if (argc != 2) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid stampdir directive\n",
			fullName, lineNo);
                continue;
	    }

            stampDirPattern = strdup(relocate(fullName, expand_env(argv[1])));

        } else if (strcmp(argv[0], "configfile") == 0) {

            // configfile filepattern [unitpattern]
	    if (argc != 2 && argc != 3) {
		fprintf(stderr, "ERROR: file %s, line %d: Invalid configfile directive\n",
			fullName, lineNo);
                continue;
	    }

            genConfFilePattern = strdup(relocate(fullName, argv[1]));
            if (argc == 3) {
                genConfUnitPattern = strdup(relocate(fullName, argv[2]));
            }

        } else {
            fprintf(stderr, "WARNING: file %s, line %d: Unknown directive %s. Ignored.\n",
                    fullName, lineNo, argv[0]);
        }
    }

    fclose(rc);
}


//
// Destroy an rc file object
//
rcFile::~rcFile()
{
}


//
// IO utility functions
//
int
rcFile::GetLine()
{
    static char line[1024];
    char*       p;
    char        c;

    argc = 0;
    p = line;

    // Skip leading blanks in the file
    while ((c = fgetc(rc)) != EOF && isspace(c)) {
        if (c == '\n') lineNo++;
    }

    while (c != EOF && (c != '\n' || argc == 0)) {
        int quoted = 0;

        // Did we just skip a blank line?
        if (c == '\n') {
            lineNo++;
            if (argc > 0) break;
        };
        
        /* Skip leading blanks */
        while (isspace(c) && c != EOF) {
            c = fgetc(rc);
            if (c == '\n') {
                lineNo++;
                if (argc > 0) break;
            };
        }
        if (c == EOF) break;

        argv[argc] = p;

        /* Read the next token */
        while (c != EOF && (!isspace(c) || quoted)) {
            switch (c) {
            case '#':
                /* Comment */
                quoted = 0;
                while (c != '\n' && c != EOF) c = fgetc(rc);
                ungetc(c, rc);
                break;
            case '"':
                /* Start/end quote */
                quoted = !quoted;
                break;
            case '\\':
                /* Next character is escaped
                 * Except if the next char is a newline, which
                 * indicates a line continuation */
                c = fgetc(rc);
                if (c != EOF && c != '\n') *p++ = c;
                break;
            case ' ':
            case '\t':
            case '\r':
            case '\f':
            case '\n':
                /* Blanks */
                if (quoted) *p++ = c;
                break;
            default:
                /* Normal character */
                *p++ = c;
                break;
            }
            c = fgetc(rc);
        }
        if (argv[argc] == p) continue;
        argc++;
        *p++ = '\0';
    }
    argv[argc] = NULL;
    lineNo++;
    
    return argc;
}

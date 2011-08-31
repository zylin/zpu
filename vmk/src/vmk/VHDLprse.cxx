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
// Simple minded VHDL parser class
//

#include <ctype.h>
#include <errno.h>
#ifdef HPUX
# include <sys/sigevent.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

inline char* strdup(const char* str)
{
    if (str == NULL) return NULL;

    char* copy = new char[strlen(str) + 1];
    if (copy == NULL) {
	fprintf(stderr, "OUT OF MEMORY!!!\n");
	abort();
    }
    return strcpy(copy, str);
}

inline const char* maybe_null(const char* str)
{
    return (str == NULL) ? "(null)": str;
}

#include "globals.hxx"
#include "ToolSet.hxx"
#include "VHDLprse.hxx"

//
// Global objects
//
LibraryHashTable libraries(13);

//
// Private objects and functions
//
static void parseComment(FILE*       fp,
			 SourceFile* file);


//
// VHDL tokens and reserved words
//
#define END_OF_FILE     0
#define ALL            -1
#define ARCHITECTURE   -2
#define BODY           -3
#define CONFIGURATION  -4
#define END            -5
#define ENTITY         -6
#define FOR            -7
#define PACKAGE        -8
#define PORT           -9
#define USE            -10
#define GENERIC        -11
#define MAP            -12
#define LIBRARY        -13
#define BEGIN          -14
#define COMPONENT      -15
#define IS             -16
#define GENERATE       -17
#define OPEN           -18
#define BLOCK          -19
#define IF             -20
#define STRING_LITERAL -98
#define IDENTIFIER     -99
// The index of the reserved word must correspond to the token value
// The last entry must be NULL
static char* reservedWord[22] = {
    "unused",
    "ALL",
    "ARCHITECTURE",
    "BODY",
    "CONFIGURATION",
    "END",
    "ENTITY",
    "FOR",
    "PACKAGE",
    "PORT",
    "USE",
    "GENERIC",
    "MAP",
    "LIBRARY",
    "BEGIN",
    "COMPONENT",
    "IS",
    "GENERATE",
    "OPEN",
    "BLOCK",
    "IF",
    NULL};

static DependencyList usedStuff;

static void destroyString(char* obj)
{
    delete [] obj;
}


//
// Class Dependency
//
Dependency::Dependency(int unitType,
		       const char* inLib,
		       const char* mainUnit,
		       const char* secUnit)
    : library(strdup(inLib)), parent(strdup(mainUnit)), child(strdup(secUnit)),
      type(unitType), unit(NULL)
{
    if (library == NULL) {
	library = new char [5];
	strcpy(library, "WORK");
    }
};

Dependency::~Dependency()
{
    delete [] library;
    delete [] parent;
    delete [] child;
};

void
Dependency::destroy(Dependency* obj)
{
    delete obj;
}

void
Dependency::setUnit(LibraryUnit* actualUnit)
{
    unit = actualUnit;
    if (actualUnit != NULL) type = actualUnit->getType();
}


void
Dependency::isLibDotAll()
{
    // A 'USE lib.all' was misinterpreted as USE 'pkg.all'
    delete [] library;
    library = parent;
    parent = NULL;
    type = LibraryUnit::LibraryAll;
}

void
Dependency::isPackDotItem()
{
    // A 'USE pack.item' was misinterpreted as USE 'lib.item'
    child = parent;
    parent = library;
    library = strdup("WORK");
    type = LibraryUnit::Package;
}


//
// Class CompConfig
//
CompConfig::CompConfig(const char* instLabel,
                       const char* compName,
                       int unitType,
                       const char* inLib,
                       const char* mainUnit,
                       const char* secUnit)
    : label(strdup(instLabel)), component(strdup(compName)),
      library(strdup(inLib)), parent(strdup(mainUnit)),
      child(strdup(secUnit)), type(unitType),
      unit(NULL)
{
}

CompConfig::~CompConfig()
{
    delete [] label;
    delete [] component;
    delete [] library;
    delete [] parent;
    delete [] child;
}

void
CompConfig::destroy(CompConfig* obj)
{
    delete obj;
}

void
CompConfig::setUnit(LibraryUnit* actualUnit)
{
    unit = actualUnit;
}


//
// Class Block
//
Block::Block(const char* blockName,
			 Block* inBlock,
			 LibraryUnit* inUnit)
    : name(strdup(blockName)), parentBlock(inBlock),
      parentUnit(inUnit), configs(), subBlocks()
{}

Block::~Block()
{
    delete [] name;
    configs.flush(CompConfig::destroy);
    subBlocks.flush(Block::destroy);
}

void
Block::destroy(Block* obj)
{
    delete obj;
}

const char*
Block::getName()
{
    return name;
}

Block*
Block::getBlock()
{
    return parentBlock;
}

LibraryUnit*
Block::getUnit()
{
    return parentUnit;
}

void
Block::print(FILE* fp,
	     unsigned level)
{
    char* prefix = new char[level*4 + 1];
    int i;
    for (i = 0; i < level*4+1; prefix[i++] = ' ');
    prefix[i] = '\0';
    
    fprintf(fp, "\t%sBlock %s:\n", prefix, name);
    fprintf(fp, "\t%sConfigurations:\n", prefix);
    CompConfigListIterator scanConfigs(&configs);
    for (scanConfigs.atHead(); scanConfigs(); ++scanConfigs) {
	fprintf(fp, "\t%s  %s:%s use %s %s.%s(%s)\n", prefix,
		scanConfigs()->labelName(),
		scanConfigs()->compName(),
		LibraryUnit::unitTypeImage(scanConfigs()->getType()),
		scanConfigs()->libName(),
		scanConfigs()->mainName(),
		maybe_null(scanConfigs()->secName()));
    }
    fprintf(fp, "\t%sSub-Blocks:\n", prefix);
    BlockListIterator scanBlocks(&subBlocks);
    for (scanBlocks.atHead(); scanBlocks(); ++scanBlocks) {

	scanBlocks()->print(fp, level + 1);
    }
}


//
// Class LibraryUnit
//
LibraryUnit::LibraryUnit(const char* unitName, int unitType,
			 SourceFile* inFile, Library* inLib,
			 const char* mainUnitName)
    : knownLibraries(), name(strdup(unitName)), type(unitType),
      parent(strdup(mainUnitName)), parentUnit(NULL), id(NULL),
      srcFile(inFile), lib(inLib), dependencies(), defaultConfs(),
      referenced(0), onLine(0)
{}

LibraryUnit::~LibraryUnit()
{
    delete [] name;
    delete [] parent;
    delete [] id;
    knownLibraries.flush(destroyString);
    dependencies.flush(Dependency::destroy);
    defaultConfs.flush(Dependency::destroy);
}

void
LibraryUnit::destroy(LibraryUnit* obj)
{
    delete obj;
}

unsigned
LibraryUnit::getType()
{
    return type;
}

const char*
LibraryUnit::getName()
{
    return name;
}

const char*
LibraryUnit::getId()
{
    return id;
}

void
LibraryUnit::setId(const char* newId)
{
    id = strdup(newId);
}

const char*
LibraryUnit::getParentName()
{
    return parent;
}

LibraryUnit*
LibraryUnit::getParent()
{
    return parentUnit;
}

void
LibraryUnit::setParent(LibraryUnit* newParent)
{
    parentUnit = newParent;
}

SourceFile*
LibraryUnit::getSourceFile()
{
    return srcFile;
}

Library*
LibraryUnit::getLibrary()
{
    return lib;
}

unsigned
LibraryUnit::isLibrary(const char* identifier)
{
    {
	if (strcmp(identifier, "WORK") == 0) return 1;
	if (strcmp(identifier, "STD") == 0) return 1;
	LibraryDeclListIterator scanLibraries(&knownLibraries);
	for (scanLibraries.reset(); scanLibraries(); ++scanLibraries) {
	    if (strcmp(scanLibraries(), identifier) == 0)
		return 1;
	}
    }
    return 0;
}

unsigned
LibraryUnit::isLoose()
{
    return !referenced;
}

void
LibraryUnit::isReferenced()
{
    referenced = 1;
}

unsigned
LibraryUnit::isOnLine(unsigned lineNumber,
		      unsigned update)
{
    if (onLine == lineNumber) return 1;
    if (update) onLine = lineNumber;
    return 0;
}

void
LibraryUnit::addDependency(Dependency* dep)
{
    dependencies.append(dep);
}

const char*
LibraryUnit::unitTypeImage(int type)
{
    switch(type) {
    case Unknown:       return "unknown";
    case LibraryAll:    return "library.all";
    case Package:       return "package";
    case PackageBody:   return "package body";
    case Entity:        return "entity";
    case Architecture:  return "architecture";
    case Configuration: return "configuration";
    }
    return "?internal error?";
}

void
LibraryUnit::printDesc(FILE *fp)
{
    fprintf(fp, "%s %s", unitTypeImage(type), name);
    if (parentUnit != NULL) {
	fprintf(fp, " of %s %s",
		unitTypeImage(parentUnit->type),
		parentUnit->name);
    } else if (parent != NULL) {
	fprintf(fp, " of %s", parent);
    }
}


void
LibraryUnit::print(FILE* fp)
{
    switch (type) {
    case Package:
	fprintf(fp, "Package %s:\n", name);
	break;
    case PackageBody:
	fprintf(fp, "Package Body %s:\n", name);
	break;
    case Entity:
	fprintf(fp, "Entity %s:\n", name);
	break;
    case Architecture:
	fprintf(fp, "Architecture %s of entity %s:\n",
		name, parent);
	break;
    case Configuration:
	fprintf(fp, "Configuration %s of entity %s:\n",
		name, parent);
	break;
    }

    fprintf(fp, "\tParent: ");
    if (parentUnit == NULL) fprintf(fp, "none\n");
    else fprintf(fp, "%s %s\n", unitTypeImage(parentUnit->type),
		 parentUnit->name);

    fprintf(fp, "\tTimestamp ID: \"%s\"\n", maybe_null(id));

    fprintf(fp, "\tKnown libraries:");
    LibraryDeclListIterator scanLibs(&knownLibraries);
    for (scanLibs.reset(); scanLibs(); ++scanLibs) {
	fprintf(fp, " %s", scanLibs());
    }
    fprintf(fp, "\n");

    fprintf(fp, "\tUsed packages:\n");
    DependencyListIterator scanPackages(&dependencies);
    for (scanPackages.atHead(); scanPackages(); ++scanPackages) {
	if (scanPackages()->getType() != Package) continue;
	fprintf(fp, "\t\t%s.%s\n", scanPackages()->libName(),
		scanPackages()->mainName());
    }

    fprintf(fp, "\tDepends on:\n");
    DependencyListIterator scanDepends(&dependencies);
    for (scanDepends.atHead(); scanDepends(); ++scanDepends) {
	if (scanDepends()->getType() == Package) continue;
	fprintf(fp, "\t\t%s %s.%s(%s)\n",
		LibraryUnit::unitTypeImage(scanDepends()->getType()),
		scanDepends()->libName(),
		scanDepends()->mainName(),
		(scanDepends()->secName() == NULL) ?
		"" : scanDepends()->secName());
    }

    fprintf(fp, "\tDefault configuration dependencies:\n");
    DependencyListIterator scanDefConfs(&defaultConfs);
    for (scanDefConfs.atHead(); scanDefConfs(); ++scanDefConfs) {
	fprintf(fp, "\t\tentity %s.%s\n", scanDefConfs()->libName(),
		scanDefConfs()->mainName());
    }
    
    if (type == LibraryUnit::Architecture) {
	Block* block = (class Architecture*) this;
	block->print(fp, 0);
    }

    fprintf(fp, "\n");
}


//
// SourceFile class
//

SourceFile::SourceFile(const char* fileName)
    : name(strdup(fileName)), units(), directives(),
      consequences()
{
}

SourceFile::~SourceFile()
{
    delete [] name;
    consequences.flush();
    directives.flush(destroyString);
    units.flush(LibraryUnit::destroy);
}

void
SourceFile::destroy(SourceFile* obj)
{
    delete obj;
}

const char*
SourceFile::getName()
{
    return name;
}

void
SourceFile::addUnit(LibraryUnit* unit)
{
    units.append(unit);
}

void
SourceFile::addDirective(const char* directive)
{
    directives.append(strcpy(new char [strlen(directive) + 1],
			     directive));
}

const char*
SourceFile::getDirective(const char* keyword)
{
    DirectiveListIterator scanDirectives(&directives);
    for (scanDirectives.reset(); scanDirectives();
	 ++scanDirectives) {
	if (strncmp(keyword, scanDirectives(),
		    strlen(keyword)) == 0) {

	    // Return significant portion of the directive
	    const char* p = scanDirectives() + strlen(keyword);
	    while (*p == ' ' || *p == '\t') p++;
	    return p;
	}
    }
    return NULL;
}

void
SourceFile::addConsequence(SourceFile* obj)
{
    // No consequences on itself
    if (obj == this) return;
    
    // First, check if this new consequence
    // is already known
    SourceFileListIterator scanFiles(&consequences);
    for (scanFiles.reset(); scanFiles(); ++scanFiles) {
        if (scanFiles() == obj) return;
    }

    consequences.append(obj);
}


//
// SourceFileUnitIter class
//

SourceFileUnitIter::SourceFileUnitIter(SourceFile& file)
    : LibraryUnitListIterator(&file.units)
{}

SourceFileUnitIter::~SourceFileUnitIter()
{}



//
// SourceFileConseqIter class
//

SourceFileConseqIter::SourceFileConseqIter(SourceFile& file)
    : SourceFileListIterator(&file.consequences)
{}

SourceFileConseqIter::~SourceFileConseqIter()
{}


//
// Library class
//

Library::Library(const char* libName, const char* path, const char* pat)
    : name(strdup(libName)), srcPath(strdup(path)), pattern(strdup(pat)),
      aliases(13), files(), units(), inMake(0)
{
}

Library::~Library()
{
    delete [] name;
    delete [] srcPath;
    delete [] pattern;
    files.flush(SourceFile::destroy);
}

const char*
Library::getName()
{
    return name;
}

const char*
Library::getPath()
{
    return srcPath;
}

const char*
Library::getPattern()
{
    return pattern;
}

void
Library::addAlias(const char* alias)
{
    aliases.insert(alias, name);
}

void
Library::addFile(SourceFile* file)
{
    files.append(file);
}

void
Library::addUnit(LibraryUnit* unit)
{
    units.append(unit);
}

int
Library::isLib(const char* nam)
{
    // Is it the library's real name?
    if (strcmp(nam, name) == 0) return 1;

  // Is it one of the aliases this library is known by?
    if (aliases.lookup(nam) != NULL) return 1;

    // That's does not appear to be me!
    return 0;
}

void
Library::make()
{
    inMake = 1;
}

int
Library::inMakefile()
{
    return inMake;
}


//
// SourceFileIter class
//

SourceFileIter::SourceFileIter(Library& lib)
    : SourceFileListIterator(&lib.files)
{}

SourceFileIter::~SourceFileIter()
{}


//
// LibraryUnitIter class
//

LibraryUnitIter::LibraryUnitIter(Library& lib)
    : LibraryUnitListIterator(&lib.units)
{}

LibraryUnitIter::~LibraryUnitIter()
{}


//
// LibraryAliasIter class
//

LibraryAliasIter::LibraryAliasIter(Library& lib)
    : StringHashTableIter(&lib.aliases)
{}

LibraryAliasIter::~LibraryAliasIter()
{}


//
// Class VHDLtokenizer
//

VHDLtokenizer::VHDLtokenizer(SourceFile* srcFile)
    : lineNo(1), last(0), current(0), tos(-1),
      file(srcFile)
{
    for (int i = 0; i < TOKENWINDOWSIZE; i++) {
	image[i] = &imageBuffer[i * 256];
	image[i][0] = '\0';
    }
    if (preprocess == NULL) {

	fp = fopen(srcFile->getName(), "r");
	if (fp == NULL) {
	    fprintf(stderr, "ERROR: %s: Cannot open file for reading ",
		    srcFile->getName());
	    perror("");
            exitCode = -1;
	}

    } else {

	// A preprocessing command has been defined

	// Replace '%f' in command string by filename
	// or append filename if no file marker
	char cmd[1024];
	char *c = cmd;
	unsigned marker_seen = 0;
	for (const char* p = preprocess; *p != '\0'; p++) {
	    if (*p == '%') {
		switch (*++p) {
		case '%':
		    *c++ = '%';
		    break;
		case 'f':
		    for (const char* f = srcFile->getName(); *f != '\0';) {
			*c++ = *f++;
		    }
		    marker_seen = 1;
		    break;
		default:
		    fprintf(stderr, "Unknown marker '%%%c' in preprocessor command\n", *p);
		    break;
		}
		continue;
	    }
	    *c++ = *p;
	}
	if (!marker_seen) strcpy(c, srcFile->getName());
	else *c = '\0';

	if (debugLevel > 0) {
	    printf("Preprocessing file %s: \"%s\"\n",
		   srcFile->getName(), cmd);
	}

	// Preprocess the source file
	fp = popen(cmd, "r");
	if (fp == NULL) {
	    fprintf(stderr, "ERROR: %s: Cannot preprocess file ",
		    srcFile->getName());
	    perror("");
            exitCode = -1;
	}

    }
}

VHDLtokenizer::~VHDLtokenizer()
{
    if (fp != NULL) {
	if (preprocess == NULL) fclose(fp);
	else pclose(fp);
    }
}

int
VHDLtokenizer::operator()()
{
    return token[current];
}

int
VHDLtokenizer::operator++()
{
    // Are there any good tokens ahead in the window ?
    if (current != last) {
	current = (current + 1) % TOKENWINDOWSIZE;
	return token[current];
    }

    if (fp == NULL) return token[current] = END_OF_FILE;

    // Parse in a new token
    current = (current + 1) % TOKENWINDOWSIZE;
    last = current;
    strcpy(image[current], "end-of-file");

RESTART:
    int lastc = 0;
    char c;

    // This tokenizer does not follow the description of
    // the lexical elements described in Chapter 13 of the
    // 1987 LRM. It tokenizes alphanumeric words, string literals
    // and all other characters. It also strips comments out.
    
    // Skip leading blanks
    while (isspace(c = fgetc(fp))) if (c == '\n') lineNo++;
    if (c == EOF) return token[current] = END_OF_FILE;

    // Guess the next type of token based on the first
    // non-white character
    if (c == '-') { // maybe a comment
	// If next character is a '-' too, skip to the
	// end of line and start over
	if ((c = fgetc(fp)) == '-') {
	    parseComment(fp, file);
	    lineNo++;
	    goto RESTART;
	}
	// Put the last character back in the stream
	// and return a '-'
	ungetc(c, fp);
	image[current][lastc++] = '-';

    } else if (c == '"') { // String literal
	// Slurp in until the next non-doubled '"'
	// or end-of-line (LRM s13.6, p3 says a string literal
	// must fit on one line)
	image[current][lastc++] = c;
	while (c == '"') {
	    while ((c = fgetc(fp)) != '"' && c != '\n' && c != EOF) {
		image[current][lastc++] = c;
	    }
	    // Check if the '"' is doubled
	    if (c == '"' && (c = fgetc(fp)) == '"') {
		image[current][lastc++] = c;
	    }
	    image[current][lastc++] = '"';
	}
	// Put last character back into the stream
	ungetc(c, fp);

    } else if (c == '%') { // String literal with allowed replacement
	// Slurp in until the next non-doubled '%'
	// or end-of-line (LRM s13.6, p3 says a string literal
	// must fit on one line)
	image[current][lastc++] = c;
	while (c == '%') {
	    while ((c = fgetc(fp)) != '%' && c != '\n' && c != EOF) {
		image[current][lastc++] = c;
	    }
	    // Check if the '%' is doubled
	    if (c == '%' && (c = fgetc(fp)) == '%') {
		image[current][lastc++] = c;
	    }
	    image[current][lastc++] = '%';
	}
	// Put last character back into the stream
	ungetc(c, fp);

    } else if (c == '\\') { // Extended Identifier
	// Slurp in until the next non-doubled '\'
	// or end-of-line (Does the 93LRM says an extended
	// literal must fit on one line ?)
	image[current][lastc++] = c;
	while (c == '\\') {
	    while ((c = fgetc(fp)) != '\\' && c != '\n' && c != EOF) {
		image[current][lastc++] = c;
	    }
	    // Check if the '\' is doubled
	    if (c == '\\' && (c = fgetc(fp)) == '\\') {
		image[current][lastc++] = c;
	    }
	    image[current][lastc++] = '\\';
	}
	// Put last character back into the stream
	ungetc(c, fp);

    } else if (isalpha(c)) { // word
	// Slurp all following alphanumeric characters
	// and convert to uppercase
	image[current][lastc++] = islower(c) ? toupper(c) : c;
	while ((isalnum(c = fgetc(fp)) || c == '_') &&
	       c != EOF) {
	    image[current][lastc++] =
		islower(c) ? toupper(c) : c;
	}
	// Put last character back into the stream
	ungetc(c, fp);

    } else { // Character
	image[current][lastc++] = c;
    }

    image[current][lastc] = '\0';

    //
    // Translate token image into an integer
    // Default is identifier.
    //
    token[current] = IDENTIFIER;

    // If token is only one character long, return the
    // character itself
    if (lastc == 1) {
        token[current] = image[current][0];
        // Except if it is only a letter, in which case it is
        // still and identifier
        if (isalpha(image[current][0])) {
            token[current] = IDENTIFIER;
        }
    }
    // String literal, maybe ?
    else if (image[current][0] == '"') {
	token[current] = STRING_LITERAL;
	// Check for (a subset of) reserved words
    } else {
	for (int i = 1; reservedWord[i] != NULL; i++) {
	    if (strcmp(image[current],
		       reservedWord[i]) == 0) {
		token[current] = -i;
		break;
	    }
	}
    }

    return token[current];
}

int
VHDLtokenizer::operator--()
{
    current = (current - 1 + TOKENWINDOWSIZE) % TOKENWINDOWSIZE;
    // Attempt to back up to far?
    if (current == last) return END_OF_FILE;
    return token[current];
}

void
VHDLtokenizer::save()
{
    tos++;
    if (tos == TOKENWINDOWSIZE) {
	fprintf(stderr, "Internal error: cannot push state\n");
	exit(-1);
    }
    state[tos] = (current << 16) + last;
}

void
VHDLtokenizer::restore()
{
    if (tos < 0) {
	fprintf(stderr, "Internal error: cannot restore state\n");
	exit(-1);
    }
    last = state[tos] & 0xFFFF;
    current = (state[tos] >> 16) & 0xFFFF;
    tos--;
}

const char*
VHDLtokenizer::text()
{
    return image[current];
}


//
// Parse (or skip) comments
//
static void
parseComment(FILE*       fp,
	     SourceFile* file)
{
    // Significant comment start with "-- vmk:"
    char c;

	// Skip leading blanks
    while (((c = fgetc(fp)) == ' '  || c == '\t') && c != EOF);
    if (c != '\n') {
	ungetc(c, fp);
	char bfr[1024];
	fgets(bfr, 1024, fp);
	if (strncmp(bfr, "vmk:", 4) == 0) {
	    // Truncate trailing '\n'
	    bfr[strlen(bfr) - 1] = '\0';
	    // Skip blanks to the significant portion
	    char* p;
	    for (p = bfr + 4; *p == ' ' || *p == '\t'; p++);
	    if (*p != '\0') file->addDirective(p);
	}
    }
}



//
// Class VHDLparser
//

VHDLparser::VHDLparser(SourceFile* srcFile, Library* lib)
    : file(srcFile), token(srcFile), library(lib)
{
}

VHDLparser::~VHDLparser()
{
}

LibraryUnit*
VHDLparser::nextUnit()
{
    Tracer trace(this, "Next unit routine");

    // A unit starts with a line that begin with one of the
    // following keyword:
    // LIBRARY, USE, PACKAGE, ENTITY, ARCHITECTURE, CONFIGURATION

    while (++token != END_OF_FILE) {
	switch (token()) {
	case LIBRARY:
	case USE:
	case PACKAGE:
	case ENTITY:
	case ARCHITECTURE:
	case CONFIGURATION:
	    --token;
	    return parseLibraryUnit();
	default:
	    // Skip to the next semi-colon
	    while(++token != ';' &&
		  token() != END_OF_FILE);
	}
    }
    return NULL;
}

LibraryUnit*
VHDLparser::parseLibraryUnit()
{
    Tracer trace(this, "Parsing library unit");

    LibraryUnit* unit = NULL;
    LibraryDeclList libraryDecls;

    // A library unit can start with LIBRARY or USE statements
    // before encountering one of PACKAGE, ENTITY,
    // ARCHITECTURE or CONFIGURATION statement.
    while (unit == NULL) {

	switch (++token) {
	case PACKAGE:	    // PACKAGE [BODY] name IS
	    if (++token == BODY) {
		++token;
		unit = new PackageBody(token.text(), file, library);
	    } else unit = new Package(token.text(), file, library);
	    if (++token != IS) error("Expecting \"IS\"");
	    break;

	case ENTITY:	    // ENTITY name IS
	    ++token;
	    unit = new Entity(token.text(), file, library);
	    if (++token != IS) error("Expecting \"IS\"");
	    break;

	case ARCHITECTURE:  // ARCHITECTURE name OF name IS
	{
	    ++token;
	    const char* aname = token.text();
	    ++token;
	    ++token;
	    unit = new Architecture(aname, token.text(), file, library);
	    if (++token != IS) error("Expecting \"IS\"");
	}
	break;

	case CONFIGURATION: // CONFIGURATION name OF [name '.' ] name IS
	{
	    ++token;
	    const char* cname = token.text();
	    ++token; ++token;
	    const char* libName = token.text();
	    if (++token == '.') ++token;
	    else {
	      libName = "WORK?";
	      --token;
	    }
	    unit = new Configuration(cname, libName, token.text(), file, library);
	    if (++token != IS) error("Expecting \"IS\"");
	}
	break;

	case LIBRARY:	// LIBRARY name {',' name} ';'
	{
	    ++token;
	    libraryDecls.append(strdup(token.text()));
	    while (++token == ',') {
		++token;
		libraryDecls.append(strdup(token.text()));
	    }
	    if (token() != ';') error("Expecting \";\"");
	}
	break;
	case USE:
	    parseUseClause(&libraryDecls, unit);
	    break;
	default:
	    // Skip to the next ';'
	    while (token() != ';') {
		++token;
		if (token() == END_OF_FILE) {
		    return NULL;
		}
	    }
	}
    }

    // Move the list of libraries and used units
    // to the unit proper
    LibraryDeclListIterator scanLibs(&libraryDecls);
    for (scanLibs.reset(); scanLibs(); ++scanLibs) {
	unit->knownLibraries.append(scanLibs());
    }
    libraryDecls.flush();
    commitUseClauses(unit);

    switch (unit->getType()) {
    case LibraryUnit::Configuration:
	parseConfiguration((Configuration*) unit);
	break;
    case LibraryUnit::Entity:
	parseEntity((Entity*) unit);
	break;
    case LibraryUnit::Architecture:
	parseArchitecture(unit);
	break;
    case LibraryUnit::Package:
    case LibraryUnit::PackageBody:
	parsePackage(unit);
	break;
    default:
	fprintf(stderr, "Internal error: unknown library unit\n");
        exitCode = -1;
    }

    if (debugLevel > 3) {
        unit->print(stdout);
    }

    return unit;
}

void
VHDLparser::parseUseClause(LibraryDeclList* libraryDecls, LibraryUnit* unit)
{
    Tracer trace(this, "Parsing use clause");

    if (token() != USE) {
	fprintf(stderr, "Internal error: not on USE clause\n");
        exitCode = -1;
	return;
    }

    while (1) {
	// USE [name '.'] name '.' (name | ALL) ';'
	// Easier to parse backward
	int tokenCount = 0;
	while (++token != ';' && token() != ',') {
	    tokenCount += 1;
	    if (token() == END_OF_FILE) return;
	};
	if (tokenCount < 3) {
	    error("Syntax error in USE clause");
            exitCode = -1;
	    return;
	}

        --token;
	unsigned unitType = LibraryUnit::Unknown;
	const char* itemName = token.text();

	--token; --token;
	const char* pkgName = token.text();
	const char* libName = NULL;

        if (--token == '.') {
            --token;
            libName = token.text();
            unitType = LibraryUnit::Package;
        } else {
            // It's a 'use A.B' statement.
            // Can be: LIB.PKG, LIB.ENT, LIB.CFG, or PKG.ITEM
            // If "A" is a known library, assume LIB.?
            // Otherwise, it's WORK.PKG.ITEM.
            unsigned isLib = 0;
            if (strcmp(pkgName, "WORK") == 0) {
                isLib = 1;
            }
            if (!isLib && libraryDecls != NULL) {
                LibraryDeclListIterator scanLibs(libraryDecls);
                for (scanLibs.reset(); scanLibs(); ++scanLibs) {
                    if (strcmp(scanLibs(), pkgName) == 0) {
                        isLib = 1;
                        break;
                    }
                }
            }
            if (!isLib && unit != NULL) {
                LibraryDeclListIterator scanLibs(&(unit->knownLibraries));
                for (scanLibs.reset(); scanLibs(); ++scanLibs) {
                    if (strcmp(scanLibs(), pkgName) == 0) {
                        isLib = 1;
                        break;
                    }
                }
            }
            if (isLib) {
                libName = pkgName;
                pkgName = itemName;
                itemName = NULL;
            } else {
                unitType = LibraryUnit::Package;
            }
        }
        if (libName == NULL) libName = "WORK?";
        
        // Ignore anything in STD
        // Ignore anything in IEEE unless 'useIEEE' is true
        if (strcmp(libName, "STD") != 0 &&
            (strcmp(libName, "IEEE") != 0 || useIEEE)) {
            Dependency* dep = new Dependency(unitType, libName, pkgName, itemName);
            usedStuff.append(dep);
        }
        // Move back to the ';' or ',' token
        while (++token != ';' && token() != ',');
        if (token() == ';') return;
    }
}

void
VHDLparser::commitUseClauses(LibraryUnit* unit)
{
    DependencyListIterator scanUsed(&usedStuff);
    for (scanUsed.atHead(); scanUsed(); ++scanUsed) {
	unit->addDependency(scanUsed());
    }
    usedStuff.flush();
}


void
VHDLparser::parseConfiguration(Configuration* unit)
{
    Tracer trace(this, "Parsing configuration");

    char* entityName = unit->parent;

    // The configuration declarative part ends
    // when 'FOR' is reached
    while (++token != FOR) {
	if (token() == END_OF_FILE) return;
	if (token() == USE) parseUseClause(NULL, unit);
	else parseToSemiColon(unit);
    }
    parseBlockConfiguration(unit, entityName, unit->getLibName());

    // The configuration ends at the next ';'
    ++token;
    parseToSemiColon(unit);
}

void
VHDLparser::parseBlockConfiguration(LibraryUnit* unit, const char* entityName,
				    const char* libName)
{
    Tracer trace(this, "Parsing block configuration");

    if (token() != FOR) {
	fprintf(stderr, "Internal error: block configuration not on FOR\n");
        exitCode = -1;
	return;
    }

    ++token; // Now on block name
    // If entityName != NULL, this is the block corresponding
    // to the entity's architecture and the block name is really
    // the architecture name of the entity.
    if (entityName != NULL) {
	// This unit depends on this architecture
	unit->addDependency(new Dependency(LibraryUnit::Architecture, libName, entityName, token.text()));
    }

    while(1) {
	switch(++token) {
	case '(':	// Index of a for-generate block
	    // Slurp until the next ')'
	    while (++token != ')') {
		if (token() == END_OF_FILE) return;
	    }
	    break;
	case USE:
	    parseUseClause(NULL, unit);
	    break;
	case FOR:
	    parseConfigurationItem(unit, NULL, 1);
	    break;
	case END:
	    // Only FOR ';' left
	    ++token;
	    ++token;
	    return;
	default:
	    // Slurp to the next ';' or GENERATE
	    ++token;
	    parseToSemiColon(unit, GENERATE);
	}
    }
}

void
VHDLparser::parseConfigurationItem(LibraryUnit* unit,
				   Block* block,
				   unsigned inConfigSpec)
{
    Tracer trace(this, "Parsing configuration item");

    // FOR label ':' indicates a component configuration

    if (token() != FOR) {
	fprintf(stderr, "Internal error: configuration item is not FOR\n");
        exitCode = -1;
	return;
    }

    StringList labelList;
    ++token;
    labelList.append(strdup(token.text()));
    if (++token == ':' || token() == ',') {
	while (token() != ':' && token() != END_OF_FILE) {
	    ++token;
	    if (token() == IDENTIFIER) labelList.append(strdup(token.text()));
	}

	// Component configuration
	++token;
	const char* compName = token.text();

	const char* libraryName = "WORK?";
	const char* entityName = NULL;
	if (++token == USE) {
	    Tracer trace(this, "Parsing component configuration");
	    const char* archName = NULL;
	    switch (++token) {
	    case CONFIGURATION:
		// [library '.'] name ';'
		++token;
		libraryName = token.text();
		if (++token == '.') ++token;
		else {
		    libraryName = "WORK?";
		    --token;
		}
		unit->addDependency(new Dependency(LibraryUnit::Configuration, libraryName, token.text(), NULL));
		// Add a configuration descriptor for each label
                // if in an architecture
                if (block != NULL) {
                    StringListIterator scanLabels(&labelList); 
                    for (scanLabels.reset(); scanLabels(); ++scanLabels) {
                        block->configs.append(new CompConfig(scanLabels(),
                                                             compName,
                                                             LibraryUnit::Configuration,
                                                             libraryName,
                                                             token.text()));
                    }
                }
		// Move to the ';'
		parseToSemiColon(unit);
		break;
	    case ENTITY:
		// [library '.'] name ['(' name ')'] ... ';'
		++token;
		libraryName = token.text();
		if (++token == '.') {
		    ++token;
		    entityName = token.text();
		} else {
		    entityName = libraryName;
		    libraryName = NULL;
		    --token;
		}
		// Optional architecture specification
		if (++token == '(') {
		    ++token;
		    archName = token.text();
		}
		// Depend on the architecture
		// only if this is in a config spec
		// or if the Makefile is targetted
		// to a toolset with hard bindings
		if ((inConfigSpec || ToolSet::getBindings() == ToolSet::Hard)
		    && archName != NULL) unit->addDependency(new Dependency(LibraryUnit::Architecture, libraryName, entityName, archName));
		else unit->addDependency(new Dependency(LibraryUnit::Entity, libraryName, entityName, NULL));
		// Memory leak!
		entityName = strdup(entityName);
		libraryName = strdup(libraryName);
		// Add a configuration descriptor for each label
                // if in an architecture
                if (block != NULL) {
                    StringListIterator scanLabels(&labelList);
                    for (scanLabels.reset(); scanLabels(); ++scanLabels) {
                        block->configs.append(new CompConfig(scanLabels(),
                                                             compName,
                                                             LibraryUnit::Entity,
                                                             libraryName,
                                                             entityName,
                                                             archName));
                    }
                }
		// Move to the ';'
		parseToSemiColon(unit);
		break;
	    }
	} else if (token() == OPEN) {
	    // Leave component unconfigured
	} else {
	    // No 'use binding_indication' part.
	    --token;
	    // We assume a default configuration.
	    // Use the component name as the entity name
	    // in case this default binding is followed
	    // by a block configuration, in which case
	    // it is equivalent to an explicit configuration
	    entityName = token.text();
	}
	// May be followed by a block configuration
	if (inConfigSpec && ++token == FOR) {
	    Tracer trace(this, "Parsing subsequent block configuration");
	    parseBlockConfiguration(unit, entityName, libraryName);
	    ++token;
	}
	// Get to the next ';'
	parseToSemiColon(unit);
    } else if (inConfigSpec) {
	// Back up to the FOR
	--token; --token;
	parseBlockConfiguration(unit, NULL, NULL);
    }
}

void
VHDLparser::parseEntity(Entity* unit)
{
    Tracer trace(this, "Parsing entity");

    while (1) {
	switch (++token) {
	case PORT:
	    // An entity with ports cannot be a top
	    unit->hasNoPorts = 0;
	    break;
	case BEGIN:
	    parseUnitBody(unit);
	    return;
	case END:
	    parseToSemiColon(unit);
	    commitUseClauses(unit);
	    return;
	case END_OF_FILE:
	    commitUseClauses(unit);
	    return;
	default:
	    // May have a LIB.PKG.TYPE reference
	    if (token() == '.') parseLibDotPkgDotItem(unit);
	    break;
	}
    }
}

void
VHDLparser::parseArchitecture(LibraryUnit* unit)
{
    Tracer trace(this, "Parsing architecture");

    parseUnitBody(unit, (Architecture*) unit);
}

void
VHDLparser::parsePackage(LibraryUnit* unit)
{
    Tracer trace(this, "Parsing package");

    parseUnitBody(unit);
}

void
VHDLparser::parseUnitBody(LibraryUnit* unit,
			  Block*       block)
{
    Tracer trace(this, "Parsing unit body");

    // The significant statements within a unit are
    // USE ...
    // FOR (ALL | labelName) ':' componentName USE ...
    // labelName ':' compName (GENERIC | PORT) MAP
    // labelName ':' BLOCK ...
    // labelName ':' IF ... GENERATE ...
    // labelName ':' FOR ... GENERATE ...
    // libname.pkgname.itemname
    while (token() != END_OF_FILE) {
	switch (token()) {
	    // These terminate the current unit
	case LIBRARY:
	    --token;
	    return;

	    // These terminate the current unit if and only if
	    // they were preceeded by a ';'. Otherwise they
	    // are part of a statement (e.g. attribute spec).
	case ENTITY:
	case CONFIGURATION:
	case ARCHITECTURE:
	case PACKAGE:
	    if (--token == ';') return;
	    ++token;
	    break;

	case USE:
	    // Use clause can appear almost anywhere in VHDL-93
	    parseUseClause(NULL, unit);
	    break;

	case END:
	    // Any pending use clauses belong to this unit
	    commitUseClauses(unit);
	    break;

	case MAP:
	    parseInstantiation(unit, block);
	    break;

	case FOR:
	    // Component configuration specification:
	    // FOR <skip> ':' <skip> USE ...
	    ++token;
	    if (++token == ':' || token() == ',') {
		--token; --token;
		parseConfigurationItem(unit, block, 0);
	    } else {
		--token; --token;
	    }
	    break;

	case BLOCK:
	    // If this is the end of the block,
	    // terminate this parsing level
	    if (--token == END) {
		++token; ++token;
		return;
	    }
	    // Parse the subblock
	    // label : BLOCK
            if (token() != ':') {
                error("Syntax error in BLOCK statement");
                exit(-1);
            }
	    {
		--token;
		Block* subBlock = new Block(token.text(), block, unit);
		block->subBlocks.append(subBlock);
		++token; ++token; ++token;
		parseUnitBody(unit, subBlock);
	    }
	    break;

	case GENERATE:
	    // If this is the end of the block,
	    // terminate this parsing level
	    token.save();
	    if (--token == END) {
		++token; ++token;
		return;
	    }
	    // Parse the subblock
	    // label : IF ... GENEREATE
	    // label : FOR ... GENEREATE
	    {
		// Backup until we reach the label
		while (--token != IF && token() != FOR &&
		       token() != END_OF_FILE);
		if (token() == END_OF_FILE || --token != ':') {
		    token.restore();
		    error("Missing label on GENERATE statement");
		    exit(-1);
		}
		--token;
		Block* subBlock = new Block(token.text(), block, unit);
		block->subBlocks.append(subBlock);
		token.restore(); ++token;
		parseUnitBody(unit, subBlock);
	    }
	    break;

	case '.':
	    parseLibDotPkgDotItem(unit);
	    break;
	}
	++token;
    }
}

void
VHDLparser::parseInstantiation(LibraryUnit* unit,
			       Block*       block)
{
    Tracer trace(this, "Parsing instantiation");

    if (token() != MAP) {
	fprintf(stderr, "Internal error: instantiation is not on MAP\n");
        exitCode = -1;
	return;
    }

    token.save();

    // Maybe a component instantiation
    // Valid instantiations are:
    // label ':' [COMPONENT] name
    // label ':' ENTITY name ['(' name ')']
    // label ':' CONFIGURATION name
    // Could also be within a block header
    // (which is one we want to skip)
    --token; // PORT or GENERIC
    if (token() != PORT && token() != GENERIC) {
	error("Not a PORT or GENERIC map");
	token.restore();
	return;
    }
    if (--token == ';') {
	// block header!
        if (debugLevel > 6) printf("Skipping block interface map.\n");
	token.restore();
	return;
    }
    if (token() == ')') {
	// Could be the ')' of a previous
	// generic map or in an entity(arch) spec in VHDL-93
	--token;
	if (--token != '(' || --token == MAP) {
            if (debugLevel > 6) printf("Skipping generic map.\n");
	    token.restore();
	    return;
	}
    }

    while (token() != ':') --token;
    // Get the label
    --token;
    const char* labelName = token.text();
    if (debugLevel > 6) printf("Parsing instantiation %s\n", labelName);
    ++token;
    const char* libraryName = NULL;
    const char* entityName = NULL;
    const char *archName = NULL;

    switch (++token) {
    case COMPONENT:
	++token;
    case IDENTIFIER:
	// Potential default configuration
	unit->defaultConfs.append(new Dependency(LibraryUnit::Entity, "WORK?", token.text(), NULL));
        if (debugLevel > 4) printf("Adding default configuration to %s.\n", token.text());
	// Add a default component configuration if this
	// component isn't already covered by a configuration statement
	{
	    unsigned covered = 0;
	    BlockConfigIter scanConfigs(block);
	    for (scanConfigs.reset(); scanConfigs(); ++scanConfigs) {
		if (strcmp(scanConfigs()->labelName(), labelName) == 0 ||
		    strcmp(scanConfigs()->labelName(), "all") == 0 ||
		    strcmp(scanConfigs()->labelName(), "others") == 0) {
		    covered = 1;
		    break;
		}
	    }
	    if (covered) break;
	    block->configs.append(new CompConfig(labelName,
						 token.text(),
						 LibraryUnit::Entity,
						 "WORK?",
						 token.text(),
						 NULL));
	}
	break;
    case ENTITY:
	// [library '.'] name ['(' name ')']
	++token;
	libraryName = token.text();
	if (++token == '.') {
	    ++token;
	    entityName = token.text();
	} else {
	    entityName = libraryName;
	    libraryName = NULL;
	    --token;
	}
	// Optional architecture specification
	if (++token == '(') {
	    ++token;
	    archName = token.text();
	    ++token;
	}
	unit->addDependency(new Dependency(LibraryUnit::Entity, libraryName, entityName, archName));
	break;
    case CONFIGURATION:
	// [library '.'] name
	++token;
	libraryName = token.text();
	if (++token == '.') ++token;
	else {
	    libraryName = NULL;
	    --token;
	}
	unit->addDependency(new Dependency(LibraryUnit::Configuration, libraryName, token.text(), NULL));
	break;
    default:
        error("Syntax error");
        exitCode = -1;
    }

    token.restore();
}


void
VHDLparser::parseToSemiColon(LibraryUnit* unit,
			    int          terminate)
{
    // Skip to the next ';', watching for L.P.I
    // Abort if token "terminate" is reached
    while (token() != ';' &&
	   token() != terminate &&
	   token() != END_OF_FILE) {
	if (token() == '.') parseLibDotPkgDotItem(unit);
	++token;
    }
}


void
VHDLparser::parseLibDotPkgDotItem(LibraryUnit* unit)
{
    // Expect LIB.PKG.ITEM, starting from first '.'

    // Is the previous token a library name?
    --token;
    if (!unit->isLibrary(token.text())) {
	// Nope. Abort.
	++token;
	return;
    }
    const char* libName = token.text();
    // Ignore things in STD or IEEE
    if (strcmp(libName, "STD") == 0 ||
        strcmp(libName, "IEEE") == 0) {
        ++token;
        return;
    }
    
    // We have a dependency to a package boys and girls!
    ++token; // Back on '.'
    ++token; // On package name
    const char* pkgName = token.text();
    // We only deal with names of the form L.P.I
    if (++token != '.') return;
    ++token; // On item name
    unit->addDependency(new Dependency(LibraryUnit::Package,
				       libName, pkgName, "all"));
}


void
VHDLparser::error(const char* message)
{
    fprintf(stderr, "ERROR: %s, line %d, token \"%s\": %s ",
	    token.fileName(), token.lineNumber(), token.text(),
	    message);
    if (errno) perror("");
    else fprintf(stderr, "\n");
    exitCode = -1;
}

void
VHDLparser::warning(const char* message)
{
    fprintf(stderr, "WARNING: %s, line %d, token \"%s\": %s\n",
	    token.fileName(), token.lineNumber(), token.text(),
	    message);
}

//
// Tracer class
//
Tracer::Tracer(VHDLparser* parser, const char* msg)
    : p(parser), m(msg)
{
    if (debugLevel < 5) return;

    printf("ENTERING: %s, line %d, token \"%s\": %s\n",
	   p->token.fileName(), p->token.lineNumber(),
	   p->token.text(), m);
}

Tracer::~Tracer()
{
    if (debugLevel < 5) return;

    printf("EXITING: %s, line %d, token \"%s\": %s\n",
	   p->token.fileName(), p->token.lineNumber(),
	   p->token.text(), m);
}

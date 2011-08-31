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

#ifndef VHDL_PARSER
#define VHDL_PARSER

#include <stdio.h>

class LibraryUnit;

class Dependency {
public:
	Dependency(int unitType, const char* inLib, const char* mainUnit,
		   const char* secUnit);
	~Dependency();
	static void destroy(Dependency* obj);

	const char*  libName()  { return library; };
	const char*  mainName() { return parent; };
	const char*  secName()  { return child; };
	int          getType()  { return type; };
	LibraryUnit* getUnit()  { return unit; };

	void         setUnit(LibraryUnit* actualUnit);

	void         isLibDotAll();
	void         isPackDotItem();

private:
	char*        library;
	char*        parent;
	char*        child;
	int          type;
	LibraryUnit* unit;
};
#define LISTOF_TYPE     Dependency
#define LISTOF          DependencyList
#define LISTOF_ITERATOR DependencyListIterator
#include "ListOf.hxx"


class CompConfig {
public:
	CompConfig(const char* instLabel, const char* compName,
		   int unitType, const char* inLib, const char* mainUnit,
		   const char* secUnit = NULL);
	~CompConfig();
	static void destroy(CompConfig* obj);

	const char*  labelName() { return label; };
	const char*  compName()  { return component; };
	const char*  libName()   { return library; };
	const char*  mainName()  { return parent; };
	const char*  secName()   { return child; };
	int          getType()   { return type; };
	LibraryUnit* getUnit()   { return unit; };

	void         setUnit(LibraryUnit* actualUnit);

private:
	char*        label;
	char*        component;
	char*        library;
	char*        parent;
	char*        child;
	int          type;
	LibraryUnit* unit;
};
#define LISTOF_TYPE     CompConfig
#define LISTOF          CompConfigList
#define LISTOF_ITERATOR CompConfigListIterator
#include "ListOf.hxx"


class Block;
#define LISTOF_TYPE     Block
#define LISTOF          BlockList
#define LISTOF_ITERATOR BlockListIterator
#include "ListOf.hxx"

class Block {
protected:
	Block(const char* blockName, Block* inBlock, LibraryUnit* inUnit);
	~Block();

public:
	static void destroy(Block* obj);

	const char*  getName();
	Block*       getBlock();
	LibraryUnit* getUnit();

	void print(FILE* fp = stdout,
		   unsigned level = 0);

private:
	char*              name;
        Block*             parentBlock;
	LibraryUnit*       parentUnit;

	CompConfigList     configs;
        BlockList          subBlocks;

	friend class BlockConfigIter;
	friend class SubBlockIter;
	friend class VHDLparser;
};

class BlockConfigIter: public CompConfigListIterator {
public:
	BlockConfigIter(Block* block)
	: CompConfigListIterator(&block->configs)
		{};
	~BlockConfigIter()
		{};
};

class SubBlockIter: public BlockListIterator {
public:
	SubBlockIter(Block* block)
	: BlockListIterator(&block->subBlocks)
		{};
	~SubBlockIter()
		{};
};


#define LISTOF_TYPE     char
#define LISTOF          LibraryDeclList
#define LISTOF_ITERATOR LibraryDeclListIterator
#include "ListOf.hxx"

class SourceFile;
#define LISTOF_TYPE      SourceFile
#define LISTOF           SourceFileList
#define LISTOF_ITERATOR  SourceFileListIterator
#include "ListOf.hxx"


class Library;

class LibraryUnit {
protected:
	LibraryUnit(const char* unitName, int unitType, SourceFile* inFile,
		    Library* inLib, const char* mainUnitName = NULL);
	~LibraryUnit();

public:
	static void destroy(LibraryUnit* obj);

	enum {Unknown, LibraryAll, Package, PackageBody, Entity, Architecture, Configuration};

	unsigned     getType();
	const char*  getName();
	const char*  getParentName();
	LibraryUnit* getParent();
	void         setParent(LibraryUnit* newParent);
	const char*  getId();
	void         setId(const char* newId);

        SourceFile*  getSourceFile();
        Library*     getLibrary();

	unsigned     isLibrary(const char* identifier);
	unsigned     isLoose();
	void         isReferenced();

	unsigned     isOnLine(unsigned lineNumber,
                              unsigned update);

        void         addDependency(Dependency* dep);
    
	static const char* unitTypeImage(int type);
	void printDesc(FILE* fp);
	void print(FILE* fp = stdout);

private:
	LibraryDeclList    knownLibraries;
	char*              name;
	unsigned           type;
	char*              parent;
	LibraryUnit*       parentUnit;
	char*	   	   id;
        SourceFile*        srcFile;
        Library*           lib;
	unsigned	   onLine;

	DependencyList     dependencies;
	DependencyList     defaultConfs;
	unsigned           referenced;

	friend class LibraryDeclIter;
	friend class LibraryUnitDependsIter;
	friend class LibraryUnitDefConfsIter;
	friend class VHDLparser;
};


class LibraryDeclIter: public LibraryDeclListIterator {
public:
	LibraryDeclIter(LibraryUnit* unit)
	: LibraryDeclListIterator(&unit->knownLibraries)
		{};
	~LibraryDeclIter()
		{};
};


class LibraryUnitDependsIter: public DependencyListIterator {
public:
	LibraryUnitDependsIter(LibraryUnit* unit)
	: DependencyListIterator(&unit->dependencies)
		{};
	~LibraryUnitDependsIter()
		{};
};


class LibraryUnitDefConfsIter: public DependencyListIterator {
public:
	LibraryUnitDefConfsIter(LibraryUnit* unit)
	: DependencyListIterator(&unit->defaultConfs)
		{};
	~LibraryUnitDefConfsIter()
		{};
};


class PackageBody : public LibraryUnit {
public:
	PackageBody(const char* name, SourceFile* inFile, Library* inLib)
	: LibraryUnit(name, LibraryUnit::PackageBody, inFile, inLib, name)
		{};
	~PackageBody()
		{};
};


class Package : public LibraryUnit {
public:
	Package(const char* name, SourceFile* inFile, Library* inLib)
	: LibraryUnit(name, LibraryUnit::Package, inFile, inLib), body(NULL)
		{};
	~Package()
		{};

	class PackageBody* getBody()
		{ return body; };

	void setBody(class PackageBody *newBody)
		{ body = newBody; };
private:
	class PackageBody* body;
};


#define LISTOF_TYPE     LibraryUnit
#define LISTOF          LibraryUnitList
#define LISTOF_ITERATOR LibraryUnitListIterator
#include "ListOf.hxx"


class Entity : public LibraryUnit {
public:
	Entity(const char* name, SourceFile* inFile, Library* inLib)
	: LibraryUnit(name, LibraryUnit::Entity, inFile, inLib), hasNoPorts(1), children()
		{};
	~Entity()
		{};

	unsigned canBeTop() { return allTops || hasNoPorts; };
	void addChild(LibraryUnit* unit)
		{ children.append(unit); };

private:
	unsigned        hasNoPorts;
	LibraryUnitList children;

	friend class EntityChildrenIter;
	friend class VHDLparser;
};


class EntityChildrenIter : public LibraryUnitListIterator {
public:
	EntityChildrenIter(Entity* unit)
	: LibraryUnitListIterator(&unit->children)
		{};
	~EntityChildrenIter()
		{};
};


class Architecture : public LibraryUnit, public Block {
public:
	Architecture(const char* aname, const char* ename, SourceFile* inFile, Library* inLib)
	: LibraryUnit(aname, LibraryUnit::Architecture, inFile, inLib, ename),
	  Block(aname, NULL, this)
		{};
	~Architecture()
		{};
};


class Configuration : public LibraryUnit {
public:
  Configuration(const char* cname, const char* libname, const char* ename,
		SourceFile* inFile, Library* inLib)
    : inLibName(strdup(libname)),
      LibraryUnit(cname, LibraryUnit::Configuration, inFile, inLib, ename)
    {};
  ~Configuration()
    {};

  const char* getLibName()
    {
      return inLibName;
    }

private:
    const char* inLibName;
};


#define LISTOF_TYPE      char
#define LISTOF           DirectiveList
#define LISTOF_ITERATOR  DirectiveListIterator
#include "ListOf.hxx"


class SourceFile {
public:
	SourceFile(const char* fileName);
	~SourceFile();

	static void destroy(SourceFile* obj);

	const char* getName();
	void addUnit(LibraryUnit* unit);
	void addDirective(const char* directive);
	const char* getDirective(const char* keyword);
	void addConsequence(SourceFile* obj);

private:
	char*     name;
	LibraryUnitList units;

	DirectiveList directives;

        SourceFileList consequences;

	friend class SourceFileUnitIter;
	friend class SourceFileConseqIter;
};


class SourceFileUnitIter: public LibraryUnitListIterator {
public:
	SourceFileUnitIter(SourceFile& file);
	~SourceFileUnitIter();
};


class SourceFileConseqIter: public SourceFileListIterator {
public:
	SourceFileConseqIter(SourceFile& file);
	~SourceFileConseqIter();
};


class Library {
public:
	Library(const char* libName, const char* path, const char* pat);
	~Library();

	const char* getName();
        const char* getPath();
        const char* getPattern();
        void addAlias(const char* alias);
	void addFile(SourceFile* file);
	void addUnit(LibraryUnit* unit);
        int isLib(const char* nam);
        void make();
        int inMakefile();

private:
	char*           name;
        char*           srcPath;
        char*           pattern;
        int             inMake;
        StringHashTable aliases;
	SourceFileList  files;
	LibraryUnitList units;

	friend class SourceFileIter;
	friend class LibraryUnitIter;
	friend class LibraryAliasIter;
};


class SourceFileIter: public SourceFileListIterator {
public:
	SourceFileIter(Library& lib);
	~SourceFileIter();
};


class LibraryUnitIter: public LibraryUnitListIterator {
public:
	LibraryUnitIter(Library& lib);
	~LibraryUnitIter();
};


class LibraryAliasIter: public StringHashTableIter {
public:
	LibraryAliasIter(Library& lib);
	~LibraryAliasIter();
};


#define HASHTABLE_ENTRY 	Library
#define HASHTABLE		LibraryHashTable
#define HASHTABLE_ITERATOR	LibraryHashTableIter
#include "HashTabl.hxx"


//
// Global handle to libraries
//
extern LibraryHashTable libraries;


class VHDLtokenizer {
public:
	VHDLtokenizer(SourceFile* srcFile);
	~VHDLtokenizer();

	int operator()();
	int operator++();
	int operator--();
        void save();
        void restore();
	const char* text();

	const char* fileName() { return file->getName(); };
	unsigned lineNumber() { return lineNo; };

private:
	SourceFile* file;
	FILE*       fp;
	unsigned    lineNo;

#define TOKENWINDOWSIZE 2048
	char*    image[TOKENWINDOWSIZE];
	int      token[TOKENWINDOWSIZE];
	unsigned state[TOKENWINDOWSIZE];
	unsigned last;
	unsigned current;
	int      tos;
	char	 imageBuffer[256 * TOKENWINDOWSIZE];
};


class VHDLparser {
public:
    VHDLparser(SourceFile* srcFile, Library* lib);
    ~VHDLparser();
    
    LibraryUnit* nextUnit();
    
private:
    Library*    library;
    SourceFile*  file;
    
    LibraryUnit* parseLibraryUnit();
    void parseUseClause(LibraryDeclList* libraryDecls, LibraryUnit* unit);
    void commitUseClauses(LibraryUnit* unit);
    void parseConfiguration(Configuration* unit);
    void parseConfigurationDeclarativePart(LibraryUnit* unit);
    void parseBlockConfiguration(LibraryUnit* unit, const char* entity,
                                 const char* libName);
    void parseConfigurationItem(LibraryUnit* unit, Block* block,
				unsigned inConfigSpec);
    void parseEntity(Entity* unit);
    void parseArchitecture(LibraryUnit* unit);
    void parsePackage(LibraryUnit* unit);
    void parseUnitBody(LibraryUnit* unit, Block* block = NULL);
    void parseInstantiation(LibraryUnit* unit, Block* block);
    void parseToSemiColon(LibraryUnit* unit, int terminate = 0);
    void parseLibDotPkgDotItem(LibraryUnit* unit);

    void error(const char* message);
    void warning(const char* message);
    void trace(const char* message);
    
    VHDLtokenizer token;
    
    friend class Tracer;
};

class Tracer {
public:
	Tracer(VHDLparser* parser, const char* msg);
	~Tracer();
private:
	VHDLparser* p;
	const char* m;
};


#endif

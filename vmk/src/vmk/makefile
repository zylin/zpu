# Makefile for VMK

ARCH	= LINUX
#ARCH	= SUN
#ARCH	= DOS

UTILS = ../utils

BINDIR	= /usr/local/bin

CC = $(BINDIR)/g++-3 -c -DUNIX -D$(ARCH) -I$(UTILS)
LD = $(BINDIR)/g++-3 -static -L$(UTILS)

.SUFFIXES: .cxx

all: vmk

clean:
	rm -rf .stamps.* StmpDict.vmk *~ \#*\# *.bak core *.o *.a

.cxx.o:
	$(CC) $<

.c.o:
	$(CC) $<

OBJS = vmk.o ToolSet.o rcFile.o VHDLprse.o Makefile.o Conseq.o

vmk: $(OBJS) ../utils/libUtils.a
	$(LD) -o vmk $(OBJS) -lUtils

vmk.o: globals.hxx rcFile.hxx VHDLprse.hxx Makefile.hxx ToolSet.hxx \
       Conseq.hxx ../version.hxx
ToolSet.o: ToolSet.hxx VHDLprse.hxx
rcFile.o: rcFile.hxx ToolSet.hxx
VHDLprse.o: globals.hxx VHDLprse.hxx ToolSet.hxx
Makefile.o: globals.hxx Makefile.hxx ToolSet.hxx
Makefile.o: globals.hxx Conseq.hxx

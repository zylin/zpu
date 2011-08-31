# Makefile for utilities

ARCH	= LINUX
#ARCH	= SUN
#ARCH	= DOS
BINDIR	= /usr/bin

CC = $(BINDIR)/g++-3 -c -DUNIX -D$(ARCH)

.SUFFIXES: .cxx

OBJS = ListOfBs.o HshTblBs.o BitArray.o glob.o relocate.o \
       envexp.o

all: libUtils.a

clean:
	rm -f *~ \#*\# *.bak core *.o *.a glob encode

.cxx.o:
	$(CC) $<

libUtils.a: $(OBJS)
	ar r libUtils.a $(OBJS)
	ranlib libUtils.a

ListOfBs.o: ListOfBs.hxx
HshTblBs.o: HshTblBs.hxx
BitArray.o: BitArray.hxx
relocate.o: relocate.h
envexp.o: envexp.h

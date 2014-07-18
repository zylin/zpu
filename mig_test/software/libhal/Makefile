#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/hw_sp605/bsp_zpuahb/software/libhal/Makefile $
# $Date$
# $Author$
# $Revision$
#

DIR=..
include include.mak


C_FILES=hw.c common.c timer.c uart.c vga.c
OBJECTS=hw.o common.o timer.o uart.o vga.o
INCLUDES=../include/peripherie.h


all: libhal.a


libhal.a: $(OBJECTS) $(INCLUDES)
	$(AR) clr libhal.a $(OBJECTS)
	$(RANLIB) libhal.a


%.o: %.c $(INCLUDES)
	$(CC) -c -o $@ $< $(CFLAGS)


clean:
	rm -f *.o
	rm -f libhal.a

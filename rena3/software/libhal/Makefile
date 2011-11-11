#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/libhal/Makefile $
# $Date: 2011-08-09 15:36:41 +0200 (Di, 09. Aug 2011) $
# $Author: lange $
# $Revision: 1186 $
#

DIR=..
include include.mak


C_FILES=hw.c common.c timer.c uart.c
OBJECTS=hw.o common.o timer.o uart.o
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

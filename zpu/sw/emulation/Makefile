# JTAG / shifter real life test bench code
# (c) 2005-2011, Martin Strubel <hackfin@section5.ch>
#

NETPP = $(HOME)/src/netpp
BFEMU = $(HOME)/src/blackfin/bfemu

XSL = tapreg.xsl
# TAP register definitions:
TAPDEF = $(HOME)/src/vhdl/tap/tap.xml

CFLAGS = -I$(BFEMU) -g -Wall

DUTIES = libzpuemu.a

all: $(DUTIES)

tap.h: $(TAPDEF) $(XSL)
	xsltproc -o $@ $(XSL) $<

zpu-tap.h: $(TAPDEF) $(XSL)
	xsltproc -o $@ --param selectDevice 2 $(XSL) $<

LIBOBJS = zpuemu.o

libzpuemu.a: $(LIBOBJS)
	$(AR) ruv $@ $(LIBOBJS)


clean:
	rm -f *.o $(DUTIES)

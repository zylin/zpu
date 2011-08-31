ARCH     = LINUX
#ARCH     = SUN
#ARCH     = DOS
GNUDIR   = /usr

BINDIR   = $(GNUDIR)/bin
G++LIB   = $(GNUDIR)/lib
CFLAGS   =

all:
	(cd utils; make BINDIR=$(BINDIR) ARCH=$(ARCH) CFLAGS="$(CFLAGS)" G++LIB=$(G++LIB) all)
	(cd vmk; make BINDIR=$(BINDIR) ARCH=$(ARCH) CFLAGS="$(CFLAGS)" G++LIB=$(G++LIB) all)

clean:
	(cd utils; make BINDIR=$(BINDIR) ARCH=$(ARCH) clean)
	(cd vmk; make BINDIR=$(BINDIR) ARCH=$(ARCH) clean)

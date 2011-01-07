library      = grlib
top          = 

rtl_files    = ../rtl/version.vhd \
               ../rtl/stdlib.vhd \
               ../rtl/amba.vhd \
               ../rtl/devices.vhd \
               ../rtl/ahbctrl.vhd \
               ../rtl/apbctrl.vhd \
	       ../rtl/report_version.vhd 

rtl_tb_files = ../rtl_tb/stdio.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)


all: compile

remake: lib Makefile.$(library)

Makefile.$(library): $(vhdlfiles) $(library)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	vmake $(library) > Makefile.$(library)
	# patch winpath -> cygpath
	sed -e 's/\(C:.*\)/$$(shell cygpath --unix "\1" | sed "s\/ \/\\\\\\\\ \/g" )/g' -i Makefile.$(library)


compile: lib $(vhdltargets)

$(vhdltargets): $(vhdlfiles)
	vcom -quiet  -2008 -work $(library) $(vhdlfiles)
	# $(vhdltargets)


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library)
	rm -f Makefile.$(library)


# default patterns

lib:	$(library)

$(library):
	vlib $(library)

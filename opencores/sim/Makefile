library      = opencores

rtl_files    = ../rtl/i2c_master_bit_ctrl.vhd \
               ../rtl/i2c_master_byte_ctrl.vhd \
               ../rtl/i2coc.vhd \

vhdlfiles    = $(rtl_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)


all: compile

compile: lib deplibs $(vhdltargets)

deplibs:
	make compile --directory ../../grlib/sim

$(vhdltargets): $(vhdlfiles)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)


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

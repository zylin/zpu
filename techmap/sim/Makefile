library      = techmap

rtl_files    = ../rtl/gencomp.vhd \
	       ../rtl/allddr.vhd \
	       ../rtl/allmem.vhd \
	       ../rtl/allpads.vhd \
	       ../rtl/generic_syncram.vhd \
	       ../rtl/syncram_2p.vhd \
	       ../rtl/syncram_dp.vhd \
	       ../rtl/memory_unisim.vhd \
	       ../rtl/netcomp.vhd \
	       ../rtl/ddrphy.vhd \
	       ../rtl/outpad.vhd \
	       ../rtl/unisim_inpad.vhd \
	       ../rtl/unisim_iddr_reg.vhd \
	       ../rtl/spartan3e_ddr_phy.vhd \
	       ../rtl/clkpad.vhd \
	       ../rtl/iopad.vhd \
	       ../rtl/syncram.vhd \

rtl_tb_files = ../rtl_tb/*.vhd

vhdlfiles    = $(rtl_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)


all: compile


remake: lib compile


compile: dependlib lib $(vhdltargets)

$(vhdltargets): $(vhdlfiles)
	vcom -quiet  -2008 -work $(library) $(vhdlfiles)

dependlib:
	make compile --directory ../../grlib/sim


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

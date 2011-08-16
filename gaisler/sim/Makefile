library      = gaisler
top          = 

rtl_files    = ../rtl/misc.vhd \
               ../rtl/uart.vhd \
               ../rtl/net.vhd \
               ../rtl/charrom_package.vhd \
               ../rtl/memctrl.vhd \
               ../rtl/spimctrl.vhd \
	       ../rtl/grethpkg.vhd \
	       ../rtl/leon3.vhd \
	       ../rtl/libdcom.vhd \
	       ../rtl/ahbmst.vhd \
	       ../rtl/dcom.vhd \
	       ../rtl/ethernet_mac.vhd \
	       ../rtl/irqmp.vhd \
	       ../rtl/ahbram.vhd \
	       ../rtl/ahbdpram.vhd \
	       ../rtl/dcom_uart.vhd \
	       ../rtl/gptimer.vhd \
	       ../rtl/ahbstat.vhd \
	       ../rtl/ddr_phy.vhd \
	       ../rtl/ethcomp.vhd \
	       ../rtl/greth.vhd \
	       ../rtl/ahbuart.vhd \
	       ../rtl/ddrsp16a.vhd \
	       ../rtl/apbuart.vhd \
	       ../rtl/ddrspa.vhd \
	       ../rtl/greth_rx.vhd \
	       ../rtl/apbvga.vhd \
	       ../rtl/eth_ahb_mst.vhd \
	       ../rtl/greth_tx.vhd \
	       ../rtl/charrom.vhd \
	       ../rtl/eth_rstgen.vhd \
	       ../rtl/grethc.vhd \
	       ../rtl/ahbrom.vhd \
	       ../rtl/i2cmst.vhd \
	       ../rtl/grgpio.vhd

rtl_tb_files = ../rtl_tb/sim.vhd

vhdlfiles    = $(rtl_files) $(rtl_tb_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)

all: compile

remake: lib compile

compile: lib deplibs $(vhdltargets)

deplibs:
	make compile --directory ../../techmap/sim
	make compile --directory ../../grlib/sim
	make compile --directory ../../opencores/sim

$(vhdltargets): $(vhdlfiles)
	vcom -quiet -2008 -work $(library) $(vhdlfiles)
	@touch .stamp


clean:
	rm -f transcript
	rm -f *.wlf
	rm -f wlf*
	rm -rf $(library)
	rm -f Makefile.$(library)

# default patterns

$(library):
	vlib $(library)

lib:	$(library)


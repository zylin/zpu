library      = gaisler
top          = 

rtl_files    = ../rtl/misc.vhd
rtl_files   += ../rtl/uart.vhd
rtl_files   += ../rtl/net.vhd
rtl_files   += ../rtl/charrom_package.vhd
rtl_files   += ../rtl/memctrl.vhd
rtl_files   += ../rtl/memoryctrl.vhd
rtl_files   += ../rtl/mctrl.vhd
rtl_files   += ../rtl/spimctrl.vhd
rtl_files   += ../rtl/grethpkg.vhd
rtl_files   += ../rtl/leon3.vhd
rtl_files   += ../rtl/libdcom.vhd
rtl_files   += ../rtl/ahbmst.vhd
rtl_files   += ../rtl/dcom.vhd
rtl_files   += ../rtl/ethernet_mac.vhd
rtl_files   += ../rtl/irqmp.vhd
rtl_files   += ../rtl/ahbram.vhd
rtl_files   += ../rtl/ahbdpram.vhd
rtl_files   += ../rtl/dcom_uart.vhd
rtl_files   += ../rtl/gptimer.vhd
rtl_files   += ../rtl/ahbstat.vhd
rtl_files   += ../rtl/ddr_phy.vhd
rtl_files   += ../rtl/ethcomp.vhd
rtl_files   += ../rtl/greth.vhd
rtl_files   += ../rtl/ahbuart.vhd
rtl_files   += ../rtl/ddrsp16a.vhd
rtl_files   += ../rtl/apbuart.vhd
rtl_files   += ../rtl/ddrspa.vhd
rtl_files   += ../rtl/greth_rx.vhd
rtl_files   += ../rtl/apbvga.vhd
rtl_files   += ../rtl/eth_ahb_mst.vhd
rtl_files   += ../rtl/greth_tx.vhd
rtl_files   += ../rtl/charrom.vhd
rtl_files   += ../rtl/eth_rstgen.vhd
rtl_files   += ../rtl/grethc.vhd
rtl_files   += ../rtl/ahbrom.vhd
rtl_files   += ../rtl/i2cmst.vhd
rtl_files   += ../rtl/grgpio.vhd

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


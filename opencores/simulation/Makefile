library      = opencores

rtl_files    = \
               ../rtl/i2c_master_bit_ctrl.vhd \
               ../rtl/i2c_master_byte_ctrl.vhd \
               ../rtl/i2coc.vhd \
               ../rtl/8b10_dec.vhd \
               ../rtl/8b10_enc.vhd \

rtl_tb_files = \
               ../rtl_tb/enc_8b10b_TB.vhd \
               ../rtl_tb/encdec_8b10b_TB.vhd \

vhdlfiles    = $(rtl_files) $(rtl_tb_files)
vhdltargets  := $(foreach n, $(vhdlfiles), ./$(library)/$(basename $(notdir $n))/_primary.dat)


all: compile

compile: lib deplibs $(vhdltargets)

simulate:
	#vsim -gui $(library).enc_8b10b_TB 
	vsim -gui $(library).endec_8b10b_TB 

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

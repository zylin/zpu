COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
OBJCOPY_OPTIONS=--strip-debug --discard-locals
DIR=..
include $(DIR)/include.mak

#OBJECTS = greth_api.o greth.o
c_files  = greth_api.c greth.c
LIBS     = ../libhal/libhal.a
LIBDIR   = ../libhal/

test_vhdl = ../../rtl/dualport_ram.vhd


all: libhal $(test_vhdl)
 
%.elf: $(LIBS) $(c_files) 
	$(CC) $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o $@ -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L$(LIBDIR) -g | ccze -A
	$(OBJDUMP) -D -S $@ > greth.lst
	$(SIZE) $@
	print_mem_zpu.sh $@

%.bin: %.elf
	$(OBJCOPY) $(OBJCOPY_OPTIONS) -O binary $< $@  

$(test_vhdl): greth.bin $(ROMGEN)
	# concat parts
	cat > $(test_vhdl) ../support/dualport_ram.vhd_header
	$(ROMGEN) greth.bin >> $(test_vhdl)
	cat >> $(test_vhdl) ../support/dualport_ram.vhd_footer

libhal:
	make --directory $(DIR)/libhal

clean:
	rm -f *.o
	rm -f *.elf
	rm -f *.bin


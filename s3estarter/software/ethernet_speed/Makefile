COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
OBJCOPY_OPTIONS=--strip-debug --discard-locals
DIR=..
include $(DIR)/include.mak

#OBJECTS=greth_api.o greth.o
c_files=greth_api.c greth.c

test_vhdl= ../../../zpu/rtl/dualport_ram.vhd


all: $(test_vhdl)
 
$(test_vhdl): greth.bin $(ROMGEN)
	# concat parts
	cat > $(test_vhdl) ../support/dualport_ram.vhd_header
	$(ROMGEN) greth.bin >> $(test_vhdl)
	cat >> $(test_vhdl) ../support/dualport_ram.vhd_footer

%.bin: %.elf
	$(OBJCOPY) $(OBJCOPY_OPTIONS) -O binary $< $@  

%.elf: $(c_files) libhal
	$(CC) $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o $@ -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L$(DIR)/libhal -g | ccze -A
	$(OBJDUMP) -D -S greth.elf > greth.lst
	$(SIZE) $@

libhal:
	cd ../libhal; make

clean:
	rm -f *.o
	rm -f *.elf
	rm -f *.bin

.phony:	libhal

DIR=..
include $(DIR)/include.mak

OBJECTS=greth_api.o greth.o

test_vhdl= ../../../zpu/rtl/dualport_ram.vhd


all: $(test_vhdl)
 
$(test_vhdl): greth.bin $(ROMGEN)
	# concat parts
	cat > $(test_vhdl) ../support/dualport_ram.vhd_header
	$(ROMGEN) greth.bin >> $(test_vhdl)
	cat >> $(test_vhdl) ../support/dualport_ram.vhd_footer

%.bin: %.elf
	$(OBJCOPY) $(OBJCOPYFLAGS) -O binary $< $@  

greth.elf: $(OBJECTS)
	$(CC) $(CFLAGS) greth_api.c greth.c -o greth.elf -L$(DIR)/libhal -lhal -Wl,--relax -Wl,--gc-sections  -g
	#$(LD) $(LDFLAGS) -o $@ -L$(DIR)/libhal --start-group $(OBJECTS) -lhal --end-group
	$(OBJDUMP) -h greth.o > greth.lst
	$(SIZE) $@

clean:
	rm -f *.o
	rm -f *.elf
	rm -f *.bin

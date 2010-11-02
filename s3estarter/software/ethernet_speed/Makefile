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
	$(CC) $(CFLAGS) greth_api.c greth.c -o greth.elf -L$(DIR)/libhal -lhal -Wl,--relax -Wl,--gc-sections -g
	#$(LD) $(LDFLAGS) -o $@ -L$(DIR)/libhal --start-group $(OBJECTS) -lhal --end-group
	$(SIZE) $@

clean:
	rm -f *.o
	rm -f *.elf
	rm -f *.bin

#COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
#ROMGEN=../support/zpuromgen
#
#all:
#	@echo "greth     - build greth"
#	@echo
#	@echo "clean     - clean up"
#
#
#test_vhdl = ../../../zpu/rtl/dualport_ram.vhd
#h_files = greth_api.h
#c_files = greth_api.h greth_api.c greth.c 
#
#
#greth: $(test_vhdl)
#
#
#greth.bin: $(c_files) $(h_files)
#	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o greth.elf -Wl,--relax -Wl,--gc-sections -Wa,-adhls=greth.lst -g
#	zpu-elf-size greth.elf
#	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary greth.elf greth.bin
#
#
#
#clean:
#	rm -f *.bin
#	rm -f *.elf
#	rm -f *.lst
#
## disable implicit rule for c files
#.SUFFIXES:
#%.c: %.w %.ch

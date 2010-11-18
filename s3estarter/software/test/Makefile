COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
OBJCOPY_OPTIONS=--strip-debug --discard-locals
ROMGEN=../support/zpuromgen

all: test

help:
	@echo "test      - build test"
	@echo
	@echo "clean     - clean up"


test_vhdl = ../../../zpu/rtl/dualport_ram.vhd
c_files = lcd-routines.c test.c 


test: $(test_vhdl)


test.bin: $(c_files)
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o test.elf -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L../libhal -Wa,-adhls=test.lst -g
	zpu-elf-size test.elf
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary test.elf test.bin

$(test_vhdl): test.bin $(ROMGEN)
	# concat parts
	cat > $(test_vhdl) ../support/dualport_ram.vhd_header
	$(ROMGEN) test.bin >> $(test_vhdl)
	cat >> $(test_vhdl) ../support/dualport_ram.vhd_footer


clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst

# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch

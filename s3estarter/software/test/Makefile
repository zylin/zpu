COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
OBJCOPY_OPTIONS=--strip-debug --discard-locals
ZPU_ROM_GEN=../support/zpuromgen

all: test

help:
	@echo "test      - build test"
	@echo
	@echo "clean     - clean up"


zpu_rom_vhdl = ../../../zpu/rtl/dualport_ram.vhd
c_files = lcd-routines.c test.c 


test: $(zpu_rom_vhdl)


test.bin: $(c_files)
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o test.elf -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L../libhal -g
	zpu-elf-size test.elf
	zpu-elf-objdump -D -S test.elf > test.lst
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary test.elf test.bin

$(zpu_rom_vhdl): test.bin $(ZPU_ROM_GEN)
	# concat parts
	cat > $(zpu_rom_vhdl) ../support/dualport_ram.vhd_header
	$(ZPU_ROM_GEN) test.bin >> $(zpu_rom_vhdl)
	cat >> $(zpu_rom_vhdl) ../support/dualport_ram.vhd_footer


clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst

# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch

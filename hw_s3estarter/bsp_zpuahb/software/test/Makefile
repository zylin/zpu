COMPILER_OPTIONS=-I../include -ffunction-sections -fdata-sections 
OBJCOPY_OPTIONS=--strip-debug --discard-locals
ZPU_ROM_GEN=../support/zpuromgen
AHB_ROM_GEN=../support/ahbrom

all: test

help:
	@echo "test      - build test"
	@echo
	@echo "clean     - clean up"


zpu_rom_vhdl = ../../rtl/dualport_ram.vhd
ahb_rom_vhdl = ../../rtl/ahbrom.vhd
c_files = lcd-routines.c test.c 
h_files = ../include/peripherie.h


test: $(zpu_rom_vhdl) $(ahb_rom_vhdl)


test.bin: $(c_files) $(h_files)
	@# test with linker script 2011-01-12
	@#zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o test.elf -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L../libhal,--script,test.ld -g

	@# normal compile command (emulate instructions)
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) -o test.elf -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L../libhal 

	@# optimized (instructions in hardware) 2011-01-13
	@#zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -abel crt0_phi.S $(c_files) -o test.elf -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-L../libhal -nostdlib 

	zpu-elf-size test.elf
	zpu-elf-objdump -D -S test.elf > test.lst
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary test.elf test.bin

$(zpu_rom_vhdl): test.bin $(ZPU_ROM_GEN)
	# concat parts
	cat > $(zpu_rom_vhdl) ../support/dualport_ram.vhd_header
	$(ZPU_ROM_GEN) test.bin >> $(zpu_rom_vhdl)
	cat >> $(zpu_rom_vhdl) ../support/dualport_ram.vhd_footer

$(ahb_rom_vhdl): test.bin $(AHB_ROM_GEN)
	$(AHB_ROM_GEN) test.bin $(ahb_rom_vhdl)


clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst

# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch

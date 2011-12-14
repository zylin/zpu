#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/Makefile $
# $Date: 2011-09-05 16:51:04 +0200 (Mo, 05. Sep 2011) $
# $Author: lange $
# $Revision: 1241 $
#

COMPILER_OPTIONS=-ffunction-sections -fdata-sections -Iinclude
OBJCOPY_OPTIONS=--strip-debug --discard-locals
ZPU_ROM_GEN=../../zpu/support/zpuromgen
AHB_ROM_GEN=../../gaisler/support/ahbrom


all: software

help:
	@echo "software  - build main software"
	@echo
	@echo "clean     - clean up"


startup = lib/crt0.S
objs    = lib/crt0.o 
lib_src = lib/premain.c lib/divmod.c lib/udivmodsi4.c
#ldflags = -nostartfiles -nostdlib -nodefaultlibs $(objs) -Wl,--relax -Wl,--gc-sections -Wl,-lhal -Wl,-Llibhal
ldflags = -nostartfiles $(objs) -Wl,--relax,--gc-sections,-lhal,-Llibhal


zpu_rom_vhdl = ../../zpu/rtl/dualport_ram.vhd
ahb_rom_vhdl = ../../gaisler/rtl/ahbrom.vhd
c_files += main.c 
c_files += monitor.c 
c_files += schedule.c
c_files += ambainfo.c 
c_files += i2c.c 
c_files += i2c_functions.c
c_files += monitor_functions.c
c_files += spi.c 
c_files += ad9854_functions.c
c_files += adc.c
c_files += rena.c
c_files += $(lib_src)
h_files = *.h include/peripherie.h


software: $(zpu_rom_vhdl) $(ahb_rom_vhdl)


main.bin: $(c_files) $(h_files) $(objs)
	make --directory libhal
	@# normal compile command (emulate instructions)
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi $(c_files) $(ldflags) -o main.elf 

	zpu-elf-size main.elf
	print_mem_zpu.sh main.elf
	zpu-elf-objdump -D -S main.elf > main.lst
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary main.elf main.bin

$(zpu_rom_vhdl): main.bin $(ZPU_ROM_GEN)
	# concat parts
	cat > $(zpu_rom_vhdl) ../../zpu/support/dualport_ram.vhd_header
	$(ZPU_ROM_GEN) main.bin >> $(zpu_rom_vhdl)
	cat >> $(zpu_rom_vhdl) ../../zpu/support/dualport_ram.vhd_footer

$(ahb_rom_vhdl): main.bin $(AHB_ROM_GEN)
	$(AHB_ROM_GEN) main.bin $(ahb_rom_vhdl)


$(startup:.S=.o): $(startup)
	zpu-elf-gcc -c $< -o $@

clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst
	rm -f *.o
	rm -f lib/*.o

# disable implicit rule for c files
.SUFFIXES:
%.c: %.w %.ch

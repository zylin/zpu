COMPILER_OPTIONS=-ffunction-sections -fdata-sections -Wl,--relax -Wl,--gc-sections
OBJCOPY_OPTIONS=--strip-debug --discard-locals

all:
	@echo "romgen    - generate zpuromgen tool"
	@echo "hello     - build example"
	@echo "test      - build test"
	@echo
	@echo "clean     - clean up"

romgen: zpuromgen.c
	gcc zpuromgen.c -o zpuromgen 


hello: romgen
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi "`pwd`/hello.c" -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
	zpu-elf-size hello.elf

	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary hello.elf hello.bin

	cat >../helloworld.vhd helloworld.vhd_header
	./zpuromgen hello.bin >>../helloworld.vhd
	cat >>../helloworld.vhd helloworld.vhd_footer

test_vhdl = ../../../zpu/rtl/dualport_ram.vhd

test: romgen
	zpu-elf-gcc $(COMPILER_OPTIONS) -O3 -phi "`pwd`/test.c" hw.c timer.c lcd-routines.c -o test.elf -Wl,--relax -Wl,--gc-sections -Wa,-adhls=test.lst -g
	zpu-elf-size test.elf
	zpu-elf-objcopy $(OBJCOPY_OPTIONS) -O binary test.elf test.bin

	cat > $(test_vhdl) dualport_ram.vhd_header
	./zpuromgen test.bin >> $(test_vhdl)
	cat >> $(test_vhdl) dualport_ram.vhd_footer


clean:
	rm -f *.bin
	rm -f *.elf
	rm -f *.lst

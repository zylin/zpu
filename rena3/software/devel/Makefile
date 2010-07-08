
all:
	@echo "romgen    - generate zpuromgen tool"
	@echo "hello     - build example"
	@echo "test      - build test"
	@echo
	@echo "clean     - clean up"

romgen:
	gcc zpuromgen.c -o zpuromgen

hello:
	zpu-elf-gcc -O3 -phi "`pwd`/hello.c" -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
	zpu-elf-objcopy -O binary hello.elf hello.bin

	cat >../helloworld.vhd helloworld.vhd_header
	./zpuromgen hello.bin >>../helloworld.vhd
	cat >>../helloworld.vhd helloworld.vhd_footer

test_vhdl = ../../rtl/dualport_ram.vhd

test:
	zpu-elf-gcc -O3 -phi "`pwd`/test.c" -o test.elf -Wl,--relax -Wl,--gc-sections  -g
	zpu-elf-objcopy -O binary test.elf test.bin

	cat > $(test_vhdl) dualport_ram.vhd_header
	./zpuromgen test.bin >> $(test_vhdl)
	cat >> $(test_vhdl) dualport_ram.vhd_footer


clean:
	rm -f *.bin
	rm -f *.elf

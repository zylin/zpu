zpu-elf-gcc -O3 -abel `pwd`/hello.c -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
zpu-elf-objdump --disassemble-all >hello.dis hello.elf
zpu-elf-objcopy -O binary hello.elf hello.bin

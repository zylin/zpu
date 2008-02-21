zpu-elf-gcc -O3 -phi `pwd`/hello.c -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
zpu-elf-objdump --disassemble-all >hello.dis hello.elf
zpu-elf-objcopy -O binary hello.elf hello.bin
java -classpath ../../../../sw/simulator/zpusim.jar com.zylin.zpu.simulator.tools.MakeRam hello.bin >hello.ram

zpu-elf-gcc -O3 -phi `pwd`/gpiotest.c -o gpiotest.elf -Wl,--relax -Wl,--gc-sections  -g
zpu-elf-objdump --disassemble-all >gpiotest.dis gpiotest.elf
zpu-elf-objcopy -O binary gpiotest.elf gpiotest.bin
java -classpath ../../../../sw/simulator/zpusim.jar com.zylin.zpu.simulator.tools.MakeRam gpiotest.bin >gpiotest.ram

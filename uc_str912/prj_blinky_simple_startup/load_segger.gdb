set complaints 1
set output-radix 16
set input-radix 16
set prompt (arm-gdb) 

target remote localhost:2331

monitor speed adaptive
monitor endian little

monitor reset
monitor flash device = STR912FAW44
monitor flash breakpoints = 1
monitor flash download = 1
monitor halt


pwd
load main.elf
file main.elf

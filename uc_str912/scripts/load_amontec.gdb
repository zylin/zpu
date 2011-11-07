set complaints 1
set output-radix 16
set input-radix 16
set prompt (arm-gdb) 

target remote localhost:3333


monitor reset init
monitor halt
monitor jtag_rclk 1000
monitor str9x flash_config 0 4 2 0x00000 0x80000
monitor flash protect 0 0 7 off
monitor flash erase_sector 0 0 7



pwd
load main.elf
#load test_led.elf

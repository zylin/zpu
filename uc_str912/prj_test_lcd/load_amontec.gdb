set complaints 1
set output-radix 16
set input-radix 16
set prompt (arm-gdb) 

set remote hardware-breakpoint-limit 2
set remote hardware-watchpoint-limit 2

target remote localhost:3333

monitor reset init
monitor halt

load lcd.elf
file lcd.elf

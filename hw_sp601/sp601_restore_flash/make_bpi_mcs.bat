
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_uart/hello_uart.elf hello_uart.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_gpio/hello_gpio.elf hello_gpio.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_timer/hello_timer.elf hello_timer.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_flash/hello_flash.elf hello_flash.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_iic/hello_iic.elf hello_iic.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_emac/hello_emac.elf hello_emac.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_switch/hello_switch.elf hello_switch.elf.srec"
xbash -q -c "export PATH=/usr/local/bin:/usr/bin:/bin:$PATH;mb-objcopy -O srec ../sp601_bist/hello_mem/hello_mem.elf hello_mem.elf.srec"

promgen -w -p bin -b -c FF -o download.bin -u 0 C:\sp601_bist\implementation\download.bit
promgen -w -p bin -o hello_uart.elf.srec -data_file up 0 hello_uart.elf.srec
promgen -w -p bin -o hello_gpio.elf.srec -data_file up 0 hello_gpio.elf.srec
promgen -w -p bin -o hello_timer.elf.srec -data_file up 0 hello_timer.elf.srec
promgen -w -p bin -o hello_flash.elf.srec -data_file up 0 hello_flash.elf.srec
promgen -w -p bin -o hello_iic.elf.srec -data_file up 0 hello_iic.elf.srec
promgen -w -p bin -o hello_emac.elf.srec -data_file up 0 hello_emac.elf.srec
promgen -w -p bin -o hello_switch.elf.srec -data_file up 0 hello_switch.elf.srec
promgen -w -p bin -o hello_mem.elf.srec -data_file up 0 hello_mem.elf.srec

promgen -w -p mcs -c FF -o SP601_J3D_BIST -s 16384 -data_file up 0 download.bin -data_file up 120000 hello_uart.elf.bin -data_file up 140000 hello_gpio.elf.bin -data_file up 160000 hello_timer.elf.bin -data_file up 180000 hello_flash.elf.bin -data_file up 1a0000 hello_iic.elf.bin -data_file up 1c0000 hello_emac.elf.bin -data_file up 1e0000 hello_switch.elf.bin -data_file up 200000 hello_mem.elf.bin


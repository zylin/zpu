all:	erase

erase:	erase.o erase_jlink.gdb
	arm-none-eabi-gdb -x erase_jlink.gdb

erase.o: erase.S
	arm-none-eabi-as erase.S -o erase.o

clean:
	rm -f erase.o

PRJ      =  test1
PATH_SW  =  /home/antonan/desarrollo/zpu/sw
INCLUDES =  $(PATH_SW)/freertos/Source/portable/GCC/ZPU/portmacro.h \
		 	FreeRTOSConfig.h
SRCS_C   =  $(PATH_SW)/freertos/Source/portable/GCC/ZPU/port.c \
			$(PATH_SW)/freertos/Source/portable/MemMang/heap_1.c \
		    $(PATH_SW)/freertos/Source/croutine.c \
			$(PATH_SW)/freertos/Source/list.c \
			$(PATH_SW)/freertos/Source/queue.c \
			$(PATH_SW)/freertos/Source/tasks.c \
			test1.c
SRCS_ASM =  $(PATH_SW)/freertos/Source/portable/GCC/ZPU/portasm.s
PATH_INC = -I$(PATH_SW)/include \
		   -I$(PATH_SW)/freertos/Source/include \
		   -I$(PATH_SW)/freertos/Source/portable/GCC/ZPU \
		   -I$(PATH_SW)/freertos/Demo/ZPU \
		   -I.
OPTIONS  = -g -Os -DGCC_ZPU 
LINK 	 = -T $(PATH_SW)/ldscripts/zpu-sram.ld
CRT      =  $(PATH_SW)/startup/crt-sram.o
LLIB     = -L $(PATH_SW)/lib
LIBS     = -lio -lgcc --start-group -lc -lbcc --end-group -lgcc -lio
LFLAGS   = --relax --gc-sections

OBJS_ASM = $(SRCS_ASM:.s=.o)
OBJS_C   = $(SRCS_C:.c=.o)

$(PRJ).srec: $(PRJ).out
	zpu-elf-objcopy -O srec $(PRJ).out $(PRJ).srec
	zpu-elf-objcopy -O binary $(PRJ).out $(PRJ).bin
	bin2rom $(PRJ).bin $(PRJ).rom

$(OBJS_ASM): $(SRCS_ASM)
	zpu-elf-gcc $(OPTIONS) $(PATH_INC) -B. -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.s)

$(OBJS_C): $(SRCS_C) $(INCLUDES)
	zpu-elf-gcc $(OPTIONS) $(PATH_INC) -B. -c -Wa,-ahlms=$(@:.o=.lst) -o $@ $(@:.o=.c)

$(PRJ).out: $(CRT) $(OBJS_C) $(OBJS_ASM)
	zpu-elf-ld $(LLIB) $(LFLAGS) $(LINK) -Map=$(PRJ).map -o $(PRJ).out $(CRT) $(OBJS_C) $(OBJS_ASM) $(LIBS)


clean:
	-rm *.o
	-rm *.out
	-rm *.bin
	-rm *.map
	-rm *.lst
	-rm *.srec
	-rm *.rom

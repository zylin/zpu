# efsl library Makefile for STR910 by Giacomo Fazio and Antonio Nasca
# (based on efsl library makefile for AT91SAM7S by Martin Thomas)


MCU   = arm9e
#THUMB = -mthumb -mthumb-interwork
THUMB = 

LIBNAME = libSTR91x_lib.a

COPT= -mcpu=$(MCU) $(THUMB) -gdwarf-2 -Wall -Os 
INCLUDEDIRS=-Iinclude
CFLAGS=$(COPT) $(INCLUDEDIRS)
# gcc4 unused code-removal:
CFLAGS += -ffunction-sections -fdata-sections

CC=arm-elf-gcc
AR=arm-elf-ar
OBJCOPY=arm-elf-objcopy

OBJ=src/91x_adc.o       src/91x_ahbapb.o       src/91x_can.o      src/91x_dma.o
OBJ+=src/91x_emi.o      src/91x_fmi.o          src/91x_gpio.o     src/91x_i2c.o      src/91x_lib.o     src/91x_mc.o
OBJ+=src/91x_rtc.o      src/91x_scu.o          src/91x_ssp.o      src/91x_tim.o
OBJ+=src/91x_wdg.o      src/91x_wiu.o          src/91x_uart.o     src/91x_vic.o


all: lib

libandclean: lib srcclean

lib: $(OBJ)
	$(AR) rcs $(LIBNAME) $(OBJ)
	
srcclean :
	rm -f $(OBJ)

clean :
	rm -f $(OBJ) $(LIBNAME)

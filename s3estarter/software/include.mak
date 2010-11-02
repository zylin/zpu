AS=zpu-elf-as
CC=zpu-elf-gcc
LD=zpu-elf-ld
OBJCOPY=zpu-elf-objcopy
AR=zpu-elf-ar
RANLIB=zpu-elf-ranlib
SIZE=zpu-elf-size

ROMGEN=$(DIR)/support/zpuromgen

INLCUDES=-I$(DIR)/include
ASFLAGS=-adhls -g $(INLCUDES)
CFLAGS=-O3 -phi -Wall -ffunction-sections -fdata-sections $(INLCUDES)
LDFLAGS=--relax --gc-sections
OBJCOPYFLAGS=--strip-debug --discard-locals

PROJECTNAME = net_test
OUT= output
ECOS_DIR=$(OUT)/ecos
INSTALL_DIR=$(ECOS_DIR)/install

.symbolic: all clean  ecos

all: ecos app 	



clean:
	rm -rf $(OUT)/*

$(OUT):
	mkdir $(OUT)

$(ECOS_DIR)/ecos.ecc $(INSTALL_DIR)/include/pkgconf/ecos.mak:
	mkdir -p $(ECOS_DIR)
	cd $(ECOS_DIR) && ecosconfig new zpuetherphi minimal
	cd $(ECOS_DIR) && ecosconfig import ../../$(PROJECTNAME).ecm
	cd $(ECOS_DIR) && ecosconfig tree
	cd $(ECOS_DIR) && make -s headers
	
$(OUT)/ecostree: $(ECOS_DIR)/ecos.ecc
	cd $(ECOS_DIR) && ecosconfig tree
	echo >$(OUT)/ecostree

ecos   $(INSTALL_DIR)/lib/libtarget.a $(INSTALL_DIR)/lib/vectors.o: $(OUT)/ecostree 
	cd $(ECOS_DIR) && make -s

app: 
	make -f $(INSTALL_DIR)/include/pkgconf/ecos.mak -f makefile $(OUT)/$(PROJECTNAME).bin

$(OUT)/$(PROJECTNAME).bin: *.c makefile 
	zpu-elf-gcc -I$(INSTALL_DIR)/include $(ECOS_GLOBAL_CFLAGS) $(ECOS_GLOBAL_LDFLAGS)  -L$(INSTALL_DIR)/lib *.c* -o $(OUT)/$(PROJECTNAME).elf  -Wl,-Map,$(OUT)/$(PROJECTNAME).map -nostartfiles -nostdlib -Ttarget.ld   -lstdc++  -lsupc++ 
	zpu-elf-objcopy -O binary $(OUT)/$(PROJECTNAME).elf $(OUT)/$(PROJECTNAME).bin
	sh ../build/makefirmware.sh $(OUT)/$(PROJECTNAME).bin $(OUT)/$(PROJECTNAME).zpu 
	zpu-elf-size $(OUT)/$(PROJECTNAME).elf

	
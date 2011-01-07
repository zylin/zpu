MODULE = top
DEVICE = xc3s500e-fg320-4
#UCF_FILE = D:/home/bl5599/projects/s3estarter/syn/s3estarter.ucf
UCF_FILE = s3estarter.ucf

SOFTWARE = ../software/ethernet_speed
#SOFTWARE = ../software/test


all:	
	@echo "check     - look for timing and other synthesis issues"
	@echo "xst       - generate ??? file"
	@echo "translate - generate ngd file"
	@echo "map       - generate ncd file"
	@echo "par       - place&route ncd file"
	@echo "trace     - generate timing report"
	@echo "bitgen    - generate bit file"
	@echo "update    - update bitstream with elf file"
	@echo "program   - program fpga with bit file"
	@echo "genmcs    - genrate mcs file"
	@echo "progspi   - program spi flash with mcs file"
	@echo "clean"
	@echo "..."
	@echo "testflow  - bitgen update program check"
	@echo "finalflow - bitgen update progspi check"

testflow: bitgen update program check

finalflow: bitgen update progspi check


check:
	@echo -e "Timing score: "
	@grep --with-filename "Timing Score"            xst/*.par
	@echo -e "\nUnwanted Latches: "
	@-grep --with-filename --count "WARNING:Xst:737" xst/*.syr
	@echo -e "\nUnassigned signals: "
	@-grep --with-filename "WARNING:Xst:653"         xst/*.syr


update:
	make all --directory $(SOFTWARE)
	data2mem -bm zpu_i0_memory.bmm -bd $(SOFTWARE)/*.elf -bt xst/$(MODULE).bit -o b xst/$(MODULE)_update.bit


program:
	impact -batch impact.cmd


genmcs:
	promgen -spi -p mcs -w -o $(MODULE)_update.mcs -s 8192 -u 0 xst/$(MODULE)_update.bit


progspi: genmcs
	impact -batch prog_spi.cmd


clean:
	rm -f *.log
	rm _impact.cmd


dir:	
	mkdir -p xst
	mkdir -p xst/projnav.tmp
	#cp *.xst xst
	#cp *.prj xst

xst:    $(MODULE).ngc
translate: $(MODULE).ngd
map:    $(MODULE)_map.ncd
par:    $(MODULE).ncd

#.PHONY: xst

$(MODULE).ngc: dir	
	cd xst ; xst -ifn $(MODULE).xst -ofn $(MODULE).syr


$(MODULE).ngd: $(MODULE).ngc $(UCF_FILE)
	cd xst ; ngdbuild -dd _ngo -nt timestamp -uc ../$(UCF_FILE) -p $(DEVICE) $(MODULE).ngc $(MODULE).ngd


$(MODULE)_map.ncd: $(MODULE).ngd
	cd xst ; map -p $(DEVICE) -cm speed -detail -ir off -pr off -c 100 -o $(MODULE)_map.ncd $(MODULE).ngd $(MODULE).pcf


$(MODULE).ncd: $(MODULE)_map.ncd
	cd xst ; par -w -ol high -t 1 $(MODULE)_map.ncd $(MODULE).ncd $(MODULE).pcf


trace: $(MODULE).ncd	
	cd xst ; trce -e -a -u -s 4 -xml $(MODULE).twx $(MODULE).ncd -o $(MODULE).twr $(MODULE).pcf


bitgen: $(MODULE).ncd
	cd xst ; bitgen -intstyle ise -f $(MODULE).ut $(MODULE).ncd



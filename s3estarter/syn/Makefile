
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

check:
	@echo -e "Timing score: "
	@grep --with-filename "Timing Score"            xst/*.par
	@echo -e "\nUnwanted Latches: "
	@-grep --with-filename --count "WARNING:Xst:737" xst/*.syr
	@echo -e "\nUnassigned signals: "
	@-grep --with-filename "WARNING:Xst:653"         xst/*.syr

update:
	make test --directory ../../rena3/software/devel
	data2mem -bm zpu_i0_memory.bmm -bd ../../rena3/software/devel/test.elf -bt xst/top.bit -o b xst/top_update.bit

program:
	impact -batch impact.cmd

genmcs:
	promgen -spi -p mcs -w -o top_update.mcs -s 8192 -u 0 xst/top_update.bit

progspi: genmcs
	impact -batch prog_spi.cmd

clean:
	rm -f *.log
	rm _impact.cmd

dir:	
	mkdir -p xst

.PHONY: xst
xst:	
	cd xst ; xst -intstyle ise -ifn "D:/home/bl5599/projects/s3estarter/syn/xst/top.xst" -ofn "D:/home/bl5599/projects/s3estarter/syn/xst/top.syr"
	
translate: xst
	cd xst ; ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc D:/home/bl5599/projects/s3estarter/syn/s3estarter.ucf -p xc3s500e-fg320-4 top.ngc top.ngd
	
map: translate
	cd xst ; map -intstyle ise -p xc3s500e-fg320-4 -cm area -detail -ir off -pr off -c 100 -o top_map.ncd top.ngd top.pcf
	
par: map	
	cd xst ; par -w -intstyle ise -ol high -t 1 top_map.ncd top.ncd top.pcf
	
trace: par	
	cd xst ; trce -intstyle ise -v 3 -s 5 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf
	
bitgen: par
	cd xst ; bitgen -intstyle ise -f top.ut top.ncd

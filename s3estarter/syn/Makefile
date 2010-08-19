
all:	
	@echo "check   - look for timing and other synthesis issues"
	@echo "update  - update bitstream with elf file"
	@echo "program - program fpga with bit file"
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

clean:
	rm -f *.log
	rm _impact.cmd

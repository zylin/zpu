
all:	
	@echo "program - program fpga with bit file"
	@echo "check   - look for timing and other synthesis issues"
	@echo "clean"
	@echo "..."

check:
	@echo -e "Timing score: "
	@grep --with-filename "Timing Score"            xst/*.par
	@echo -e "\nUnwanted Latches: "
	@-grep --with-filename --count "WARNING:Xst:737" xst/*.syr
	@echo -e "\nUnassigned signals: "
	@-grep --with-filename "WARNING:Xst:653"         xst/*.syr

program:
	impact -batch impact.cmd

clean:
	rm -f *.log

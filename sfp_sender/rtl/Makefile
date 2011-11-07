#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601_amba/rtl/Makefile $
# $Date: 2011-08-16 10:22:19 +0200 (Di, 16. Aug 2011) $
# $Author: lange $
# $Revision: 1196 $
#


DATE = $(shell date +"%b %d %Y  %X")
LENGTH = $(shell expr length "$(DATE)")


all: version.vhd
	

.PHONY: version.vhd
version.vhd:
	@echo "updating $@ ($(DATE))"
	@rm -f $@
	@echo "package version is"                                                    >> $@
	@echo ""                                                                      >> $@
	@echo "    constant version_time_c : string( 1 to $(LENGTH)) := \"$(DATE)\";" >> $@
	@echo ""                                                                      >> $@
	@echo "end package version;"                                                  >> $@


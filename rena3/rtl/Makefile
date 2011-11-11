#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp605/rtl/Makefile $
# $Date: 2011-09-01 15:07:37 +0200 (Do, 01. Sep 2011) $
# $Author: lange $
# $Revision: 1237 $
#


DATE = $(shell date +"%b %e %Y  %X")
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


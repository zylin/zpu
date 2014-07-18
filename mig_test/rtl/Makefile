#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWF_Internals/FPGA/hw_sp601/bsp_zpuahb/rtl/Makefile $
# $Date$
# $Author$
# $Revision$
#


DATE = $(shell date +"%b %e %Y  %X")
DATELENGTH = $(shell expr length "$(DATE)")

SVNREV = $(shell svnversion | awk '{printf "%-21s", $$0}')
SVNLENGTH = $(shell expr length "$(SVNREV)")


all: timestamp.vhd
	
timestamp.vhd:
	@echo "updating $@ ($(DATE); $(SVNREV))"
	@rm -f $@
	@echo "package timestamp is"                                                       >> $@
	@echo ""                                                                           >> $@
	@echo "    constant version_time_c : string( 1 to $(DATELENGTH)) := \"$(DATE)\";"  >> $@
	@echo "    constant svnrevision_c  : string( 1 to $(SVNLENGTH)) := \"$(SVNREV)\";" >> $@
	@echo ""                                                                           >> $@
	@echo "end package timestamp;"                                                     >> $@


clean:
	rm timestamp.vhd

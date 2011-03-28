#TOP        = top
#DIR        = ../s3estarter/syn/xst
#SCREENSHOT = s3estarter_ressources

#TOP        = spartan6_top
#DIR        = ../beam_position_monitor/hardware/board_sp601/synthese/xst
#SCREENSHOT = bpm_ressources

TOP        = top
DIR        = ../central_trigger_generator/syn/xst
SCREENSHOT = central_trigger_ressources


# derived Variables
MAPREPORTXML = $(DIR)/$(TOP)_map.xrpt 
MAPREPORT    = $(DIR)/$(TOP)_map.mrp


start = $(shell grep --line-number  "^Logic Utilization:" $(DIR)/$(TOP)_map.mrp | cut -d":" -f1)
end   = $(shell grep --line-number  "^Peak Memory Usage:" $(DIR)/$(TOP)_map.mrp | cut -d":" -f1)


help:
	@echo "run     - run Treeviz"
	@echo "convert - convert data (on unix)"
	@echo "util    - grep for utilization"
	@echo "combine - two screenshots for better overview"
	@echo "clean   - tidy up"

run:	ressources.xml
	@echo "save screeshot as $(SCREENSHOT)_grob.png and $(SCREENSHOT)_fein.png"
	java -jar Treeviz/dist/Treeviz.jar $<

convert: ressources.xml


# useful for printing with graphic report
# cut lines beetween "Logic Utilization" and "Average Fanout..."
util: $(MAPREPORT)
	@sed -n '/Logic Utilization:/,/^Average Fanout of Non-Clock Nets:/p' $(MAPREPORT)

# not so useful -> confusing if hierachy to deep
# cut lines from "Section 13" (2nd occurence) and end of file
util_hier: $(MAPREPORT)
	@tail -n +$(shell grep --line-number  "^Section 13" $(MAPREPORT) | tail -1 | cut -d":" -f1) $(MAPREPORT)



ressources.xml: $(MAPREPORTXML) convert.xsl
	saxon-xslt $(MAPREPORTXML)  convert.xsl > tmp.xml
	# prune empty lines with sed
	sed -e '/^[ ]*$$/d' tmp.xml > ressources.xml
	# cleanup
	rm -f tmp.xml


combine: $(SCREENSHOT)_fein.png $(SCREENSHOT)_grob.png
	composite -blend 33 $(SCREENSHOT)_fein.png $(SCREENSHOT)_grob.png $(SCREENSHOT)_mixed.png


clean:
	rm -f ressources.xml


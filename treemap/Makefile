

help:
	@echo "run     - run Treeviz"
	@echo "convert - convert data"
	@echo "clean   - tidy up"

run:	ressources.xml
	java -jar Treeviz/dist/Treeviz.jar $*

convert: ressources.xml

ressources.xml:
	saxon-xslt ../s3estarter/syn/xst/top_map.xrpt convert.xsl > tmp.xml
	# prune empty lines with sed
	sed -e '/^[ ]*$$/d' tmp.xml > ressources.xml


clean:
	rm -f tmp.xml
	rm -f ressources.xml


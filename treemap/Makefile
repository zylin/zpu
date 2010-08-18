

help:
	@echo "run     - run Treeviz"
	@echo "convert - convert data"
	@echo "get     - copy map report from syn directory"
	@echo "clean   - tidy up"

run:	ressources.xml
	java -jar Treeviz/dist/Treeviz.jar $*

convert: ressources.xml

ressources.xml:
	saxon-xslt top_map.xrpt convert.xsl > tmp.xml
	sed -e '/^[ ]*$$/d' tmp.xml > ressources.xml

get:
	cp ../s3estarter/syn/xst/top_map.xrpt . 

clean:
	rm -f tmp.xml
	rm -f ressources.xml


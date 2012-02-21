
all:
	@echo "romgen    - generate zpuromgen tool"
	@echo "ahbrom    - generate ahbrom tool"
	@echo
	@echo "clean     - clean up"

romgen: zpuromgen.c
	gcc zpuromgen.c -o zpuromgen 

ahbrom: ahbrom.c
	gcc ahbrom.c -o ahbrom


clean:
	rm -f *.exe

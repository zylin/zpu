library      = zpu




help:
	@echo "defined targets:"
	@echo
	@echo "simulate  - simulation"
	@echo "compile   - ..."
	@echo "clean     - clean up"
	@echo



compile: Makefile.msim
	export ANAFLAGS="-quiet -2008"; \
	make -f Makefile.msim | ccze -A

simulate:
	export top=$(top); \
	vsim -quiet -gui -do run.do  -l transcript.log

clean:
	rm -rf $(library) 
	rm -f transcript.log
	rm -f *.wlf
	rm -f trace.txt
	rm -f log.txt
	make -f Makefile.msim clean
	rm -rf grlib
	rm -rf zpu 
	rm -f Makefile.msim
	rm -f .stamp

# generate Makefile.msim with vmk
Makefile.msim: vhdl_files.txt
	vlib zpu 
	vlib grlib
	vmk -t modelsim -O -w $(library) -F vhdl_files.txt
	

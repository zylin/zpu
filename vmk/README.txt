Tool um automatisch Abhängikeiten von vhdl-Files zu erzeugen

Vorteil gegenüber vmake (von ModelSim): Braucht keine initiale Kompilierung

Download mittels:
cvs -d:pserver:anonymous@vmk.cvs.sourceforge.net:/cvsroot/vmk login 
cvs -z3 -d:pserver:anonymous@vmk.cvs.sourceforge.net:/cvsroot/vmk co -P vmk


vmk  -t modelsim -w grlib  ../rtl/*.vhd ../rtl_tb/*.vhd > Makefile.vmk

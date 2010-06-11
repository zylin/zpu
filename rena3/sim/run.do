#restart -f


proc nsng {} {

restart -f
set StdArithNoWarnings 1
set NumericStdNoWarnings  1

when -label enable_Warn {reset == '0'} {echo "Enable Warnings" ; set StdArithNoWarnings 0 ; set NumericStdNoWarnings 0 ;}

run -all
}

do wave.do

run -all

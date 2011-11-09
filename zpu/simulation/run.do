#
# helper functions
#


# neues Spiel, neues Glueck
proc nsng {} {

    restart -f
    set StdArithNoWarnings 1
    set NumericStdNoWarnings  1

    when -label enable_Warn {reset == '0'} {echo "Enable Warnings" ; set StdArithNoWarnings 0 ; set NumericStdNoWarnings 0 ;}

    run -all
}


proc r {} {
    restart -f
    run -all
}


proc my_debug {} {
    global env
    foreach key [array names env] {
        puts "$key=$env($key)"
    }
}


proc e {} {
    exit -force
}

proc x {} {
    exit -force
}


#
# run ZPU simulation
#

vsim -quiet zpu.sim_small_fpga_top_noint

source wave.do

set StdArithNoWarnings 1
set NumericStdNoWarnings  1

when -label enable_StdWarn {reset == '0'} {echo "Enable StdArithWarnings" ; set StdArithNoWarnings 0 ;}
when -label enable_StdWarn {reset == '0'} {echo "Enable NumericStdWarnings" ; set NumericStdNoWarnings 0 ;}


run 5 ms

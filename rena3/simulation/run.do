
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


# restart with clear
proc rc {} {
    .main clear
    r
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




# get env variables
global env
quietly set top $env(top)


if {[file exists wave_$top.do]} {
    do wave_$top.do
} else {
    if {[file exists wave.do]} {
        do wave.do
    } else {
        puts "INFO: no wave file found."
    }
}


run -all


#
# helper functions
#

# restart + run
proc r {} {
    restart -f
    set sim_start [clock seconds]
    
    run -all
    
    puts "# simulation run time: [clock format [expr  [clock seconds] - $sim_start] -gmt 1 -format %H:%M:%S] "
}


# restart with clear
proc rc {} {
    .main clear
    r
}

# print varables
proc my_debug {} {
    global env
    foreach key [array names env] {
        puts "$key=$env($key)"
    }
}


# fast exit
proc e {} {
    exit -force
}

# fast exit
proc x {} {
    exit -force
}


# get env variables
global env
quietly set top $env(top)


if {[file exists wave.do]} {
    do wave.do
} else {
    if {[file exists wave_$top.do]} {
        do wave_$top.do
    } else {
        puts "INFO: no wave file (wave_$top.do) found"
    }
    puts "INFO: no wave file (wave.do) found"
}



set sim_start [clock seconds]

run -all

puts "# simulation run time: [clock format [expr  [clock seconds] - $sim_start] -gmt 1 -format %H:%M:%S] "

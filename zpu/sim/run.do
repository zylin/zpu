#restart -f

#
# generate library
#
vlib zpu


#
# compile stuff
#

quietly set vcom_lib zpu
quietly set vcom_options -quiet

vcom -work $vcom_lib $vcom_options ../rtl_tb/txt_util.vhd

vcom -work $vcom_lib $vcom_options ../rtl/zpu_config.vhd
vcom -work $vcom_lib $vcom_options ../rtl/zpupkg.vhd
vcom -work $vcom_lib $vcom_options ../rtl/*.vhd


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


#
# run ZPU simulation
#

vsim -quiet zpu.fpga_top

source wave.do

set StdArithNoWarnings 1
set NumericStdNoWarnings  1

when -label enable_StdWarn {areset == '0'} {echo "Enable StdArithWarnings" ; set StdArithNoWarnings 0 ;}
when -label enable_StdWarn {areset == '0'} {echo "Enable NumericStdWarnings" ; set NumericStdNoWarnings 0 ;}


run 5 ms

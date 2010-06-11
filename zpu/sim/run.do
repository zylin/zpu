#restart -f

vlib zpu

set vcom_lib zpu
set vcom_options -quiet

vcom -work $vcom_lib $vcom_options ../rtl_tb/txt_util.vhd

vcom -work $vcom_lib $vcom_options ../rtl/zpu_config.vhd
vcom -work $vcom_lib $vcom_options ../rtl/zpupkg.vhd
vcom -work $vcom_lib $vcom_options ../rtl/*.vhd


# run ZPU
vsim -quiet zpu.fpga_top

source wave.do

set StdArithNoWarnings 1
set NumericStdNoWarnings  1

when -label enable_StdWarn {areset == '0'} {echo "Enable StdArithWarnings" ; set StdArithNoWarnings 0 ;}
when -label enable_StdWarn {areset == '0'} {echo "Enable NumericStdWarnings" ; set NumericStdNoWarnings 0 ;}


run 5 ms

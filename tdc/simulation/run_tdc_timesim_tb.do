proc r {} {
	restart -f;
	run -all
}

proc x {} {
	exit -force
}


do wave_tdc_timesim_tb.do
run -all

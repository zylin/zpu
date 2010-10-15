proc r {} {
	restart -f;
	run -all
}

proc x {} {
	exit -force
}


do wave_thermometer_coder_tb.do
run -all

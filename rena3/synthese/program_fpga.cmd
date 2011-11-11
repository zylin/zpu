setMode -bscan
#setCable -port auto
setCable -port usb21
Identify
#assignFile -p 2 -file "xst/top.bit"
assignFile -p 2 -file "xst/top_update.bit"
Program -p 2 
closeCable
quit

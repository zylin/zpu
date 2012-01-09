setMode -bscan
#setCable -port auto
setCable -port usb21
Identify
#assignFile -p 2 -file "top.bit"
assignFile -p 2 -file "top_update.bit"
Program -p 2 
closeCable
quit

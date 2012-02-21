setMode -bscan
#setCable -port auto
setCable -port usb21
Identify
assignFile -p 1 -file "top_update.bit"
Program -p 1 
closeCable
quit

setMode -bscan
setCable -port auto
Identify
assignFile -p 2 -file "top_update.bit"
Program -p 2 
closeCable
quit

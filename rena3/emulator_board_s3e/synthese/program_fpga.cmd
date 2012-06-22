setMode -bscan
setCable -port auto
Identify
assignFile -p 1 -file "top_update.bit"
Program -p 1 
closeCable
quit

setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
assignFile -p 1 -file "top_update.bit"
Program -p 1 
quit

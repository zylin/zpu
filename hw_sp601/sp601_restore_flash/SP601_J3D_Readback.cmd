setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
attachflash -position 1 -bpi "28F128J3D"
assignfiletoattachedflash -position 1 -file "SP601_J3D_all.mcs"
ReadbackToFile -p 1 -file "SP601_J3D_Readback.mcs" -bpionly 
quit

setMode -bs
setCable -p auto
identify
identifyMPM 
attachflash -position 1 -bpi "28F128J3D"
assignfiletoattachedflash -position 1 -file "SP601_J3D_BIST.mcs"
Verify -p 1 -bpionly
closeCable
quit

setMode -bs
setCable -p auto
identify
identifyMPM
attachflash -position 1 -bpi "28F128J3D"
assignfiletoattachedflash -position 1 -file "SP601_J3D_BIST.mcs"
Program -p 1 -bpionly -e -loadfpga
closeCable
quit

setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 2 -spi "W25Q64BV"
assignfiletoattachedflash -position 2 -file "top_update.mcs"
Program -p 2 -dataWidth 4 -spionly -e -v -loadfpga 
closeCable
quit

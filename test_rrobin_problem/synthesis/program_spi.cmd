setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 1 -spi "W25Q64BV"
assignfiletoattachedflash -position 1 -file "top_update.mcs"
Program -p 1 -dataWidth 4 -spionly -e -v -loadfpga 
closeCable
quit

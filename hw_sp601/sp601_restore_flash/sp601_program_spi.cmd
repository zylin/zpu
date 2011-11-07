setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 1 -spi "W25Q64BV"
assignfiletoattachedflash -position 1 -file "SP601_SPI_BRD_v2_0.mcs"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
closeCable
quit

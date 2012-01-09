setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 1 -spi "M25P16"
assignfiletoattachedflash -position 1 -file "D:/home/bl5599/projects/s3estarter/syn/top_update.mcs"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
quit

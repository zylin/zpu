setMode -bs
setCable -p auto
identify
attachFlash -p 1 -spi w25q64bv
assignFileToAttachedFlash -p 1 -file SP601_W25Q64BV_all.mcs
ReadbackToFile -p 1 -file "SP601_W25Q64BV_Readback.mcs" -spionly 
closeCable
quit

setMode -bs
setCable -p auto
identify
attachFlash -p 1 -spi w25q64bv
assignFileToAttachedFlash -p 1 -file SP601_SPI_BRD_v2_0.mcs
Verify -p 1 -spionly
closeCable
quit

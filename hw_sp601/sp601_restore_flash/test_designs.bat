:: Updates only the files that change; doesn't recreate the blank mcs files.

call make_bpi_mcs.bat
call make_spi_mcs.bat

impact -batch sp601_program_bpi.cmd

impact -batch SP601_J3D_BIST_Verify.cmd
impact -batch SP601_J3D_Readback.cmd
move /Y SP601_J3D_Readback.mcs SP601_J3D_all.mcs

impact -batch sp601_program_spi.cmd

impact -batch SP601_SPI_BRD_v2.0_Verify.cmd
impact -batch SP601_W25Q64BV_Readback.cmd
move /Y SP601_W25Q64BV_Readback.mcs SP601_W25Q64BV_all.mcs


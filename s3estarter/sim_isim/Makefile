library      = s3estarter
top          = top_tb


all: compile simulate


compile:
	vhpcomp  --work global      ../../global/rtl/*.vhd
	vhpcomp  --work grlib       ../../grlib/rtl/version.vhd ../../grlib/rtl/stdlib.vhd ../../grlib/rtl/amba.vhd ../../grlib/rtl/devices.vhd ../../grlib/rtl/*.vhd
	vhpcomp  --work grlib       ../../grlib/rtl_tb/*.vhd
	vhpcomp  --work techmap     ../../techmap/rtl/gencomp.vhd ../../techmap/rtl/ddr_unisim.vhd ../../techmap/rtl/*.vhd
	vhpcomp  --work gaisler     ../../gaisler/rtl/misc.vhd ../../gaisler/rtl/uart.vhd ../../gaisler/rtl/charrom_package.vhd ../../gaisler/rtl/memctrl.vhd  ../../gaisler/rtl/greth_pkg.vhd  ../../gaisler/rtl/net.vhd ../../gaisler/rtl/*.vhd
	vhpcomp  --work gaisler     ../../gaisler/rtl_tb/*.vhd
	vhpcomp  --work zpu         ../../zpu/rtl_tb/txt_util.vhd ../../zpu/rtl/zpu_config.vhd ../../zpu/rtl/zpupkg.vhd ../../zpu/rtl/zpu_wrapper_package.vhd ../../zpu/rtl/*.vhd
	vhpcomp  --work s3estarter  ../rtl/fpga_types.vhd ../rtl/fpga_components.vhd ../rtl/*.vhd
	vlogcomp --work s3estarter --include ../rtl_tb/ --define sg6 --define x16 ../rtl_tb/ddr.v
	vhpcomp  --work s3estarter  ../rtl_tb/*.vhd

simulate:
	fuse --incremental -o tb.exe   $(library).$(top)
	cmd /c "c:\Program_Files_BLa\Xilinx\12.2\ISE_DS\settings64.bat; tb -gui -tclbatch run.do -view wave.wcfg"


clean:
	rm -rf isim
	rm -f fuse.log
	rm -f isim.log
	rm -f isim.wdb
	rm -f tb.exe



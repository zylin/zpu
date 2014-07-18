#
# $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/trunk/hardware/board_prototyp1/synthesis/Makefile $
# $Date$
# $Author$
# $Revision$
#

MODULE = top
DEVICE = xc6slx100
SPEEDGRADE = 2
PACKAGE = fgg484
UCF_FILE = top.ucf
CORES = ../cores/
SOFTWARE = ../software
BMM_FILE = zpu.bmm
BMM_BD_FILE = zpu_bd.bmm

BUILDDIR = isebuild
DEVICE_DPS = $(DEVICE)-$(PACKAGE)-$(SPEEDGRADE)
DATE = $(shell date +"%Y-%m-%d__%H_%M")
LOGFILE = synthesis_log_$(DATE).txt
export XST_LOGFILE := $(LOGFILE)


define XST_FILE
set -tmpdir "projnav.tmp"
set -xsthdpdir "xst"
run
-ifn ../$(MODULE).prj
-ifmt mixed
-ofn $(MODULE)
-ofmt NGC
-p $(DEVICE)-$(SPEEDGRADE)-$(PACKAGE)
-top $(MODULE)
-opt_mode Speed
-opt_level 1
-power NO
-iuc NO
-keep_hierarchy No
-netlist_hierarchy As_Optimized
-rtlview Yes
-glob_opt AllClockNets
-read_cores YES
-write_timing_constraints NO
-cross_clock_analysis NO
-hierarchy_separator /
-bus_delimiter <>
-case Maintain
-slice_utilization_ratio 100
-bram_utilization_ratio 100
-dsp_utilization_ratio 100
-lc Auto
-reduce_control_sets Auto
-fsm_extract YES -fsm_encoding Auto
-safe_implementation No
-fsm_style LUT
-ram_extract Yes
-ram_style Auto
-rom_extract Yes
-shreg_extract YES
-rom_style Auto
-auto_bram_packing NO
-resource_sharing YES
-async_to_sync NO
-shreg_min_size 2
-use_dsp48 Auto
-iobuf YES
-max_fanout 100000
-bufg 16
-register_duplication YES
-register_balancing No
-optimize_primitives NO
-use_clock_enable Auto
-use_sync_set Auto
-use_sync_reset Auto
-iob Auto
-equivalent_register_removal YES
-slice_utilization_ratio_maxmargin 5
-infer_ramb8 No
endef

# 16k
define BMM16
ADDRESS_SPACE zpu_i0_memory 
    RAMB16 [0x00000000:0x00003fff]
    BUS_BLOCK 
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram8 [31:28];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram7 [27:24];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram6 [23:20];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram5 [19:16];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram4 [15:12];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram3 [11: 8];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram2 [ 7: 4];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram1 [ 3: 0];
    END_BUS_BLOCK;
END_ADDRESS_SPACE;
endef

# 32k
define BMM
ADDRESS_SPACE zpu_core_medium_i0_memory 
    RAMB16 [0x00000000:0x00007fff]
    BUS_BLOCK 
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram16 [31:30];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram15 [29:28];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram14 [27:26];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram13 [25:24];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram12 [23:22];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram11 [21:20];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram10 [19:18];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram9  [17:16];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram8  [15:14];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram7  [13:12];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram6  [11:10];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram5  [ 9: 8];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram4  [ 7: 6];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram3  [ 5: 4];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram2  [ 3: 2];
        box_i0/dualport_ram_ahb_wrapper_i0/dualport_ram_i0/Mram_ram1  [ 1: 0];
    END_BUS_BLOCK;
END_ADDRESS_SPACE;
endef


define UT_FILE
-w
-g INIT_9K:Yes
-g DebugBitstream:No
-g Binary:no
-g CRC:Enable
-g Reset_on_err:Yes
-g ConfigRate:26
-g ProgPin:PullUp
-g TckPin:PullUp
-g TdiPin:PullUp
-g TdoPin:PullUp
-g TmsPin:PullUp
-g UnusedPin:PullDown
-g UserID:0xFFFFFFFF
-g ExtMasterCclk_en:No
-g SPI_buswidth:4
-g TIMER_CFG:0xFFFF
-g multipin_wakeup:No
-g StartUpClk:CClk
-g DONE_cycle:4
-g GTS_cycle:5
-g GWE_cycle:6
-g LCK_cycle:NoWait
-g Security:None
-g DonePipe:No
-g DriveDone:No
-g en_sw_gsr:No
-g drive_awake:No
-g sw_clk:Startupclk
-g sw_gwe_cycle:5
-g sw_gts_cycle:4
endef


define PROGRAM_FPGA_FILE
setMode -bscan	                       
setCable -port auto                     
Identify                                
assignFile -p 1 -file "$(MODULE)_update.bit"
Program -p 1                            
closeCable                              
quit
endef


define PROGRAM_SPI_FILE
setMode -bs                                                   
setCable -port auto                                           
Identify -inferir                                             
identifyMPM                                                   
attachflash -position 1 -spi "W25Q64BV"                     
assignfiletoattachedflash -position 1 -file "$(MODULE)_update.mcs"
Program -p 1 -dataWidth 4 -spionly -e -v -loadfpga            
closeCable                                                    
quit                                                          
endef


export XST_FILE := $(XST_FILE)
export BMM := $(BMM)
export UT_FILE := $(UT_FILE)
export PROGRAM_FPGA_FILE := $(PROGRAM_FPGA_FILE)
export PROGRAM_SPI_FILE := $(PROGRAM_SPI_FILE)


all:	
	@echo "check     - look for timing and other synthesis issues"
	@echo "xst       - generate ngc file (netlist, replaces edif and netlist constrains)"
	@echo "translate - generate ngd file (native generic database [reduced to primitives])"
	@echo "map       - generate ncd file (native ciruit description)"
	@echo "par       - place&route ncd file (design implementation)"
	@echo "trace     - generate timing report"
	@echo "bitgen    - generate bit file (ncd -> bit)"
	@echo "update    - update bitstream with elf file"
	@echo "program   - program fpga with bit file"
	@echo "genmcs    - genrate mcs file"
	@echo "genbin    - genrate bin(ary) file"
	@echo "progspi   - program spi flash with mcs file"
	@echo "clean"
	@echo "..."
	@echo "softflow  - just update fpga with software (software update program)"
	@echo "testflow  - time software bitgen trace update program check"
	@echo "finalflow - time software bitgen trace update progspi check"


softflow: 
	make software update program

testflow: 
	time $(MAKE) software bitgen trace update program check     2>&1 | tee $(XST_LOGFILE)

finalflow:
	time $(MAKE) software bitgen trace update progspi check     2>&1 | tee $(XST_LOGFILE)


check:
	@echo -e "Timing score: "
	@grep --with-filename "Timing Score"                $(BUILDDIR)/*.par
	@echo -e "\nUnwanted Latches (737): "            
	@grep --with-filename "WARNING:Xst:737"             $(BUILDDIR)/*.syr || echo -n
	@echo -e "\nUnassigned signals (653): "          
	@grep --with-filename "WARNING:Xst:653"             $(BUILDDIR)/*.syr || echo -n
	@echo -e "\nInternal tristates (2042): "         
	@grep --with-filename "WARNING:Xst:2042"            $(BUILDDIR)/*.syr || echo -n
	@echo -e "\nCombinatoric loops (2170): "         
	@grep --with-filename "WARNING:Xst:2170"            $(BUILDDIR)/*.syr || echo -n
	@echo -e "\nGated clocks (372): "
	@grep --with-filename "WARNING:PhysDesignRules:372" $(BUILDDIR)/*.bgn || echo -n


software: sw_timestamp
	###
	#############################################################################
	### (re)compile software
	###
	test ! -d $(SOFTWARE) || make all --directory $(SOFTWARE)


sw_timestamp:
	###
	#############################################################################
	#### update sw timestamp
	###
	test ! -d $(SOFTWARE) || make --always-make timestamp --directory $(SOFTWARE)


update: $(BUILDDIR)/$(MODULE).bit
	###
	#############################################################################
	### update the bitfile
	###
	test ! -d $(SOFTWARE) || data2mem -bm $(BMM_BD_FILE) -bd $(SOFTWARE)/*.elf -bt $(BUILDDIR)/$(MODULE).bit -o b $(MODULE)_update.bit
	test   -d $(SOFTWARE) || cp $(BUILDDIR)/$(MODULE).bit $(MODULE)_update.bit


program:
	###
	#############################################################################
	### configure FPGA
	###
	echo "$$PROGRAM_FPGA_FILE" > program_fpga.cmd
	impact -batch program_fpga.cmd


genbin: $(MODULE)_update.bin

$(MODULE)_update.bin: $(MODULE)_update.bit
	###
	#############################################################################
	### generate flash file, bin format for manual flashing
	###
	promgen -b -p bin -w -o $(MODULE)_update.bin -u 0 $(MODULE)_update.bit


genmcs: $(MODULE)_update.mcs

$(MODULE)_update.mcs: $(MODULE)_update.bit
	###
	#############################################################################
	### generate flash file
	###
	promgen -spi -p mcs -w -o $(MODULE)_update.mcs -s 8192 -u 0 $(MODULE)_update.bit


progspi: genmcs
	###
	#############################################################################
	### program flash
	###
	echo "$$PROGRAM_SPI_FILE" > program_spi.cmd
	impact -batch program_spi.cmd


clean:
	rm -f $(MODULE).prj
	rm -f *.log
	rm -f _impact.cmd
	rm -f *.cfi
	rm -f *.prm
	rm -rf $(BUILDDIR)
	rm -rf _ngo
	rm -rf _xmsgs
	rm -f $(BMM_FILE)
	rm -f $(BMM_BD_FILE)
	rm -f $(MODULE).xst
	rm -f $(MODULE).ut
	rm -f program_fpga.cmd
	rm -f program_spi.cmd


dir: $(MODULE).prj	
	###
	#############################################################################
	### generate build directory
	###
	mkdir -p $(BUILDDIR)
	mkdir -p $(BUILDDIR)/projnav.tmp



$(MODULE).prj: ../vhdl_files.txt
	###
	#############################################################################
	### generate project file
	###
	grep --invert rtl_tb ../vhdl_files.txt | grep --invert "\#" | grep --invert "^$$" | awk '{printf "vhdl %s ../%s\n",$$1,$$2}' > $(MODULE).prj


xst:    $(MODULE).ngc
translate: $(MODULE).ngd
map:    $(MODULE)_map.ncd
par:    $(MODULE).ncd


hw_timestamp:
	###
	#############################################################################
	#### update hw timestamp
	###
	test ! -f ../rtl/Makefile || make --directory ../rtl

$(MODULE).ngc: dir hw_timestamp
	###
	#############################################################################
	### synthesis
	###
	echo "$$XST_FILE" > $(MODULE).xst
	cd $(BUILDDIR) ; xst -ifn ../$(MODULE).xst -ofn $(MODULE).syr


$(MODULE).ngd: $(MODULE).ngc $(UCF_FILE)
	###
	#############################################################################
	### translate
	###
	echo "$$BMM" > $(BMM_FILE)
	cd $(BUILDDIR) ; ngdbuild -dd _ngo -nt timestamp -uc ../$(UCF_FILE) -bm ../$(BMM_FILE) -p $(DEVICE_DPS) -sd ../$(CORES) $(MODULE).ngc $(MODULE).ngd

$(MODULE)_map.ncd: $(MODULE).ngd
	###
	#############################################################################
	### map
	###
	@# explanation of map parameters:
	@# -p                    part number
	@# -mt                   multi-threading
	@# -w                    overwrite existing files
	@# -logic_opt            logic optimization
	@# -ol                   overall effor level (std|high)
	@# -t	                placer cost table
	@# -xt                   extra placer cost table (0..5)
	@# -register_duplication duplicate registers
	@# -global_opt	        Global Optimization (off|speed|area|power)
	@# -ir                   ignore RLOCs
	@# -pr			pack registers in IO (off|i|o|b)
	@# -lc                   lut combining (auto|area|off)
	@# -power		Virtex 6 Power Optimization (on|off|high|xe)
	@# -detail		Generate Detailed MAP Report
	@# -o			Output File Name
	@# -bp                   enables block RAM mapping
	cd $(BUILDDIR) ; export XIL_MAP_NODRC; export XIL_PAR_DESIGN_CHECK_VERBOSE=1; export XIL_PAR_ALLOW_LVDS_LOC_OVERRIDE=1; map -p $(DEVICE_DPS) -mt 1 -w -logic_opt off -ol high -t 22 -xt 5 -register_duplication on -global_opt off -ir off -pr b -lc off -power off -detail -o $(MODULE)_map.ncd $(MODULE).ngd $(MODULE).pcf


$(MODULE).ncd: $(MODULE)_map.ncd
	###
	#############################################################################
	### place & route
	###
	@#   -ol = Overall effort level. high is maximum effort.
	@#         Default: high except Virtex-4 and Spartan-3 architectures
	@#                  std (standard) for older architectures
	@#   -pl = Placer effort level. high is maximum effort. Overrides
	@#         any placer effort level implied by "-ol" option.
	@#         Default: high for Virtex-4 and Spartan-3 architectures
	@#         Not supported for newer architectures.
	@#   -rl = Router effort level. high is maximum effort. Overrides
	@#         any router effort level implied by "-ol" option.
	@#         Default: high for Virtex-4 and Spartan-3 architectures
	@#         Not supported for newer architectures
	@#   -xe = Extra effort level. c (Continue on Impossible) is maximum effort.
	@#         Default: none
	@#   -mt = Multi-threading enabled. 4 is the maximum number of threads.
	@#         Default: off except Virtex-4 and Spartan-3 architectures
	@#         Supported only for newer architectures.
	@#   -t =  Placer cost table entry. Start at this entry.
	@#         Default: 1 for Virtex-4 and Spartan-3 architectures
	@#         Not supported for newer architectures
	@#   -p =  Don't run the placer. (Keep current placement)
	@#   -k =  Re-entrant route. Keep the current placement. Continue the routing
	@#         using the existing routing as a starting point.
	@#   -r =  Don't run the router.
	@#   -w =  Overwrite. Allows overwrite of an existing file (including input
	@#         file). If specified output is a directory, allows files in
	@#         directory to be overwritten.
	@#   -f =  Read par command line arguments and switches from file.
	@#   -filter = Message Filter file name (for example "filter.filter"). If
	@#         specified, the contents of this file will be used to filter messages
	@#         from this application. The filter file can be created using Xreport.
	@#   -smartguide = Enables SmartGuide using guidefile.ncd as the guide file.
	@#   -x =  Ignore user timing constraints in physical constraints file and
	@#         generate timing constraints automatically for all internal clocks to
	@#         increase performance. Note: the level of performance achieved will
	@#         be dictated by the effort level (-ol std|high) chosen.
	@#   -nopad = Turns off generation of the pad report.
	@#         Default: Pad Report Generated
	@#   -power = Power Aware Par.  Optimizes the capacitance of non-timing-driven
	@#            design signals.
	@#         Default: off
	@#   -activityfile <activityfile.vcd|saif> = Switching activity data file to
	@#            guide power optimization.  This option is only valid if the
	@#            "-power on" option has been used.
	@#   -intstyle = Indicate contextual information when invoking Xilinx applications
	@#         within a flow or project environment.
	@#         The mode "xflow" indicates that the program is being run as part of a
	@#         batch flow. The mode "silent" indicates that no output will be
	@#         displayed to the screen. The mode "ise" indicates that the program is being
	@#         run as part of an integrated design environment.
	@#         Default: Program is run as a standalone application.
	@#   -ise = Use supplied ISE project repository file.
	@#   -ntd = Ignore Timing constraints in physical constraints file and do NOT
	@#         generate timing constraints automatically.
	@#   <infile>  = Name of input NCD file.
	@#   <outfile> = Name of output NCD file or output directory.
	@#               Use format "<outfile>.ncd" or "<outfile>.dir".
	@#   <pcffile> = Name of physical constraints file.
	cd $(BUILDDIR) ; par -w -ol high $(MODULE)_map.ncd $(MODULE).ncd $(MODULE).pcf


trace:
	cd $(BUILDDIR) ; trce -v 5 -u 10 -fastpaths -xml $(MODULE).twx -o $(MODULE).twr $(MODULE).ncd $(MODULE).pcf


bitgen: $(MODULE).ncd
	###
	#############################################################################
	### generate bitfile
	###
	echo "$$UT_FILE" > $(MODULE).ut
	cd $(BUILDDIR) ; bitgen -f ../$(MODULE).ut $(MODULE).ncd


firmware: $(MODULE)_update.mcs $(MODULE)_update.bin
	mkdir -p firmware_$(DATE)
	cp Makefile             firmware_$(DATE)
	cp $(MODULE)_update.bit firmware_$(DATE)
	cp $(MODULE)_update.bin firmware_$(DATE)
	cp $(MODULE)_update.mcs firmware_$(DATE)
	zip -r firmware_$(DATE) firmware_$(DATE)/*


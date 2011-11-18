# need project files:
#    top.xst
#    top.prj
#    top.ut

# need Xilinx tools:
#    xst
#    ngdbuild
#    map
#    par
#    trce
#    bitgen

# generate build directory
mkdir build
cd build 
mkdir tmp

# start processes
xst      -ifn "../top.xst" -ofn "top.syr" 
ngdbuild -dd _ngo -nt timestamp -uc ../avnet-eval-xc5vfx30t.ucf -p xc5vfx30t-ff665-1 top.ngc top.ngd  
map      -p xc5vfx30t-ff665-1 -w -logic_opt off -ol high -t 1 -register_duplication off -global_opt off -mt off -cm area -ir off -pr off -lc off -power off -o top_map.ncd top.ngd top.pcf 
par      -w -ol high -mt off top_map.ncd top.ncd top.pcf 
trce     -v 3 -s 1 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf 
bitgen   -f ../top.ut top.ncd 

# get bitfile
cp top.bit ..

#!/bin/sh

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

echo "########################"
echo "generate build directory"
echo "########################"
mkdir build
cd build 
mkdir tmp

echo "###############"
echo "start processes"
echo "###############"
xst      -ifn "../synthesis_config/top.xst" -ofn "top.syr" 
ngdbuild -dd _ngo -nt timestamp -uc ../synthesis_config/sp605.ucf -p xc6slx45t-csg324-2 top.ngc top.ngd  
map      -p xc6slx16-csg324-2 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -global_opt off -mt off -ir off -pr off -lc off -power off -o top_map.ncd top.ngd top.pcf 
par      -ol high -mt off top_map.ncd -w top.ncd top.pcf 
trce     -v 3 -s 2 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf 
bitgen   -f ../synthesis_config/top.ut top.ncd 

echo "###########"
echo "get bitfile"
echo "###########"
cp top.bit ..

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
ngdbuild -dd _ngo -nt timestamp -uc ../synthesis_config/digilent-starter-xc3s500e.ucf -p xc3s500e-fg320-4 top.ngc top.ngd  
map      -p xc3s500e-fg320-4 -cm area -ir off -pr off -c 100 -o top_map.ncd top.ngd top.pcf 
par      -w -ol high -t 1 top_map.ncd top.ncd top.pcf 
trce     -v 3 -s 4 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf 
bitgen   -f ../synthesis_config/top.ut top.ncd 

echo "###########"
echo "get bitfile"
echo "###########"
cp top.bit ..

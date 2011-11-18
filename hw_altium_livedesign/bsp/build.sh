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
mkdir build
cd build 
mkdir tmp

echo "###############"
echo "start processes"
xst      -ifn "../top.xst" -ofn "top.syr" 
ngdbuild -dd _ngo -nt timestamp -uc ../altium-livedesign-xc3s1000.ucf -p xc3s1000-fg456-4 top.ngc top.ngd  
map      -p xc3s1000-fg456-4 -cm area -ir off -pr off -c 100 -o top_map.ncd top.ngd top.pcf 
par      -w -ol high -t 1 top_map.ncd top.ncd top.pcf 
trce     -v 3 -s 4 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf 
bitgen   -f ../top.ut top.ncd 

echo "###########"
echo "get bitfile"
cp top.bit ..

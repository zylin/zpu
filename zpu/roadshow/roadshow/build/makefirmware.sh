echo >$2 ZylinPhiFirmware

if [ x"$3" = x ] ;then
	echo "No ic300.bit embedded into .phi"
else
	echo "Embed ic300.bit into .phi"
	echo >>$2 "FPGA: `wc -c $3 | grep -o -e \[0-9\]*`"
	cat >>$2 $1
fi
echo "Writing application"
echo >>$2 "Application: `wc -c $1 | grep -o -e \[0-9\]*`"
cat >>$2 $1
echo >>$2 Done
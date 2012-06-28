#set terminal png size 1024,768
#set output 'adc_check.png'

set title "RENA3 ADC Test"
set xlabel "Messsample"
set ylabel "mV"

set grid

set yrange[-3400:3400]

plot 'adc.data' using 1:($2*1000)         title "Spannung" with histeps, \
     'adc.data' using 1:(($3-0x2000)/3.3) title "ADC"      with points

pause -1

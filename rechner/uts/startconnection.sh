#!/bin/sh
IP=172.16.24.3 
MAC=00:02:B3:4C:1F:5F
TIME=75

# W71XP-Praktik 
# 172.16.103.108
#MAC=00:0F:EA:DE:DF:A9

#Tine
#IP=172.16.100.144
#MAC=00:11:11:13:e7:12

# Ute
#IP=172.16.100.148 
#MAC=00:13:D3:62:F2:09

# felix
#MAC=00:30:05:cf:4a:62
#IP=172.16.101.8

warten()
{
  i=0; 
    while [ $i -lt $1 ] ; 
    do echo -n "." ; 
    let i++; 
    sleep 1; 
  done
}

echo "-------------------------"
echo "preventive wake up"
echo "-------------------------"
~/bin/wakeonlan $MAC

echo "-------------------------"
echo $IP online? 
echo "-------------------------"
ping -q -c 1 $IP

while test $? -eq "1";
do

    echo "-------------------------"
    echo "waiting $TIME s"
    echo "-------------------------"
    warten $TIME

    ping -q -c 1 $IP
done

echo "-------------------------"
echo "$IP is already online!"
echo "connect with ssh"
echo "-------------------------"
ssh $IP -X  $*

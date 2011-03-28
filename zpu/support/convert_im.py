#!/usr/bin/env python

import sys

def bitlen( int_type):
    length = 0
    while int_type > 0:
        int_type >>= 1
        length += 1
    return length


def from_im( list):

    res = 0

    for i in list:
        res = (res << 7) | (i & 0x7f)

    return res

    # handle sign
    if (bitlen(res) == 7) and (res & 2**6):
        res -= 2**7

    if bitlen(res) == 14 and (res & 2**13):
        res -= 2**14

    return res



def to_im( number):
    
    # prepare negative numbers (sign extend)
    if number < 0:
        if number < -2**7:
            if number < -2**14:
                if number < 2**21:
                    number = number % 2**21
                else:
                    number = number % 2**28
            else:
                number = number % 2**14
        else:
            number = number % 2**7

    #print  bin(number)
    
    # result list
    res = []

    while (number & 0xff80) > 0: # hoeherwertige Anteile da?
        
        part = number & 0x7f
        res.append( part)

        number  = number & 0xff80   # entferne Anteil
        number  = number >> 7
        
    res.append( number)

    res.reverse()

    return res



print "number converter for ZPU IM instruction"

if len( sys.argv) == 1:
    progname = sys.argv[0]
    print "%s                          - this help" % progname
    print "%s <arg>                    - convert from integer to IM commands" % progname
    print "%s <arg0> <arg1> ... <argn> - convert from IM commands to intger" % progname

if len( sys.argv) == 2:
    print to_im( int( sys.argv[1]))

if len (sys.argv) > 2:
    
    arg_list = []

    del sys.argv[0]
    for arg in  sys.argv:
        arg_list.append( int(arg))

    res = from_im( arg_list)
    print res,  "0x%X" % (res % 2**32)

#print "to   im:" ,   to_im( 4660)
#print "to   im:" ,   to_im( -177)
#print "from im:" , from_im( [36, 52])
#print "from im:" , from_im( [126, 79])

#!/usr/bin/python

"""

Erzeugt eine Statistik in welcher Programmfunktion die Taktzyklen
verbraten werden.

benoetigt den Simulationstrace -> trace.txt
und eine Liste mit den Symbolen (sortiert)

dabei sollten die Symbole mit 'N' und 't' ignoriert werden

zpu-elf-nm --numeric-sort greth.elf | grep -v " N " | grep -v " t " > greth.symbols


Aufruf:
statistic_trace.py > greth_statistic.txt

"""

import string
import re


def get_symbol_line( src, number):

    lastline = ""
    lastaddr = -1

    for lineno, line in enumerate( src):

        line = line.strip()
        
        try:
            addr = string.atoi( "0x0"+line.split(" ")[0], 16)

        except ValueError:
            #print "ignore: %s" % line
            addr = -1

        if (number >= lastaddr) and (number < addr):
            result = " ".join( lastline.split(" ")[1:] )
            #return result
            return lastline.split(" ")[2]
            #return lastaddr

        lastline = line
        lastaddr = addr

#   lineno = 0
#   for m in re.finditer( pattern, src):
#       start = m.start()
#       lineno = src.count('\n', 0, start)+2
#       #offset = start - src.rfind('\n',0 ,start)
#       #word = m.group(0)
#       #print "greth.diss(%s,%s): %s" % (lineno, offset, word)
#       break
#   return lineno 
    return ""
#    return 0 



def sortkey( (k,v)):
    return (-v, k)



def do_stuff():
    
    statistik = {}

    src = open('greth.symbols').readlines()
    
    with open("trace.txt", "rU") as fobj:

        line_count = 0

        for line in fobj:

#            if line_count < 100:
#                line_count += 1
#            else:
#                print "attention debug shortcut!"
#                break

            line = line.strip()

            if line.startswith("#"):
                continue
            if len(line) == 0:
                continue

            zuordnung = line.split(" ")
            pc = string.atoi( zuordnung[0], 16)
            #print "%s --- %s" % ( get_symbol_line( src, pc), line)
            value = get_symbol_line( src, pc)
            if not value in statistik:
                statistik[ value ] = 1
            else:
                statistik[ value ] += 1


    items = statistik.items()
    items.sort( key=sortkey)


    for value, key in items:
        print "%30s , %s" % (value, key)

do_stuff()



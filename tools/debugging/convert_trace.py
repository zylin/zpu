#!/usr/bin/python
"""
es wird benoetigt:

# Disassemblerlisting
zpu-elf-objdump --disassemble --source greth.elf > greth.diss

# Simulationsoutput
# Simulator -> trace.txt

convert_trace.py sucht die zu einer trace-zeile 
passende Zeilennummer aus dem Disassemblerlisting


# das Ausgabeformat kann von vim/quickfix gelesen werden
# Achtung! Ggf lange Laufzeit
# (ca. 3min fuer 1 MB trace.txt)
convert_trace.py > greth_conv.txt


Verwendung in vim:

"" """"""""""""""""""""
" quickfix-Handling
" Alt-2 bzw. Alt-3 um durch die Fehlerliste zu gehen
set errorformat +=$f:%l:%m
noremap <M-2> :cp<CR>
noremap <M-3> :cn<CR>

"""

import profile

import string
import re


def get_line_number( src, pattern):
    lineno = 0
    for m in re.finditer( pattern, src):
        start = m.start()
        lineno = src.count('\n', 0, start)+2
        #offset = start - src.rfind('\n',0 ,start)
        #word = m.group(0)
        #print "greth.diss(%s,%s): %s" % (lineno, offset, word)
        break
    return lineno 


def do_stuff():
    

    src = open('greth.diss').read()
    
    with open("trace.txt", "rU") as fobj:

        line_count = 0

        for line in fobj:

            #if line_count < 10000:
            #    line_count += 1
            #else:
            #   break

            line.strip()

            if line.lstrip().startswith("#"):
                continue
            if line.lstrip() == '':
                continue

            zuordnung = line.split(" ")
            pc = string.atoi( zuordnung[0], 16)
            search_str = "\s+%x:.*" % (pc)
            
            print "greth.diss:%d:%s" % ( get_line_number( src, search_str), line.rstrip('\r\n'))


profile.run('do_stuff()')



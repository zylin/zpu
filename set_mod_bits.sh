#!/bin/sh

find -iname *.vhd -type f -executable -print0 | xargs -0 chmod -x

find -iname *.txt -type f -executable -print0 | xargs -0 chmod -x
find -iname *.pdf -type f -executable -print0 | xargs -0 chmod -x

find -iname *.ucf -type f -executable -print0 | xargs -0 chmod -x
find -iname *.bmm -type f -executable -print0 | xargs -0 chmod -x
find -iname *.cmd -type f -executable -print0 | xargs -0 chmod -x
find -iname *.xise -type f -executable -print0 | xargs -0 chmod -x

find -iname *.log -type f -executable -print0 | xargs -0 chmod -x
find -iname modelsim.ini -type f -executable -print0 | xargs -0 chmod -x

find -iname *.c -type f -executable -print0 | xargs -0 chmod -x
find -iname *.h -type f -executable -print0 | xargs -0 chmod -x

find -iname Makefile -type f -executable -print0 | xargs -0 chmod -x

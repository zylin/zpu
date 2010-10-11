#!/bin/sh

find -iname *.vhd -type f -executable -print0 | xargs -0 chmod -x
find -iname Makefile -type f -executable -print0 | xargs -0 chmod -x
find -iname modelsim.ini -type f -executable -print0 | xargs -0 chmod -x

#!/bin/sh

find -iname *.vhd -type f -executable -print0 | xargs -0 chmod -x

find -iname *.txt -type f -executable -print0 | xargs -0 chmod -x
find -iname *.pdf -type f -executable -print0 | xargs -0 chmod -x
find -iname *.png -type f -executable -print0 | xargs -0 chmod -x

find -iname *.ucf -type f -executable -print0 | xargs -0 chmod -x
find -iname *.bmm -type f -executable -print0 | xargs -0 chmod -x
find -iname *.cmd -type f -executable -print0 | xargs -0 chmod -x
find -iname *.xise -type f -executable -print0 | xargs -0 chmod -x

find -iname *.log -type f -executable -print0 | xargs -0 chmod -x
find -iname modelsim.ini -type f -executable -print0 | xargs -0 chmod -x

find -iname *.c -type f -executable -print0 | xargs -0 chmod -x
find -iname *.h -type f -executable -print0 | xargs -0 chmod -x

find -iname Makefile -type f -executable -print0 | xargs -0 chmod -x
find -iname *.do -type f -executable -print0 | xargs -0 chmod -x

find -iname *.tar.gz -type f -executable -print0 | xargs -0 chmod -x


# fix group
find -not -group None -print0 | xargs -0 chown :None

# svn stuff
DIR=beam_position_monitor
find $DIR -type f -name "*.vhd" -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;
find $DIR -type f -name "*.h" -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;
find $DIR -type f -name "*.c" -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;

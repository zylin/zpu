#!/bin/sh

find -iname "*.vhd"    -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.txt"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.pdf"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.png"    -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.vym"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.dot"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.odt"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.odg"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.doc"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.docx"   -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.xls"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.xlsx"   -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.ucf"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.bmm"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.cmd"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.xise"   -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.log"    -type f -executable -print0 | xargs -0 chmod -x
find -iname modelsim.ini -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.c"      -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.h"      -type f -executable -print0 | xargs -0 chmod -x
                     
find -iname "*.in"     -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.help"   -type f -executable -print0 | xargs -0 chmod -x

find -iname Makefile   -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.do"     -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.tar.gz" -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.zip"    -type f -executable -print0 | xargs -0 chmod -x

find -iname "*.php"    -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.js"     -type f -executable -print0 | xargs -0 chmod -x
find -iname "*.css"    -type f -executable -print0 | xargs -0 chmod -x

# fix group
find -not -group None -print0 | xargs -0 chown :None

# svn stuff
DIR=. 
EXCLUDE=-and -not -path './xc3sprog'
find $DIR -type f -name "Makefile" $EXCLUDE -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;
find $DIR -type f -name "*.vhd"    $EXCLUDE -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;
find $DIR -type f -name "*.h"      $EXCLUDE -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;
find $DIR -type f -name "*.c"      $EXCLUDE -exec svn propset svn:keywords "Date Author Id Revision HeadURL" {} \;

export SNAPSHOT=`date +%Y-%m-%d`

echo hdl$SNAPSHOT.zip docs$SNAPSHOT.zip sw$SNAPSHOT.zip
rm -f hdl$SNAPSHOT.zip docs$SNAPSHOT.zip sw$SNAPSHOT.zip
zip -r hdl$SNAPSHOT.zip hdl -x "*.svn*"
zip -r docs$SNAPSHOT.zip docs -x "*.svn*"
zip -r sw$SNAPSHOT.zip sw -x "*.svn*"

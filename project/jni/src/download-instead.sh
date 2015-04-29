#!/bin/bash

export INSTEAD_VERSION="2.2.3"

#svn checkout http://instead.googlecode.com/svn/trunk/ instead-read-only
#mv instead-read-only instead

#git clone https://github.com/instead-hub/instead

rm -rf instead
curl -O -L https://github.com/instead-hub/instead/archive/$INSTEAD_VERSION.zip
unzip $INSTEAD_VERSION.zip
rm $INSTEAD_VERSION.zip
mv instead-$INSTEAD_VERSION instead
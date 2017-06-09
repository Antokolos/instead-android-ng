#!/bin/bash

export INSTEAD_VERSION="3.0.1"

rm -rf instead
curl -O -L https://github.com/instead-hub/instead/archive/$INSTEAD_VERSION.zip
unzip $INSTEAD_VERSION.zip
rm $INSTEAD_VERSION.zip
mv instead-$INSTEAD_VERSION instead
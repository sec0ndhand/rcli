#!/bin/bash

git clone git@github.com:sec0ndhand/rcli.git
cd test

cat ../install.sh | bash -s -- mycli

# check if mycli output containts 'env'
if grep -q "env" mycli; then
  echo "Check that mycli output contains 'env'"
else
  echo "mycli output does not contain 'env'"
  exit 1
fi

exit 0

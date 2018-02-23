#!/bin/bash

# A straightforward test using a real repo (a mirror of the FXP XML
# parser) with real MLB files, albeit tuned to match our expectations
# about the nature of the main function.

set -eu

mydir=$(dirname "$0")
cd "$mydir"


echo
echo "==> Running simplest example directly in Poly/ML"
echo

../polyrun ./simple.mlb


if [ ! -d fxp ]; then
    echo "==> Checking out more complex test repo"
    echo
    git clone https://github.com/cannam/fxp
fi

cd fxp

echo
echo "==> First testing MLB with MLton (for reference)"
echo

mlton src/Apps/Canon/canon.mlb

echo
echo "==> Running build with Poly/ML (polybuild)"
echo

../../polybuild src/Apps/Canon/canon.mlb

echo
echo "==> Testing output"
echo

cat doc/fxp-xsa.xml | src/Apps/Canon/canon --validate=no && echo

echo
echo "==> Running directly in Poly/ML (polyrun)"
echo

cat doc/fxp-xsa.xml | ../../polyrun src/Apps/Canon/canon.mlb --validate=no && echo

echo
echo "==> Loading in Poly/ML REPL (polyrepl)"
echo

echo main | ../../polyrepl src/Apps/Canon/canon.mlb | grep '^val it = fn'

echo
echo "==> Running directly in SML/NJ (smlrun)"
echo

cat doc/fxp-xsa.xml | ../../smlrun src/Apps/Canon/canon.mlb --validate=no && echo

echo
echo "==> Done"
echo


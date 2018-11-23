#!/bin/bash

# A straightforward test using a real repo (a mirror of the FXP XML
# parser) with real MLB files, albeit tuned to match our expectations
# about the nature of the main function.

set -eu

mydir=$(dirname "$0")
cd "$mydir"

check_regression() {
    local expected="$1"
    local actual="$2"
    if ! cmp -s "$expected" "$actual" ; then
        echo "*** ERROR: Output does not match expected: diff follows, expected first"
        diff -u "$expected" "$actual"
        exit 2
    fi
}


echo
echo "==> Running simplest example directly in Poly/ML"
echo

../polyrun ./simple.mlb


if [ ! -d fxp ]; then
    echo
    echo "==> Checking out more complex test repo"
    echo
    git clone https://github.com/cannam/fxp
    ( cd fxp ; git checkout 534f24d26695ef810d1b3c9e6d9f05a86c977217 )
fi


cd fxp

echo
echo "==> Running mlb-expand regression test"
echo

../../mlb-expand src/Apps/Canon/canon.mlb > output.txt
check_regression ../regression/expand.txt output.txt

echo
echo "==> Running mlb-dependencies regression test"
echo

../../mlb-dependencies src/Apps/Canon/canon.mlb > output.txt
check_regression ../regression/dependencies.txt output.txt

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
echo "==> Running mlb-coverage all-files regression test"
echo

cat doc/fxp-xsa.xml | ../../mlb-coverage src/Apps/Canon/canon.mlb --validate=no > output.txt
check_regression ../regression/coverage.txt output.txt

echo
echo "==> Running mlb-coverage single-file regression test"
echo

# annoyingly, different greps seem to differ in how they handle
# overlapping context so the results come out a bit different across
# platforms. I can't easily see how to work around that one in the
# coverage script, so let's do it here - hence the sort/uniq shuffle
cat doc/fxp-xsa.xml | ../../mlb-coverage -f src/Parser/Parse/parseDocument.sml ./src/Apps/Canon/canon.mlb --validate=no | sort -n | uniq > output.txt
cat ../regression/annotate.txt | sort -n | uniq > expected.txt
check_regression expected.txt output.txt

echo
echo "==> Done"
echo


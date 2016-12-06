#!/bin/bash

debug=no

if [ -z "${SML_LIB:-}" ]; then
    lib=/usr/lib/mlton/sml
    if [ ! -d "$lib" ]; then
	lib=/usr/local/lib/mlton/sml
    fi
else
    lib="$SML_LIB"
fi

simplify() {
    simple=$(sed -e 's|^./||' -e 's|[^/][^/]*/../||g' -e 's|//|/|g')
    if [ "$debug" = "yes" ]; then
	echo "$simple" 1>&2
    fi
    echo "$simple"
}

cat_mlb() {
    local mlb="$1"
    if [ ! -f "$mlb" ]; then
	echo "*** Error: File not found: $mlb" 1>&2
	exit 1
    fi
    local dir=$(dirname "$mlb");
    if [ "$debug" = "yes" ]; then
	echo "$mlb:" 1>&2
    fi
    cat "$mlb" | while read line; do
	local trimmed=$(
	    echo "$line" | 
		sed 's|(\*.*\*)||' |              # remove ML-style comments
		sed 's#$(SML_LIB)#'"${lib}"'#g' | # expand library path
		perl -p -e 's|\$\(([A-Za-z_-]+)\)|$ENV{$1}|' | # expand other vars
		sed 's|^ *||' |                   # remove leading whitespace
		sed 's| *$||')                    # remove trailing whitespace
	local path="$trimmed"
	case "$path" in
	    /*) ;;
	    *) path="$dir/$trimmed" ;;
	esac
	case "$path" in
	    "") ;;		                  # ignore empty lines
	    *basis.mlb) ;;			  # remove incompatible Basis lib
	    *mlton.mlb) ;;			  # remove incompatible MLton lib
	    *main.sml) ;;			  # remove redundant call to main
	    *.mlb) cat_mlb "$path" ;;
	    *.sml) echo "$path" | simplify ;;
	    *.sig) echo "$path" | simplify ;;
	esac
    done
}

expand_arg() {
    local arg="$1"
    case "$arg" in
	*.sml) echo "$arg" ;;
	*.mlb) cat_mlb "$arg" ;;
	*) echo "*** Error: .sml or .mlb file must be provided" 1>&2
	   exit 1 ;;
    esac
}

get_base() {
    local arg="$1"
    case "$arg" in
	*.sml) basename "$arg" .sml ;;
	*.mlb) basename "$arg" .mlb ;;
	*) echo "*** Error: .sml or .mlb file must be provided" 1>&2
	   exit 1 ;;
    esac
}    

get_outfile() {
    local arg="$1"
    echo $(dirname "$arg")/$(get_base "$arg")
}

get_tmpfile() {
    local arg="$1"
    mktemp /tmp/smlbuild-$(get_base "$arg")-XXXXXXXX
}

get_tmpsmlfile() {
    local arg="$1"
    mktemp /tmp/smlbuild-$(get_base "$arg")-XXXXXXXX.sml
}

get_tmpobjfile() {
    local arg="$1"
    mktemp /tmp/smlbuild-$(get_base "$arg")-XXXXXXXX.o
}



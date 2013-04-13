#!/bin/bash

[ $# -ne 1 ] && { echo "Usage: $0 <data-file>" >&2; exit 1; }
[ -f $1 ] || { echo "File \"$1\" does not exist!" >&2; exit 1; }

awk '{ print $1 }' $1
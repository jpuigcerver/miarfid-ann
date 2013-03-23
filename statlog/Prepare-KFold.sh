#!/bin/bash

K=10
ORIG_DATA=Data/sat6c.tra.svmlight
NDATA=$(cat ${ORIG_DATA} | wc -l)
NXF=$(echo "($NDATA + $K - 1) / $K" | bc)

echo "Split original data ($NDATA items) into $K parts (approx. $NXF items)"
split -d -l $NXF ${ORIG_DATA} ${ORIG_DATA}.valid
for f in ${ORIG_DATA}.valid*; do
    for f2 in ${ORIG_DATA}.valid*; do
	[ $f == $f2 ] && { continue; }
	cat $f2
    done > ${f/.valid/.train}
done
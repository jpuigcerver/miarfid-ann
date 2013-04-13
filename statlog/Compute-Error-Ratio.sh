#!/bin/bash

REF=$1
HYP=$2

[ $# -ne 2 ] && { echo "Usage: $0 <ref-file> <hyp-file>" >&2; exit 1; }
[ -f $REF ] || { echo "File \"$REF\" does not exist!" >&2; exit 1; }
[ -f $HYP ] || { echo "File \"$HYP\" does not exist!" >&2; exit 1; }

paste $REF $HYP | awk 'BEGIN{err=0.0; n=0.0;}{
  if ($1 != $2) { err += 1.0; }
  n = n + 1.0;
}END{ printf("%f\n", 100.0 * err / n); }'
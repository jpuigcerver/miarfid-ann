#!/bin/bash
set -e

for d in $@; do
    awk '{
      printf("%d ", $NF);
      for (i=1; i < NF; ++i) {
        printf("%d:%f ", i, $i);
      }
      printf("\n");
    }' $d > $d.svmlight
done

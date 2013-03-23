#!/bin/bash

DATA=( Data/sat6c.public.tst Data/sat6c.tra )
for d in ${DATA[@]}; do
    awk '{
      printf("%d ", $NF);
      for (i=1; i < NF; ++i) {
        printf("%d:%d ", i, $i);
      }
      printf("\n");
    }' $d > $d.svmlight
done

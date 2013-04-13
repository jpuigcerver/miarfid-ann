#!/bin/bash

DATA=Data/sat6c.tra.norm
NC=6

for c in `seq 1 $NC`; do
    awk -v c=$c '{
      if ($NF == c) {
        $NF="+1";
      } else {
        $NF="-1";
      }
      print $0
    }' $DATA > Data/sat6c.tra.norm.sc${c}
done
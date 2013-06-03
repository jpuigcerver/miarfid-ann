#!/bin/bash
set -e

awk '{
  CL=1; msc=$1;
  for (c=2; c <= NF; ++c) {
    if ($c > msc) { msc=$c; CL=c; }
  }
  print CL
}'

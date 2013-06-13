#!/bin/bash
set -e
wget http://tracer.lcc.uma.es/problems/tide/data/level80.txt
wget http://tracer.lcc.uma.es/problems/tide/data/level90.txt
tr -d '\r' < level80.txt > level80.unix.txt
tr -d '\r' < level90.txt > level90.unix.txt
mv level80.unix.txt level80
mv level90.unix.txt level90
rm level80.txt level90.txt

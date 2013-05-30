#!/usr/bin/env python
# -*- coding: utf-8 -*-

from sys import argv, stdin, stderr
from math import sqrt

MEAN=None
STD=None
for i in range(1, len(argv)):
    if '-m' == argv[i]:
        MEAN = float(argv[i+1])
    elif '-s' == argv[i]:
        STD = float(argv[i+1])
    elif '-h' == argv[i]:
        print 'Usage: %s [OPTIONS]' % argv[0]
        print 'Normalize a data file (values with mean = 0 and std = 1).'
        print ''
        print 'Options:'
        print '  -m <mean>  Assumed mean of the data' 
        print '  -s <std>   Assumed standard deviation of the data' 
        exit (0)

if MEAN is None or STD is None:
    DATA=[]
    for l in stdin:
        v = float(l)
        DATA.append(v)
    MEAN = sum(DATA) / len(DATA)
    STD = sqrt(reduce(lambda acc, x: acc + (x - MEAN)**2, DATA, 0) / (len(DATA) - 1))
    stderr.write('MEAN = %f  STD = %f\n' % (MEAN, STD))
    for v in DATA:
        print (v - MEAN) / STD
else:
    for l in stdin:
        v = float(l)
        print (v - MEAN) / STD

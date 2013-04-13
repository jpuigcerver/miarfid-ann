#!/usr/bin/env python
# -*- coding: utf-8 -*-
from sys import argv, exit
from math import sqrt

if len(argv) != 3:
    print 'Usage: %s train_data test_data' % argv[0]
    exit(0)

tr_fname=argv[1]
te_fname=argv[2]

SUM=[0 for i in range(36)]
SSQ=[0 for i in range(36)]
TRAIN=[]
TEST=[]
# Read data and compute suf. statistics
try:
    f = open(tr_fname)
    for l in f:
        l = l.split()
        if len(l) != 37: continue
        nd=[]
        for d in range(36):
            n = float(l[d])
            nd.append(n)
            SUM[d] = SUM[d] + n
            SSQ[d] = SSQ[d] + n**2
        nd.append(l[36])
        TRAIN.append(nd)
    f.close()

    f=open(te_fname)
    for l in f:
        l = l.split()
        if len(l) != 37: continue
        nd=[]
        for d in range(36):
            n = float(l[d])
            nd.append(n)
        nd.append(l[36])
        TEST.append(nd)
    f.close()
except Exception as e:
    print 'Exception: %s' % str(e)
    exit(1)

N = len(TRAIN)
if N <= 0: exit(1)
# Compute AVG and STD
AVG=[ n / N for n in SUM ]
STD=[ sqrt(SSQ[i] / N - AVG[i]**2) for i in range(36) ]

# Normalize data
try:
    f = open('%s.norm' % tr_fname, 'w')
    for d in TRAIN:
        for i in range(36):
            f.write('%f ' % ((d[i] - AVG[i]) / STD[i]))
        f.write('%s\n' % d[36])
    f.close()

    f = open('%s.norm' % te_fname, 'w')
    for d in TEST:
        for i in range(36):
            f.write('%f ' % ((d[i] - AVG[i]) / STD[i]))
        f.write('%s\n' % d[36])
    f.close()
except Exception as e:
    print 'Exception: %s' % str(e)
    exit(1)

print 'Train data: %d' % len(TRAIN)
print 'Test data: %d' % len(TEST)

exit (0)

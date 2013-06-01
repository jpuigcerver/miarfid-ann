#!/usr/bin/env python
# -*- coding: utf-8 -*-

from sys import argv, stdin, stderr
from math import sqrt

transp = lambda x: map(list, zip(*x))

def ParseArgList(i = 0):
    lst = []
    while i < len(argv) and argv[i][0] != '-':
        lst.append(argv[i])
        i = i + 1
    return i, lst

def CompMeanStd(data, start = 0):
    dataT = transp(data)
    m = []
    s = []
    for d in dataT[start:]:
        m_d = float(sum(d)) / float(len(d))
        s_d = sqrt(reduce(lambda y, x: y + (x - m_d)**2 / float(len(d) - 1), d, 0))
        m.append(m_d)
        s.append(s_d)
    return m, s

def LoadStatsFile(fname):
    MEAN, STD = [], []
    f = open(fname, 'r')
    for l in f:
        l = l.split()
        if len(l) < 1 or l[0][0] == '#': continue
        if len(MEAN) == 0:
            MEAN = [float(e) for e in l]
        else:
            STD  = [float(e) for e in l]
            break
    f.close()
    return MEAN, STD

# Read script options
STATS = None
i = 1
while i < len(argv) and argv[i][0] == '-':
    if '-s' == argv[i]:
        i, STATS  = ParseArgList(i + 1)
    elif '-h' == argv[i]:
        print """Usage: %s [OPTIONS] [--] [FILE...]
Normalize a data file (values with mean = 0 and std = 1).

Options:
  -h            show this help message
  -s <stat...>  use statistics from file instead of computing them
""" % argv[0]
        exit (0)
    elif '--' == argv[i]:
        i = i + 1
    else:
        stderr.write('Unknown option: %s\n' % argv[i])
        exit(1)

FILES = [f for f in argv[i:]]
if len(FILES) == 0:
    stderr.write('You must specify the file to normalize.\n')
    exit(1)

if STATS is not None and len(STATS) != len(FILES):
    stderr.write('You must specify one statistics file for each input.\n')
    exit(1)

# Process input files
for i in range(len(FILES)):
    fname = FILES[i]
    # Read data file
    fi = open(fname, 'r')
    DATA = []
    for l in fi:
        l = l.split()
        if len(l) < 2 or l[0][0] == '#': continue
        v = [int(l[0])]
        for e in l[1:]:
            v.append(float(e.split(':')[1]))
        DATA.append(v)
    fi.close()
    # Compute statistics
    if STATS is None:
        MEAN, STD = CompMeanStd(DATA, 1)
    else:
        MEAN, STD = LoadStatsFile(STATS[i])
    # Write normalized file
    fo = open('%s.norm' % fname, 'w')
    for v in DATA:
        lbl = v[0]
        fea = ' '.join(['%d:%f' % (i,(v[i] - MEAN[i-1])/STD[i-1]) for i in range(1,len(v))])
        fo.write('%s %s\n' % (lbl, fea))
    fo.close()
    # Write statistics file
    if STATS is None:
        fs = open('%s.stats' % fname, 'w')
        fs.write('# Statistics from %s\n' % fname)
        fs.write('# MEAN\n')
        fs.write('%s\n' % ' '.join(str(e) for e in MEAN))
        fs.write('# STD. DEVIAT.\n')
        fs.write('%s\n' % ' '.join(str(e) for e in STD))
        fs.close()

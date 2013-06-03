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

def CompMinMax(data, start = 0):
    dataT = transp(data)
    min_v = []
    max_v = []
    for d in dataT[start:]:
        min_d = min(d)
        max_d = max(d)
        min_v.append(min_d)
        max_v.append(max_d)
    return min_v, max_v

def LoadStatsFile(fname):
    nmin, nmax = None, None
    min_v, max_v = [], []
    f = open(fname, 'r')
    for l in f:
        l = l.split()
        if len(l) < 1 or l[0][0] == '#': continue
        if nmin is None:
            nmin = float(l[0])
        elif nmax is None:
            nmax = float(l[0])
        elif len(min_v) == 0:
            min_v = [float(e) for e in l]
        else:
            max_v = [float(e) for e in l]
            break
    f.close()
    return nmin, nmax, min_v, max_v

# Read script options
STATS = None
L, U = -1, 1
i = 1
while i < len(argv) and argv[i][0] == '-':
    if '-l' == argv[i]:
        L = float(argv[i + 1])
        i = i + 2
    elif '-u' == argv[i]:
        U = float(argv[i + 1])
        i = i + 2
    elif '-s' == argv[i]:
        i, STATS  = ParseArgList(i + 1)
    elif '-h' == argv[i]:
        print """Usage: %s [OPTIONS] [--] [FILE...]
Scale data file to range [L,U]. Default: [-1,1]

Options:
  -h            show this help message
  -l            lowest value in each dimension. default: -1
  -u            highest value in each dimension. default: +1
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
    stderr.write('You must specify the file to scale.\n')
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
        MIN, MAX = CompMinMax(DATA, 1)
    else:
        L, U, MIN, MAX = LoadStatsFile(STATS[i])
    # Write scaled file
    fo = open('%s.scal' % fname, 'w')
    for v in DATA:
        fo.write('%d' % v[0])
        for i in range(1, len(v)):
            if MIN[i-1] == MAX[i-1]:
                newv = L
            else:
                newv = (U - L) * (v[i] - MIN[i-1]) / (MAX[i-1] - MIN[i-1]) + L
            fo.write(' %d:%f' % (i, newv))
        fo.write('\n')
    fo.close()
    # Write statistics file
    if STATS is None:
        fs = open('%s.scal.stats' % fname, 'w')
        fs.write('# Statistics from %s\n' % fname)
        fs.write('# NEW MIN\n')
        fs.write('%f\n' % L)
        fs.write('# NEW MAX\n')
        fs.write('%f\n' % U)
        fs.write('# MIN\n')
        fs.write('%s\n' % ' '.join(str(e) for e in MIN))
        fs.write('# MAX\n')
        fs.write('%s\n' % ' '.join(str(e) for e in MAX))
        fs.close()

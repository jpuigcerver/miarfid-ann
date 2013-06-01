#!/usr/bin/env python
# -*- coding: utf-8 -*-

from os import system
from random import seed, shuffle
from sys import argv, stdin, stderr, stdout

FOLDS = 5
SEED = 0
i = 1
while i < len(argv) and argv[i][0] == '-':
    if argv[i] == '-k':
        FOLDS = int(argv[i+1])
        if FOLDS <= 1: FOLDS = 5
        i = i + 2
    elif argv[i] == '-s':
        SEED = int(argv[i+1])
        i = i + 2
    elif argv[i] == '-h':
        print 'Usage: %s [OPTIONS] FILE...' % argv[0]
        print '  -k FOLDS  set the number of FOLDS to divide each file'
        print '  -s SEED   set the SEED for the random number generator'
        exit(0)
    else:
        stderr.write('Unknown option: "%s"\n' % argv[i])
        stderr.write('Use -h to list all the options.\n')
        exit(1)

seed(SEED)
for fname in argv[i:]:
    f = open(fname, 'r')
    D = f.readlines()
    f.close()
    NK = len(D) / FOLDS
    shuffle(D)
    # Generate Validation sets
    for k in range(FOLDS - 1):
        f = open('%s.valid%02d' % (fname, k), 'w')
        for l in D[k*NK:(k+1)*NK]: f.write(l)
        f.close()
    f = open('%s.valid%02d' % (fname, FOLDS - 1), 'w')
    for l in D[(FOLDS-1)*NK:]: f.write(l)
    f.close()
    # Generate Training sets
    for i in range(FOLDS):
        tfiles = ['%s.valid%02d' % (fname, j) for j in range(FOLDS) if i != j]
        system('cat %s > %s' % (' '.join(tfiles), '%s.train%02d' % (fname, i)))

exit(0)

#!/usr/bin/env python
import os
import sys


def tokenize(str):
    pass



if __name__ == '__main__':
    file_name = 'test.cfg'
    if len(sys.argv) > 1:
        file_name = sys.argv[1]
    if not os.path.isfile(file_name):
        print 'ERR:F:\n'
        exit()

    data = open(file_name).read()
    tokenize(data)

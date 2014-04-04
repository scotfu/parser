#!/usr/bin/env python
import os
import sys
import re

def groupnize(data):
    global_conf = re.search(r'(global.*?\{.*?\};?)', data, re.DOTALL)
    host_confs = re.search(r'(host.*\{.*\};?\n*)', data, re.DOTALL)
    return global_conf,host_confs

def process(data):
    t = groupnize(data)
    global_conf = t[0].group()
    host_confs = t[1].group()
    print global_conf
    print host_confs

def readData():
    file_name = 'test.cfg'
    if len(sys.argv) > 1:
        file_name = sys.argv[1]
    if not os.path.isfile(file_name):
        print 'ERR:F:\n'
        exit()
    f = open(file_name) 
    data = f.read()
    f.close()
    return data
    
    
if __name__ == '__main__':
    data = readData()
    #print data
    process(data)

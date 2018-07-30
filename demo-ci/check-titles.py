#!/usr/bin/env python

import sys
import os
import yaml
import pprint


source_dir = sys.argv[1]
files = os.listdir(source_dir);
files.sort()

for file in files:
    if file[0:5] != "test." or file[-4:] != '.yml':
        continue

    testfile = os.path.basename(file)

    with open(source_dir + '/' + file, 'r') as stream:
        plays = yaml.safe_load(stream)

    for play in plays:
        hosts = play['hosts']
        name = "-"
        try:
            name = play['name']
        except:
            pass
        print ("%-60s | %-20s | %s" % (testfile, name, hosts))

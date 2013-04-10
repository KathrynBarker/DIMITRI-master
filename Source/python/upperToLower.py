#!/usr/bin/python
"""
This script renames all of the files to lowercase.  This is needed to use GDL as linux and GDL are case sensitive and
will not find files that are upper case in the file path

"""

import fnmatch
import os

rootPath = os.getcwd() + '/'
pattern = '*.pro'

for root, dirs, files in os.walk(rootPath):
    for filename in fnmatch.filter(files, pattern):
        print('found match :: ' + str(filename))
        try:
            os.rename(os.path.join(root,filename), os.path.join(root, filename.lower()))
            print('renaming :: ' + str(os.path.join(root,filename)) + ':: to ::' + str(os.path.join(root, filename.lower())))
        except:
            print('missing a file :: moving on ')
            raise

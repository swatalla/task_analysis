# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
from multiprocessing import Pool, Process, Manager, Value, Array
import re
from lxml import etree
from collections import OrderedDict
import numpy as np
import pyqtgraph as pg


xmlfile = "C:\Users\Sebastian Atalla\Desktop\Raw_Timing_Files\SDIP_002_RUN1.xls"

ns = {'s': 'urn:schemas-microsoft-com:office:spreadsheet'}

with open(xmlfile) as xmlfile:
    xml = xmlfile.read()
    
root = etree.fromstring(xml)

hdr = list()
lst = list()
                        
for branch in root[-1]:
    for q in xrange(0, int(len([r for r in branch if len(r) != 0]))):
        for sub_branch in branch[q]:
            for child in sub_branch:
                if q == 0:
                    hdr.append(child.text)
                else:
                    lst.append(child.text)
                    del lst[int(2*q):]

hdr = hdr[0:3:2]                   
for j in xrange(0, int(len(hdr[0:3:2]))+1):
    hdr[j] = hdr[j].split(' ', 1)[0]
    
dict = OrderedDict({'{}'.format(elem):[] for elem in hdr})
keys = [i for i in dict.keys()]
              
def array_conv():
    for h in range(0, len(dict)):
        dict[keys[h]] = [v for i, v in enumerate(lst) if i % 2 == h]
        dict[keys[h]][:] = map(lambda x:x if re.match("^[0-9]\d*(\.\d+)?$", x) else 0, dict[keys[h]])
        dict[keys[h]][:] = np.array(dict[keys[h]]).astype(np.float)
            
array_conv()

pg.plot(dict[keys[0]], dict[keys[1]])
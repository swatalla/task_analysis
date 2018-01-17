# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
import re
import xml.etree.cElementTree as ET
from collections import OrderedDict
import pandas as pd
import numpy as np
from PyQt5 import QtGui
import pyqtgraph as pg


xmlfile = "C:\Users\Sebastian Atalla\Desktop\Raw_Timing_Files\SDIP_002_RUN1.xls"

baseline = 0

s = '{urn:schemas-microsoft-com:office:spreadsheet}'

tree = ET.ElementTree(file=xmlfile)
root = tree.getroot()

hdr = list()
lst = list()
# maybe I can run for the length of branch?

for i in range(0, 13001):
    for branch in root[2]:
        for sub_branch in branch[i]: # 0, 1, 2, 3, 4
            for child in sub_branch:
                if i == 0:
                    hdr.append(child.text)
                else:
                    lst.append(child.text)
                    del lst[int(2*i):]

hdr = hdr[0:3:2]                   
for j in range(0, int(len(hdr[0:3:2]))+1):
    hdr[j] = hdr[j].split(' ', 1)[0]
    
dict = OrderedDict({'{}'.format(elem):[] for elem in hdr})
keys = [i for i in dict.keys()]
   

def only_numbers(string_in):
    check = re.match("^[0-9]\d*(\.\d+)?$", string_in)
    return check is not None
              
def array_conv():
    for h in range(0, len(dict)):
        dict[keys[h]] = [v for i, v in enumerate(lst) if i % 2 == h]
        for i, x in enumerate(dict[keys[h]]):
            if only_numbers(dict[keys[h]][i]) == True:
                dict[keys[h]][i] = float(x)
            else:
                dict[keys[h]][i] = float(baseline)
        if all(isinstance(item, float) for item in dict[keys[h]]) == True:
            dict[keys[h]] = np.array(dict[keys[h]]).astype(np.float)
                            
array_conv()
        
pg.plot(dict[keys[0]], dict[keys[1]])
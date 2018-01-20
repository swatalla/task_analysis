# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
import re
from lxml import etree
from collections import OrderedDict, defaultdict
import numpy as np
from scipy import signal
import pyqtgraph as pg

xmlfile = "C:\Users\Sebastian Atalla\Desktop\Raw_Timing_Files\SDIP_002_RUN1.xls"

def xmlRead(filename):
    with open(filename) as filename:
        xml = filename.read()
        return xml
    
root = etree.fromstring(xmlRead(xmlfile))[-1]
    
dict = OrderedDict({'Time': []}, {"Temperature": []})

def build_data(h):
    data = [leg.text for branch in root for sub_branch in branch for leg in sub_branch[h-1:h] for foot in leg if re.match("^[0-9]\d*(\.\d+)?$", leg.text)]
    return data
    
def array_conv():
    for h in range(0, len(dict)):
        dict[keys[h]] = [v for i, v in enumerate(data) if i % 2 == h]
        dict[keys[h]][:] = np.array(dict[keys[h]]).astype(np.float)
            
array_conv()

pg.plot(dict[keys[0]], dict[keys[1]])
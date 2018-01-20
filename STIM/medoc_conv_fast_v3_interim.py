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


with open(xmlfile) as xmlfile:
    xml = xmlfile.read()

root = etree.fromstring(xml)
    
#data = ["Time", "Temperature"]
dict = OrderedDict({"Time": [], "Temperature": []})

#for h in dict.keys():
#    dict[h] = [organ.text for branch in root[-1] for sub_branch in branch 
#        for i in range(len(dict)) for child in sub_branch[int(2*i):int((2*i)+1)] 
#        for organ in child if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]

time = [organ.text for branch in root[-1] for sub_branch in branch 
        for child in sub_branch[0:1] for organ in child
        if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]
time[:] = np.array(time).astype(np.float)

temp = [organ.text for branch in root[-1] for sub_branch in branch 
        for child in sub_branch[2:3] for organ in child
        if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]
temp[:] = np.array(temp).astype(np.float)
    
def array_conv():
    for h in dict.keys():
        dict[h] = [v for i, v in enumerate(data) if i % 2 == h]
        dict[h][:] = [x if re.match("^[0-9]\d*(\.\d+)?$", x) else 0 for x in dict[h]]
        dict[h][:] = np.array(dict[h]).astype(np.float)
            
array_conv()

#pg.plot(dict[keys[0]], dict[keys[1]])
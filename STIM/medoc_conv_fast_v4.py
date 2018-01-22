# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
import re
from lxml import etree
from collections import OrderedDict
import numpy as np
from scipy import signal
import pyqtgraph as pg

xmlfile = "C:\Users\Sebastian Atalla\Desktop\Raw_Timing_Files\SDIP_002_RUN1.xls"

with open(xmlfile) as xmlfile:
    xml = xmlfile.read()

root = etree.fromstring(xml)
    
dict = OrderedDict({"time": [], "temp": []})


dict["time"][:] = [organ.text for branch in root[-1] for sub_branch in branch 
                    for child in sub_branch[0:1] for organ in child
                    if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]


dict["temp"][:] = [organ.text for branch in root[-1] for sub_branch in branch 
                    for child in sub_branch[2:3] for organ in child
                    if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]

if len(dict["temp"]) < len(dict["time"]):
    dict["temp"].insert(0, dict["temp"][0])
  
#for key in dict.keys():
#    print min(dict.keys(), key=len)

dict["temp"][:] = np.array(dict["temp"]).astype(np.float)
dict["time"][:] = np.array(dict["time"]).astype(np.float)

pg.plot(dict["time"], dict["temp"])
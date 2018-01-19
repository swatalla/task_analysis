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
from scipy import signal
import pyqtgraph as pg


    
xmlfile = "C:\Users\Sebastian Atalla\Desktop\Raw_Timing_Files\SDIP_002_RUN2.xls"

with open(xmlfile) as xmlfile:
    xml = xmlfile.read()
    
root = etree.fromstring(xml)

hdr = list()
lst = list()
                        
#for branch in root[-1]:
#    for q in xrange(0, int(len([r for r in branch if len(r) != 0]))):
#        for sub_branch in branch[q]:
#            for child in sub_branch:
#                if q == 0:
#                    hdr.append(child.text)
#                else:
#                    lst.append(child.text)
#                    del lst[int(2*q):]

def xml_read(xmlRoot, hdList, dtList):               
    for branch in xmlRoot[-1]:
        for q in xrange(0, int(len([r for r in branch if len(r)]))):
            for sub_branch in branch[q]:
                for child in sub_branch:
                    if q == 0:
                        hdList.append(child.text)
                    else:
                        dtList.append(child.text)
                        del dtList[int(2*q):]
                    
#len([q in r for r in branch for branch in root[-1] if q is not None])
                    
#[child.text for branch in root[-1] for r in branch if len(r) for sub_branch in branch for child in sub_branch]
                    
#[child.text for branch in root[-1] for sub_branch in branch[0] for child in sub_branch]
#[child.text for branch in root[-1] for q in range(0, int(len([r for r in branch if len(r) != 0]))) for sub_branch in branch[q] for child in sub_branch]

def header(headList):
    header = headList[0:3:2]                   
    for j in xrange(0, int(len(headList[0:3:2]))+1):
        header[j] = header[j].split(' ', 1)[0]

def dictionary(heading):
    dict = OrderedDict({'{}'.format(elem):[] for elem in heading})
    keys = [i for i in dict.keys()]
              
def array_conv(key):
    for h in range(0, len(dict)):
        dict[key[h]] = [v for i, v in enumerate(lst) if i % 2 == h]
        dict[key[h]][:] = [x if re.match("^[0-9]\d*(\.\d+)?$", x) else 0 for x in dict[key[h]]]
        dict[key[h]][:] = np.array(dict[key[h]]).astype(np.float)

def pyplot(key):
    pg.plot(dict[key[0]], dict[key[1]])
    

def main(xmlRoot, hdList, dtList, headList, heading, key):
    xml_read(xmlRoot, hdList, dtList)
    header(headList)
    dictionary(heading)
    array_conv(key)
    pyplot(key)
    
if __name__ == "__main__":
    main(xml, hdr, lst, hdr, header, keys)
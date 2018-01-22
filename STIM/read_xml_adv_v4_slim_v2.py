# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
import re
from lxml import etree
from collections import Counter
import numpy as np
from scipy.fftpack import rfft, irfft
from pyqtgraph.Qt import QtGui, QtCore
import pyqtgraph as pg

xmlfile = 'C:\\Users\\Sebastian Atalla\\Desktop\\Raw_Timing_Files\\SDIP_002_RUN1.xls'

with open(xmlfile) as xmlfile:
    xml = xmlfile.read()

root = etree.fromstring(xml)

time = np.array([organ.text for branch in root[-1] for sub_branch in branch 
        for child in sub_branch[0:1] for organ in child
        if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]).astype(np.float)

temp = np.array([organ.text for branch in root[-1] for sub_branch in branch 
        for child in sub_branch[2:3] for organ in child 
        if re.match("^[0-9]\d*(\.\d+)?$", organ.text)]).astype(np.float)

if len(temp) < len(time):
    temp = np.insert(temp, 0, temp[0])

temp_adj = temp.copy()

condition = Counter(np.around(temp).ravel())
stim = np.array([val for val, freq in condition.most_common(4)]).astype(np.float)
base, pain = stim[0], stim[1:4]

bold_tc = 277900.0
mask = np.where(time <= bold_tc)

base_onset = []
base_offset = []
pain_onset = []
pain_offset = []

def sever(data, y, z):
    svn = len(data)/y
    return data[z*svn:(z+1)*svn]

def outliers(data, m=5.):
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/(mdev if mdev else 0.)
    return np.asarray(data)[s<m]

def filter(val_set):
    w = rfft(val_set)
    s = w**2
    band = s < (s.max()/5)
    w_dup = w.copy()
    w_dup[band] = 0
    y = irfft(w_dup)
    [np.put(temp_adj, i, np.around(j)) for i, j 
        in zip(list(range(idx[0], idx[-1])), y)]

for cond in np.nditer(stim):

    test_pts = [int(item) for sublist in 
        np.array(np.where((np.around(temp, decimals=1) >= cond-0.1) 
        & (np.around(temp, decimals=1) <= cond+0.1))).tolist() 
        for item in sublist]

    if cond == 30.0:
        for x in range(7):
            base = sever(test_pts, 7, x)
            idx = np.array(outliers(base)).tolist()
            base_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            base_onset.append(idx[0])
            base_offset.append(idx[-1])
            filter(base_val)
    else:
        for x in range(2):
            pain = sever(test_pts, 2, x)
            idx = np.array(outliers(pain)).tolist()
            pain_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            pain_onset.append(idx[0])
            pain_offset.append(idx[-1])
            filter(pain_val)

#for x in xrange(26):
#        ramp_rng = sever(temp, 26, x)
#        idx = np.array(outliers(ramp_rng)).tolist()
#        for y in range(len(stim)):
#            ramp_val = [time[t] for t in list(xrange(idx[0], idx[-1]))]
    
        #for ind, val in enumerate(temp_adj):
        #    if cond-0.5 <= val <= cond+0.05:
        #        np.put(temp_adj, ind, np.round(val)) 

       # bins = np.arange(0, cond+0.3, 0.1)

       # bin_temp = [temp_base[np.digitize(np.where(time == temp_base), bins, right = True) == i] 
       #             for i in xrange(1, len(bins)) 
       #             if temp_base[np.digitize(np.where(time == temp_base), bins, right = True) == i].size]

#bin = np.arange(stim[0], stim[1]+1, (stim[1]-stim[0]))

#bin_temp = [temp_base[np.digitize(temp_adj, bin, right = True) == i] 
#            for i in xrange(1, len(bins)) 
#            if temp_base[np.digitize(temp_adj, bin, right = True) == i].size]

#hist, edges = np.histogram(temp_adj, bins='scott')

mask_time = time[mask]
mask_temp = temp_adj[mask]


app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
p1 = win.addPlot(title="Run_1")
p1.plot(time, temp_adj)
lin0 = pg.InfiniteLine(time[base_onset[0]])
lin1 = pg.InfiniteLine(time[base_onset[1]])
lin2 = pg.InfiniteLine(time[base_onset[2]])
lin3 = pg.InfiniteLine(time[base_onset[3]])
lin4 = pg.InfiniteLine(time[base_offset[0]])
lin5 = pg.InfiniteLine(time[base_offset[1]])
lin6 = pg.InfiniteLine(time[base_offset[2]])
lin7 = pg.InfiniteLine(time[base_offset[3]])

p1.addItem(lin0)
p1.addItem(lin1)
p1.addItem(lin2)
p1.addItem(lin3)
p1.addItem(lin4)
p1.addItem(lin5)
p1.addItem(lin6)
p1.addItem(lin7)

if __name__ == '__main__':
    import sys
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QApplication.instance().exec_()
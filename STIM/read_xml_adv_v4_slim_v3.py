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

base_onset = sorted([])
base_offset = sorted([])
pain_onset = sorted([])
pain_offset = sorted([])
#ramp_up = []
#du = []
#ramp_down = []
#dd = []

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

def point_gen(ps, dx):
    return [int(item) for sublist in 
    np.array(np.where((np.around(temp, decimals=1) >= ps-dx) 
    & (np.around(temp, decimals=1) <= ps+dx))).tolist() 
    for item in sublist]


for cond in np.nditer(stim):

    if cond == 30.0:
        for x in range(7):
            test_pts = point_gen(cond, 0.1)
            base = sever(test_pts, 7, x)
            idx = np.array(outliers(base)).tolist()
            base_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            base_onset.append(idx[0])
            base_offset.append(idx[-1])
            filter(base_val)
    else:
        for x in range(2):
            test_pts = point_gen(cond, 0.1)
            pain = sever(test_pts, 2, x)
            idx = np.array(outliers(pain)).tolist()
            pain_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            pain_onset.append(idx[0])
            pain_offset.append(idx[-1])
            filter(pain_val)

ramp_up = [(base_offset[i], pain_onset[j]) for i, j 
           in zip(range(0, len(base_offset)-1), range(len(pain_onset)))]
ramp_down = [(base_onset[i], pain_offset[j]) for i, j 
             in zip(range(1, len(base_onset)), range(len(pain_offset)))]

mask_time = time[mask]
mask_temp = temp_adj[mask]


app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
p1 = win.addPlot(title="Run_1")
p1.plot(time, temp)
p1.plot(time, temp_adj, pen=(0,255,255))


for i, j in zip(range(1, len(base_onset)), range(len(base_offset)-1)):
    p1.addItem(pg.InfiniteLine(time[base_onset[i]], pen=(255,0,0)))
    p1.addItem(pg.InfiniteLine(time[base_offset[j]], pen=(255,0,0)))
    #p1.addItem(pg.FillBetweenItem(time[base_onset[i]], time[base_offset[j]]))

for i, j in zip(range(len(pain_onset)), range(len(pain_offset))):
    p1.addItem(pg.InfiniteLine(time[pain_onset[i]], pen=(255,0,255)))
    p1.addItem(pg.InfiniteLine(time[pain_offset[j]], pen=(255,0,255)))



if __name__ == '__main__':
    import sys
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QApplication.instance().exec_()
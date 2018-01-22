# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla
"""
import re
from lxml import etree
from collections import Counter
import numpy as np
from scipy import stats, fftpack
import pyqtgraph as pg

bold_tc = 277900.0
mask = np.where(time <= bold_tc)

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

def baseline(data):
    svn = len(data)/7
    return (data[:svn], data[svn:2*svn],
            data[2*svn:3*svn], data[3*svn:4*svn],
            data[4*svn:5*svn], data[5*svn:6*svn],
            data[6*svn:])

def sever(data):
    half = len(data)/2
    return data[:half], data[half:]

def outliers(data, m=5.):
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/(mdev if mdev else 0.)
    return np.asarray(data)[s<m]

for cond in np.nditer(stim):

    test_pts = [int(item) for sublist in 
        np.array(np.where((np.around(temp, decimals=1) >= cond-0.1) 
        & (np.around(temp, decimals=1) <= cond+0.1))).tolist() 
        for item in sublist]

    if cond == 30.0:

        base_pts = [int(item) for sublist in 
            np.array(np.where((np.around(temp, decimals=1) >= cond-0.1) 
            & (np.around(temp, decimals=1) <= cond+0.1))).tolist() 
            for item in sublist]

        one, two, three, four, five, six, seven = baseline(base_pts)
        idx = np.array(outliers(one)).tolist(), np.array(outliers(two)).tolist(), \
                np.array(outliers(three)).tolist(), np.array(outliers(four)).tolist(), \
                np.array(outliers(five)).tolist(), np.array(outliers(six)).tolist(), \
                np.array(outliers(seven)).tolist()
        base_val = [[temp[t] for t in list(xrange(idx[0][0], idx[0][-1]))], 
                    [temp[t] for t in list(xrange(idx[1][0], idx[1][-1]))],
                    [temp[t] for t in list(xrange(idx[2][0], idx[2][-1]))],
                    [temp[t] for t in list(xrange(idx[3][0], idx[3][-1]))],
                    [temp[t] for t in list(xrange(idx[4][0], idx[4][-1]))],
                    [temp[t] for t in list(xrange(idx[5][0], idx[5][-1]))],
                    [temp[t] for t in list(xrange(idx[6][0], idx[6][-1]))]]

        for x in range(7):
            w = rfft(base_val[x])
            s = w**2
            band = s < (s.max()/5)
            w_dup = w.copy()
            w_dup[band] = 0
            y = irfft(w_dup)
            [np.put(temp_adj, [int(i)], [int(k)]) for i, (j, k) 
                in zip(list(range(idx[0][0], idx[0][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[1][0], idx[1][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[2][0], idx[2][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[3][0], idx[3][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[4][0], idx[4][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[5][0], idx[5][-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx[6][0], idx[6][-1])), enumerate(y))]

    else:

        init, last = sever(test_pts)

        idx_1, idx_2 = np.array(outliers(init)).tolist(), \
                        np.array(outliers(last)).tolist()
        
        init_val = [[temp[t] for t in list(xrange(idx_1[0], idx_1[-1]))], 
                    [temp[t] for t in list(xrange(idx_2[0], idx_2[-1]))]]

        for x in range(2):
            w = rfft(init_val[x])
            s = w**2
            band = s < (s.max()/5)
            w_dup = w.copy()
            w_dup[band] = 0
            y = irfft(w_dup)
            [np.put(temp_adj, [int(i)], [int(k)]) for i, (j, k) 
                in zip(list(range(idx_1[0], idx_1[-1])), enumerate(y))]
            [np.put(temp_adj, [int(l)], [int(n)]) for l, (m, n) 
                in zip(list(range(idx_2[0], idx_2[-1])), enumerate(y))]
    

#ramps = [b for a, b in zip(enumerate(temp_rnd), enumerate(stim)) if a != b]

#for ind, val in enumerate(temp_adj):
#    if 0 > temp_adj[ind-1]-temp_adj[ind] >= -0.1:
#        temp_adj[ind] = np.ceil(val)
#    elif 0 < temp_adj[ind-1]-temp_adj[ind] <= 0.1:
#        temp_adj[ind] = np.floor(val)
#    else:
#        pass

#temp_rnd = np.around(temp_adj, decimals=1)

pg.plot(time[mask], temp_adj[mask])

if __name__ == '__main__':
    import sys
    if sys.flags.interactive != 1 or not hasattr(QTCore, 'PYQT_VERSION'):
        pg.QtGui.QApplication.exec_()
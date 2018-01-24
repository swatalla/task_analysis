import re
from lxml import etree
from collections import Counter
import numpy as np
import statsmodels.api as sm
from scipy.signal import fftconvolve, argrelmin, argrelmax, find_peaks_cwt
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
trim = int(np.around((len(time)*(((time[-1] - bold_tc)/2)/(time[-1])))))
stimulus = 16000
baseline = 24000

base_onset = []
base_offset = []
pain_onset = []
pain_offset = []

def lowess(x, y, d):
    return sm.nonparametric.lowess(y, x, frac=d)
    #return lowess

########################################################
temp_cv = lowess(time, temp, 0.01)

ind = find_peaks_cwt(temp_cv[:,1], np.arange(1, len(temp_cv)/6))
########################################################

for cond in np.nditer(stim):
    if cond == 30.0:
        for x in range(7):
            test_pts = point_gen(temp_cv[:,1], cond, 0.1)
            base = sever(test_pts, 7, x)
            idx = np.array(outliers(base)).tolist()
            base_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            base_onset.append(idx[0])
            base_offset.append(idx[-1])


    else:
        for x in range(2):
            test_pts = point_gen(temp_cv[:,1], cond, 0.1)
            pain = sever(test_pts, 2, x)
            idx = np.array(outliers(pain)).tolist()
            pain_val = [temp[t] for t in list(xrange(idx[0], idx[-1]))]
            pain_onset.append(idx[0])


base_onset = sorted(base_onset)
base_offset = sorted(base_offset)
pain_onset = sorted(pain_onset)
pain_offset = sorted(pain_offset)

ramps = [[[(base_offset[i], pain_onset[j])], [(base_onset[k], pain_offset[l])]]
         for i, j, k, l in zip(range(0, len(base_offset)-1), range(len(pain_onset)), 
         range(1, len(base_offset)-1), range(len(pain_onset)))]

duration = [(abs(time[int(up2)]-time[int(up1)]), abs(time[int(down2)]-time[int(down1)])) 
            for elem1, elem2 in ramps for (up1, up2),(down1, down2) in zip(elem1, elem2)]

'''
This block builds the QtGui app for the plot window
'''

app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
p1 = win.addPlot(title="Run_1")
p1.plot(temp_cv[:, 0], temp_cv[:, 1], pen=(255,0,255))
p1.plot(time[mask], temp[mask])
p1.plot(time[mask], temp_adj[mask], pen=(0,255,255))

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
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

bold_tc = 277900.0
mask = np.where(time <= bold_tc)
trim = int(np.around((len(time)*(((time[-1] - bold_tc)/2)/(time[-1])))))
stimulus = 16000
baseline = 24000

#time = time[trim:-trim]
#temp = temp[trim:-trim]

temp_adj = temp.copy()

def lowess(x, y, d):
    return sm.nonparametric.lowess(y, x, frac=d)
    #return lowess

########################################################
temp_cv = lowess(time, temp, 0.008)

temp = temp_cv[:,1]
#ind = find_peaks_cwt(temp_cv[:,1], np.arange(1, len(temp_cv)/26))

ind = find_peaks_cwt(temp[trim:-trim], np.arange(temp[trim], len(temp[trim:-trim])/24))
########################################################

'''
This block builds the QtGui app for the plot window
'''

app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
p1 = win.addPlot(title="Run_1")
#p1.plot(temp_cv[:, 0], temp_cv[:, 1], pen=(255,0,255))
p1.plot(time[trim:-trim], temp[trim:-trim])
p1.plot(time[trim:-trim][ind], temp[trim:-trim][ind], symbol='o') #pen=(0,255,255))

'''
for i, j in zip(range(1, len(base_onset)), range(len(base_offset)-1)):
    p1.addItem(pg.InfiniteLine(time[base_onset[i]], pen=(255,0,0)))
    p1.addItem(pg.InfiniteLine(time[base_offset[j]], pen=(255,0,0)))
    #p1.addItem(pg.FillBetweenItem(time[base_onset[i]], time[base_offset[j]]))

for i, j in zip(range(len(pain_onset)), range(len(pain_offset))):
    p1.addItem(pg.InfiniteLine(time[pain_onset[i]], pen=(255,0,255)))
    p1.addItem(pg.InfiniteLine(time[pain_offset[j]], pen=(255,0,255)))
'''

if __name__ == '__main__':
    import sys
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QApplication.instance().exec_()
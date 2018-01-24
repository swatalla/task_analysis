import re
from lxml import etree
from collections import Counter
import numpy as np
import statsmodels.api as sm
from scipy.signal import fftconvolve, argrelmin, argrelmax, find_peaks_cwt
from scipy.fftpack import rfft, irfft
import itertools
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

condition = Counter(np.around(temp).ravel())
stim = np.array([val for val, freq in condition.most_common(4)]).astype(np.float)
base, pain = stim[0], stim[1:4]

bold_tc = 277900.0
mask = np.where(time <= bold_tc)
trim = int(np.around((len(time)*(((time[-1] - bold_tc)/2)/(time[-1])))))
stimulus = 16000
baseline = 24000

temp_adj = temp.copy()

def lowess(x, y, d):
    return sm.nonparametric.lowess(y, x, frac=d)

def sever(data, y, z):
    svn = len(data)/y
    return data[z*svn:(z+1)*svn]

def outliers(data, m=4.):
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/(mdev if mdev else 1.)
    return np.asarray(data)[s<m]

'''
Smoothed Z-Score Algorithm
----------------------------------
lag = the lag of the moving window
    e.g. a lag of 5 will use the last 5 observations to smooth the data
threshold = the z-score at which the algorithm signals
    e.g. threshold of 3.5 will signal if a datapoint is 3.5 standard deviations away from the moving mean
influence = the influence (between 0 and 1) of new signals on the mean and standard deviation
    e.g. influence of 0 ignores new signals complete for recalculating the new threshold; influence of 0
         is the most robust, 1 is the least robust
'''
def z_score(y, lag, threshold, influence):
    signals = np.zeros(len(y))
    y_filt = np.array(y)
    avgFilter = [0]*len(y)
    stdFilter = [0]*len(y)
    avgFilter[lag-1] = np.mean(y[0:lag])
    stdFilter[lag-1] = np.std(y[0:lag])
    for i in range(lag, len(y)):
        if abs(y[i] - avgFilter[i-1]) > threshold * stdFilter[i-1]:
            if y[i] > avgFilter[i-1]:
                signals[i] = 1
            else:
                 signals[i] = -1

            y_filt[i] = influence * y[i] + (1 - influence) * y_filt[i-1]
            avgFilter[i] = np.mean(y_filt[(i-lag):i])
            stdFilter[i] = np.std(y_filt[(i-lag):i])
        else:
            signals[i] = 0
            y_filt[i] = y[i]
            avgFilter[i] = np.mean(y_filt[(i-lag):i])
            stdFilter[i] = np.std(y_filt[(i-lag):i])

    return dict(signals = np.asarray(signals),
                avgFilter = np.asarray(avgFilter),
                stdFilter = np.asarray(stdFilter))


########################################################
temp_cv = lowess(time, temp, 0.01)

temp_cv = temp_cv[:,1]

lag = 1 #after how many points the algorithm begins working
threshold = 5 #how many std_deviations
influence = 0

result = z_score(temp_cv, lag, threshold, influence)
########################################################

stimuli = dict(stim2 = [(outliers(np.where((sever(temp,2,x) >= stim[3]-0.01) 
                        & (sever(temp,2,x) <= stim[3]+1)))) + (x*len(temp)/2) 
                        for x in range(len(stim[1:-1]))],
               stim1 = [(outliers(np.where((sever(temp,2,x) >= stim[2]-0.01) 
                        & (sever(temp,2,x) <= stim[2]+1)))) + (x*len(temp)/2) 
                        for x in range(len(stim[1:-1]))],
               stim0 = [(outliers(np.where((sever(temp,2,x) >= stim[1]-0.01) 
                        & (sever(temp,2,x) <= stim[1]+1)))) + (x*len(temp)/2) 
                        for x in range(len(stim[1:-1]))])

peaks = sorted([(stimuli[key][x][list(temp[stimuli[key][x]]).index(max(temp[stimuli[key][x]]))], 
                 stimuli[key][x][list(temp[stimuli[key][x]]).index(temp[stimuli[key][x]][-1])]) 
                for key in stimuli.keys() for x in range(len(stimuli[key]))])

## onsets needs work
onsets = sorted([(stimuli[key][i][-j], stimuli[key][i][-j]) for key in stimuli.keys() for i in xrange(len(stimuli[key])) for j in  xrange(len(stimuli[key]))])

'''
This block builds the QtGui app for the plot window
'''

app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
p1 = win.addPlot(title="Run_1")
#p1.plot(temp_cv[:, 0], temp_cv[:, 1], pen=(255,0,255))
p1.plot(time, temp, pen=(255, 255, 0))
p1.plot(time, temp_cv, pen=(255, 0, 255))
#p1.plot(time[peaks[0]], temp[peaks[0]], symbol='o', pen=None)
p1.plot(time, result["avgFilter"], pen=(255, 255, 0))
p1.plot(time, result["avgFilter"] + threshold * result["stdFilter"], pen=(255, 0, 255))
p1.plot(time, result["avgFilter"] - threshold * result["stdFilter"], pen=(0, 255, 255))
p1.plot(time, result["signals"]+30, pen=(0, 255, 0))

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
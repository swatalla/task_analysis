# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 14:07:41 2018

@author: Sebastian Atalla

NEXT IMPROVEMENT: Increase the baseline period by known value; i.e. if dt baseline < 24000 msec,
increase the baseline period from the base_onset period to encapsulate a full 24000 msec period

Possibly shift the window from the whole dataset to:
            [(total_time - bold_tc)/2:] - stuff to analyze - [:(total_time - bold_tc)/2]
            -> effectively shrink analysis window by 13137.5 ms on either side

Another possible improvement: smooth temp before point_gen call, and then limit the window so that
all baseline windows are equal lengths.

Try and make it compatible with iOS by minimizing libraries that are not pure python
So far:
lxml --> xml
"""
import re
from xml import etree
from collections import Counter
import numpy as np
#import statsmodels.api as sm
from itertools import chain, izip
from pyqtgraph.Qt import QtGui, QtCore
import pyqtgraph as pg

xmlfile = '/Users/sebastianatalla/Desktop/Onset_Test/Raw_Timing_Files/SDIP_002_RUN2.xls'

with open(xmlfile) as xmlfile:
    xml = xmlfile.read()

root = etree.ElementTree.fromstring(xml)

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

def smooth(y, box_pts):
    box = np.ones(box_pts)/box_pts
    y_smooth = np.convolve(y, box, mode = 'same')
    for i, j in enumerate(y_smooth):
        if y_smooth[i] < 30:
            y_smooth[i] = 30
    return y_smooth


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
         
This should be compared with the matlab code on stackexchange. There is no reason
why it can't work for ANY signal.
'''
def z_score(y, lag, threshold, influence):
    signals = np.zeros(len(y)) # Initialize signal results
    y_filt = np.array(y) # Initialize filtered series
    avgFilter = [0]*len(y) # Initialize filters
    stdFilter = [0]*len(y)
    avgFilter[lag-1] = np.mean(y[0:lag])
    stdFilter[lag-1] = np.std(y[0:lag])
    for i in range(lag, len(y)): # Loop over all datapoints
        if abs(y[i] - avgFilter[i-1]) > threshold * stdFilter[i-1]:
            if y[i] > avgFilter[i-1]: # Positive signal
                signals[i] = 1
            else:
                signals[i] = -1
            # Reduce influence
            y_filt[i] = influence * y[i] + (1 - influence) * y_filt[i-1]
            #avgFilter[i] = np.mean(y_filt[(i-lag):i])
            #stdFilter[i] = np.std(y_filt[(i-lag):i])
        else: # No Signal
            signals[i] = 0
            y_filt[i] = y[i]
            # Adjust Filters    
        avgFilter[i] = np.mean(y_filt[(i-lag):i])
        stdFilter[i] = np.std(y_filt[(i-lag):i])

    return dict(signals = np.asarray(signals),
                avgFilter = np.asarray(avgFilter),
                stdFilter = np.asarray(stdFilter))


########################################################
#temp_cv = lowess(time, temp, 0.01)

#temp_cv = temp_cv[:,1]

lag = np.around(len(temp)*0.03).astype(int) #after how many points the algorithm begins working
threshold = 6 #how many std_deviations, 6 seems to be good option
influence = 0.003 #0.003 was tolerable, 0.00001 probably better

result = z_score(temp, lag, threshold, influence)
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



base_peaks = np.where(result["signals"][:-1] != result["signals"][1:])[0][1:-1]

base_ramps = dict(start = np.array(base_peaks[0::2]).tolist(),
                  stop = np.array(base_peaks[1::2]).tolist())

pain_peaks = sorted([(stimuli[key][x][list(temp[stimuli[key][x]]).index(max(temp[stimuli[key][x]]))], 
                 stimuli[key][x][-1]) for key in stimuli.keys() for x in range(len(stimuli[key]))])

pain_ramps = dict(start = np.array([x for x, y in pain_peaks]).tolist(),
                  stop = np.array([y for x, y in pain_peaks]).tolist())

onsets = list(chain.from_iterable(izip(base_ramps["start"], pain_ramps["start"], pain_ramps["stop"], base_ramps["stop"])))

'''
Look at set objects: s.intersection, s.union, s.difference, etc for finding the onset and offset
of the baseline ramps

np.where(result["signals"] > 0) for finding the baseline points, maybe even look at the points before
and after the 'packet' (region in which all ones are present in result["signals"]) to indicate the 
'turning point', which may be the actual point that I want
'''



'''
This block builds the QtGui app for the plot window
'''

app = QtGui.QApplication([])
win = pg.GraphicsWindow(title="Stimulus Time Course")

pg.setConfigOptions(antialias=True)
pg.setConfigOption('background', '(222,222,222)')
pg.setConfigOption('foreground', 'k')

p1 = win.addPlot(title="Run_1")
p1.addLegend()
p1.showGrid(alpha=0.5)
p1.addItem(pg.PlotDataItem(time, temp, pen=(255, 137, 83)))
#p1.addItem(pg.PlotDataItem(time, temp_cv, pen=(255, 0, 255)))
p1.addItem(pg.PlotDataItem(time[lag:], result["avgFilter"][lag:], pen=pg.mkPen(color=(255, 255, 0), width=1.5), name="Mean"))
p1.addItem(pg.PlotDataItem(time[lag:], result["avgFilter"][lag:] + threshold * result["stdFilter"][lag:], pen=pg.mkPen(color=(255, 0, 255), width=1.5), name="Upper"))
p1.addItem(pg.PlotDataItem(time[lag:], result["avgFilter"][lag:] - threshold * result["stdFilter"][lag:], pen=pg.mkPen(color=(0, 255, 255), width=1.5), name="Lower"))
p1.addItem(pg.PlotDataItem(time[lag:], result["signals"][lag:]+30, pen=pg.mkPen(color=(0, 255, 0), width=1.5), name="signals"))
#p1.addItem(pg.PlotDataItem(x = time[onsets], y = temp[onsets], symbol='s', pen='c', brush='m'))

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
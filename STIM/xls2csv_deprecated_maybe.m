clear all; close all; clc
cwd = pwd; addpath(cwd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  MODIFY 'subjectID' AND 'rootDir' below
% will look for all Excel spreadsheets ending '.xls' in the folder specified
% by 'rootDir' with 'subjectID' appended to the end.  Note that 'subjectID'
% is zero-padded, ie, 2 --> 02; 40 --> 40
% 
% .png files of plots will be saved in the same folder as the .xls files
% .csv files containing ramp information will be saved in the folder in which
%   you started to run this code.
%
subjectID = 54;
rootDir = 'Y:\Research_Data\KL2_Subject_Data\SDIP\SDIP_0';

% rootDir = '/Users/bettyann/Documents/vanderbilt/CowanLab/toddMonroe/rampCode/wpad_';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%{
Note:
   when running on mac, xlsread cannot read sheets, eg, 'Data'.  i open each
   excel file, delete the first sheet, then save as 'ba_...'.
%}

doVerbose = true;
msgid = 'MATLAB:HandleGraphics:noJVM';
s = warning( 'off', msgid );

% check that subject-specific folder exists
dataDir = sprintf( '%s%02d', rootDir, subjectID );
dataDir = sprintf( '%s%s%s', dataDir, filesep, 'Raw_Timing_Files' );
if ( ~exist( dataDir, 'dir' ))
   msg = sprintf( '\nError: Folder for subject''s .xls files does not exist' );
   msg = sprintf( '%s.\nCheck matlab variable definitions:', msg );
   msg = sprintf( '%s\n SubjectId = %02d\n rootDir = %s', msg, subjectID, rootDir );
   msg = sprintf( '%s\n dataDir = %s', msg, dataDir );
   msg = sprintf( '%s\nAre .xls files in dataDir?\n', msg );
   error( msg );
end;

cd( dataDir );
if ( true )
   list = {};
   tmp = dir( '*.xls*' );
   for ii = 1:length(tmp)
      list{ii} = tmp(ii).name;
   end;
end;

if ( doVerbose )
   fprintf( 'Found the following .xls files; Guessing at run number:\n' );
   for ii = 1:length(list)
      fprintf( ' Run %2d: %s\n', ii, list{ii} );
   end;
end;

figure;
pos = get( gcf, 'Position' );
pos(3) = pos(3) * 1.33;        % make plot wider
set( gcf, 'Position', pos );

for i=1:length(list)
   % this is here because the .csv file is saved in the 'cwd' working dir and
   % we need to move back to the subjectID directory at the start of each loop
   cd( dataDir );

    % Some subjects failed. Skip them
    try
        % Read in each subject's data. Strip out the temperature (temp) array
        % and timecourse (time) array
        tmp = regexprep( list{i}, '\n', '' );
	try
	    [~,~,data] = xlsread(tmp,'Data');
	catch
	    msg = sprintf( 'Error reading ''%s''. Skip.', tmp );
	    warning( msg );
	    continue;
	end;

        temp = data(3:end,3);
        temp = cell2mat(temp);
        temp = round(temp);
        unProcessed = temp;
        time = data(3:end,1);
        time = cell2mat(time);

	 % time in units = sec
	 secTime = time / 1000;

	 % bettyann chodkowski: quick peek to inspect temperature profile
	 doPlot = true;
	 if ( doPlot )
	    clf;
	    plot( secTime, temp, 'b-' );
	    xlabel( 'Time (sec)' );  ylabel( 'Temperature' );
	    tStr = sprintf( 'Run %d? | %s: Inspect Temperature Profile', i, list{i} );
	    title( tStr, 'interpreter', 'none' );
	    str = sprintf( '\nInspect Temperature Profile\nRun %d: %s', i, list{i} );
	    str = sprintf( '%s\nPress [RETURN] to continue ', str );
	    xx = input( str );
	 end;

        %% This section handles finding the increasing ramp
        % Need to store the increment to max value and start value to remove
        % later. The output array looks like this:
        % First row == start position of ram
        % Second row == top of ramp
        init = 1;
        maxArray = zeros(2,6);
        for v=1:6
            for j=init:length(temp)
                if temp(j) > 30
                    %Get a local window of 401 values to mine for max
                    section = temp(j-200:j+200);

                    %Section incrementer
                    init = j+1500;

                    %Get the max value
                    maxVal = max(section);
                    n=1; 
                    thisTemp = temp(j);
                    while thisTemp ~= maxVal
                        thisTemp = temp(j+n);
                        n=n+1;
                    end
                    maxArray(1,v) = j;
                    maxArray(2,v) = j+n;
                    break;
                end
            end
        end

        %% This section handles finding the decreasing ramp
        % Need to store the increment to min value and start value to remove
        % later. The output array looks like this:
        % First row == start position of ram
        % Second row == bottom of ramp

        minArray = zeros(2,6);
        init = maxArray(1,1)+400;

        % THIS SECTION DOESN'T WORK AS HOPED. USE FIND(SECTION ==
        % MAX(SECTION)) and FIND(SECTION == MIN(SECTION)) to find the positions
        % of the starts and finishes of the ramps rather than incrementing.
        for v=1:6
            for j=init:length(temp)
                if temp(j) <= 30
                    % Get a local window of 401 values to mine for max
                    section = temp(j-300:j+100);

                    % Section incrementer
                    init = j+2000;

                    maxValue = max(section);
                    maxLocations = find(section==maxValue);

                    % Since the array is sectioned, we need to add the location
                    % to the value of j
                    maxLocation = maxLocations(end)+j-300;

                    minValue = min(section);
                    minLocations = find(section==minValue);
                    minLocation = minLocations(1);
                    minArray(1,v) = maxLocation;
                    minArray(2,v) = minLocation+j-300;
                    break;
                end
            end
        end   

        %% Now we write out the data into a pretty format:
        outputArray = cell(2,37);
        % Header Info
        outputArray{1,1}='Subject_Name';
        outputArray{1,2}='rampStart1';
        outputArray{1,3}='rampFinish1';
        outputArray{1,4}='length1';
        outputArray{1,5}='rampStart2';
        outputArray{1,6}='rampFinish2';
        outputArray{1,7}='length2';
        outputArray{1,8}='rampStart3';
        outputArray{1,9}='rampFinish3';
        outputArray{1,10}='length3';
        outputArray{1,11}='rampStart4';
        outputArray{1,12}='rampFinish4';
        outputArray{1,13}='length4';
        outputArray{1,14}='rampStart5';
        outputArray{1,15}='rampFinish5';
        outputArray{1,16}='length5';
        outputArray{1,17}='rampStart6';
        outputArray{1,18}='rampFinish6';
        outputArray{1,19}='length6';
        outputArray{1,20}='rampStart7';
        outputArray{1,21}='rampFinish7';
        outputArray{1,22}='length7';
        outputArray{1,23}='rampStart8';
        outputArray{1,24}='rampFinish8';
        outputArray{1,25}='length8';
        outputArray{1,26}='rampStart9';
        outputArray{1,27}='rampFinish9';
        outputArray{1,28}='length9';
        outputArray{1,29}='rampStart10';
        outputArray{1,30}='rampFinish10';
        outputArray{1,31}='length10';
        outputArray{1,32}='rampStart11';
        outputArray{1,33}='rampFinish11';
        outputArray{1,34}='length11';
        outputArray{1,35}='rampStart12';
        outputArray{1,36}='rampFinish12';
        outputArray{1,37}='length12';

        % Now update the values
        % .xls filename may have [comma] in name so protect with double-quotes
        outputArray{2,1}=sprintf( '"%s"', list{i} );
        outputArray{2,2}=time(maxArray(1,1));
        outputArray{2,3}=time(maxArray(2,1));
        outputArray{2,4}=time(maxArray(2,1)) - time(maxArray(1,1));
        outputArray{2,5}=time(minArray(1,1));
        outputArray{2,6}=time(minArray(2,1));
        outputArray{2,7}=time(minArray(2,1)) - time(minArray(1,1));
        outputArray{2,8}=time(maxArray(1,2));
        outputArray{2,9}=time(maxArray(2,2));
        outputArray{2,10}=time(maxArray(2,2)) - time(maxArray(1,2));
        outputArray{2,11}=time(minArray(1,2));
        outputArray{2,12}=time(minArray(2,2));
        outputArray{2,13}=time(minArray(2,2)) - time(minArray(1,2));
        outputArray{2,14}=time(maxArray(1,3));
        outputArray{2,15}=time(maxArray(2,3));
        outputArray{2,16}=time(maxArray(2,3)) - time(maxArray(1,3));
        outputArray{2,17}=time(minArray(1,3));
        outputArray{2,18}=time(minArray(2,3));
        outputArray{2,19}=time(minArray(2,3)) - time(minArray(1,3));
        outputArray{2,20}=time(maxArray(1,4));
        outputArray{2,21}=time(maxArray(2,4));
        outputArray{2,22}=time(maxArray(2,4)) - time(maxArray(1,4));
        outputArray{2,23}=time(minArray(1,4));
        outputArray{2,24}=time(minArray(2,4));
        outputArray{2,25}=time(minArray(2,4)) - time(minArray(1,4));
        outputArray{2,26}=time(maxArray(1,5));
        outputArray{2,27}=time(maxArray(2,5));
        outputArray{2,28}=time(maxArray(2,5)) - time(maxArray(1,5));
        outputArray{2,29}=time(minArray(1,5));
        outputArray{2,30}=time(minArray(2,5));
        outputArray{2,31}=time(minArray(2,5)) - time(minArray(1,5));
        outputArray{2,32}=time(maxArray(1,6));
        outputArray{2,33}=time(maxArray(2,6));
        outputArray{2,34}=time(maxArray(2,6)) - time(maxArray(1,6));
        outputArray{2,35}=time(minArray(1,6));
        outputArray{2,36}=time(minArray(2,6));
        outputArray{2,37}=time(minArray(2,6)) - time(minArray(1,6));

	 % plot temperature profile with ramps included
	 clf;
	 subplot(2,1,1), plot( secTime, unProcessed );
	 yy = ylim;  yy = yy + 2;
	 axis tight;
	 ylim( yy );
	 ylabel( 'Temperature (C)' );
	 tStr = sprintf( 'Run %d? | %s', i, list{i} );
	 tStr = sprintf( '%s\nTemperature Profile with Ramps', tStr );
	 title( tStr, 'interpreter', 'none' );
	 hold on;
	 plot( xlim, [30 30], 'k:' );

	 % different colors for each ramp transition
	 co = [
		  0         0    1.0000
	     1.0000         0         0
		  0    0.7000         0
	     0.7000         0    0.7000
	 ];
	 hold on;
	 for ii = 1:length(maxArray);
	    xx = secTime( maxArray(1,ii) );
	    plot( [xx xx], ylim, '-', 'Color', co(1,:) );
	    xx = secTime( maxArray(2,ii) );
	    plot( [xx xx], ylim, '-', 'Color', co(2,:) );

	    xx = secTime( minArray(1,ii) );
	    plot( [xx xx], ylim, '-', 'Color', co(3,:) );
	    xx = secTime( minArray(2,ii) );
	    plot( [xx xx], ylim, '-', 'Color', co(4,:) );
	 end;

        % Remove the ramps 
        noRamps = unProcessed;
        noRamps([maxArray(1,1):maxArray(2,1), maxArray(1,2):maxArray(2,2), ...
              maxArray(1,3):maxArray(2,3), maxArray(1,4):maxArray(2,4), ...
              maxArray(1,5):maxArray(2,5), maxArray(1,6):maxArray(2,6), ... 
              minArray(1,1):minArray(2,1), minArray(1,2):minArray(2,2), ...
              minArray(1,3):minArray(2,3), minArray(1,4):minArray(2,4), ...
              minArray(1,5):minArray(2,5), minArray(1,6):minArray(2,6)]) = [];
        noRampsSecTime = secTime;
        noRampsSecTime([maxArray(1,1):maxArray(2,1), maxArray(1,2):maxArray(2,2), ...
              maxArray(1,3):maxArray(2,3), maxArray(1,4):maxArray(2,4), ...
              maxArray(1,5):maxArray(2,5), maxArray(1,6):maxArray(2,6), ... 
              minArray(1,1):minArray(2,1), minArray(1,2):minArray(2,2), ...
              minArray(1,3):minArray(2,3), minArray(1,4):minArray(2,4), ...
              minArray(1,5):minArray(2,5), minArray(1,6):minArray(2,6)]) = [];
        noRampsSecTime = 1:length(noRamps);
        noRampsSecTime = noRampsSecTime + min(time);
        noRampsSecTime = noRampsSecTime' / 100;

	 % plot temperature profile with ramps removed
	 subplot(2,1,2), plot( noRampsSecTime, noRamps );
	 axis tight;
	 ylim( yy );
	 hold on;
	 plot( xlim, [30 30], 'k:' );
	 xlabel( 'Time (sec)' );
	 ylabel( 'Temperature (C)' );
	 title( 'Temperature Profile without Ramps' );

	 [ pName, pngFile, ext ] = fileparts( list{i} );
	 if ( isempty( pName )) pName = pwd; end;
	 pngFile = [ pName filesep pngFile '.png' ];
         saveas( gca, pngFile );
	 fprintf( 'Saved plot as %s\n', pngFile );

        % save .csv file in the directory in which we started, not necessarily
        % the directory in which the .xls files live
        % cd(cwd);
	[ cName, csvFile, ext ] = fileparts( list{i} );
	if ( isempty( cName )) cName = pwd; end;
	csvFile = [ cName filesep csvFile '.csv' ];
        cell2csv( csvFile, outputArray );
	fprintf( 'Saved .csv as %s\n', csvFile );
	cd( dataDir );

	 if ( doVerbose )
	    % maxArray(1,:) = start of   up ramp(:)
	    % maxArray(2,:) = end   of   up ramp(:)
	    % minArray(1,:) = start of down ramp(:)
	    % minArray(2,:) = end   of down ramp(:)

	    % durPrevBaseline = duration of baseline for the periods _before_ the stimuli
	    % durPeak = duration of stimuli
	    durPrevBaseline(1) = minArray(2,1) - 0;
	    durPeak(1) = maxArray(2,1) - minArray(1,1);
	    for ii = 2:size(maxArray,2)
	       durPrevBaseline(ii) = maxArray(1,ii) - minArray(2,ii-1);
	       durPeak(ii) = maxArray(2,ii) - minArray(1,ii);
	    end;
	    durPrevBaseline = durPrevBaseline / 100;
	    durPeak         = abs( durPeak )  / 100;
	    durUpRamp   = diff(secTime(maxArray));
	    durDownRamp = diff(secTime(minArray));

	    stimInfo = [ durPrevBaseline; durPeak; durUpRamp; durDownRamp ]';

	    if ( true )
	       fprintf( '\n' );
	       fprintf( '                 Duration (sec)\n' );
	       fprintf( '    PrevBaseL  PeakStim  upRamp downRamp Total\n' );
	       for ii = 1:length(durPeak)
		  fprintf( '%3d: %6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\n', ...
		     ii, durPrevBaseline(ii), durPeak(ii), ...
		     durUpRamp(ii), durDownRamp(ii), sum(stimInfo(ii,:),2) );
	       end;
	       fprintf( 'avg: %6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\n', ...
		  mean( stimInfo ), mean(sum(stimInfo,2)) );
	       fprintf( '\n' );
	    end;
	 end;

    catch err
        if ~isempty(err.identifier) 
            fprintf(2,['Subject ' list{i} ' failed. Please fix manually\n']);
        end
    end
    clear err;
end

s = warning( 'on', msgid );



%spm_name = 'X:\Research_Data\KL2_Subject_Data\Subject_Data\WPAD\WPAD_006\Analysis\SPM.mat';
%roi_file = 'X:\Research_Data\KL2_Subject_Data\Regions\ROIs\L_ACC_BA_24_32_roi.mat';

clear;
marsbar('on');          % this starts marsbar; no need to do this yourself
doOverWriteOutput = false;
doVerbose = true;

%warning('on', 'verbose')
warning('off', 'all') %remember to turn these back on

inDir = '/Users/atalla.3/Desktop/R21PSC/REPLACED_BY_SUBJECT_ID/Analysis/';
%inDir = '/Volumes/ioSafe/monroe/Research_Data/R21_Subject_Data/ASDM/REPLACED_BY_SUBJECT_ID/Analysis/';
%inDir = 'X:\Research_Data\KL2_Subject_Data\Subject_Data\SDIP\REPLACED_BY_SUBJECT_ID\Analysis\';

subjs = {
    'ASDF_001'
    'ASDF_003'
    'ASDF_004'
    'ASDF_005'
    'ASDF_006'
    'ASDF_008'
    'ASDF_009'
    'ASDF_010'
    'ASDF_013'
    'ASDF_014'
    'ASDF_015'
    'ASDF_018'
    'ASDF_019'
    'ASDF_020'
    'ASDF_022'
    'ASDF_023'
    'ASDF_024'
    'ASDF_027'
    'ASDF_028'
    'ASDF_029'
    'ASDF_030'
    'ASDF_031'
    'ASDF_033'
    'ASDF_036'
    'ASDF_041'
    'ASDF_042'
    'ASDF_044'
    };

rDir = '/Users/atalla.3/Desktop/Seeds/ROI/';

ROI = {
    [ rDir 'L_ACC_BA_24_32_roi.mat']
    [ rDir 'L_Amygdala_roi.mat']
    [ rDir 'L_DLPFC_BA_9_46_roi.mat']
    [ rDir 'L_Hypothalamus_roi.mat']
    [ rDir 'L_Insula_roi.mat']
    [ rDir 'PAG_RVM_6mmSPH_2_-26_-10_roi.mat']
    [ rDir 'R_ACC_BA_24_32_roi.mat']
    [ rDir 'R_Amygdala_roi.mat']
    [ rDir 'R_DLPFC_BA_9_46_roi.mat']
    [ rDir 'R_Hypothalamus_roi.mat']
    [ rDir 'R_Insula_roi.mat']
    };

outDir = '/Users/atalla.3/Desktop/Seeds/ROI/results';
%*********************************************************************
eff = 1;

filename = [];

cwd = pwd;

for s = 1:length(subjs)     % loop thru each subject
    
    for r = 1:length(ROI)          % loop thru each ROI
        
        [ ~, bName, ~ ] = fileparts( ROI{r} );
        tmp = fullfile( outDir, [subjs{s} '_' bName '_PSigFunc.txt'] );
        
        if ( ~doOverWriteOutput )
            % check that output filename is unique (i.e., does not already exist)
            while ( exist( tmp, 'file' ))
                [ pName, bName, ext ] = fileparts( tmp );
                bName = sprintf( '%s+', bName );
                tmp = fullfile( pName, [bName ext] );
            end
        end
        filename{r} = tmp;
        if ( doVerbose )
            fprintf( '%s\t--> %s\n', ROI{r}, filename{r} );
        end
        
        
        if ( doVerbose )
            fprintf( '    %s \n', subjs{s} );
        end
        
        % construct this subject's directory
        subjDir = regexprep( inDir, 'REPLACED_BY_SUBJECT_ID', subjs{s} );
        
        % change directory to where SPM.mat file lives
        cd( subjDir );
        
        if ( doVerbose )
            fprintf( '\n==  %s \n', ROI{r} );
        end
        
        pct_signal = []; % set pct_signal to empty for each ROI
        if eff % if running event fitted, need subjects repmat for each row
            xsubjs = {};
        end
        
        
        
        spm_name = 'SPM.mat';
        roi_file = ROI{r};
        
        D = mardo(spm_name);
        D = autocorr(D, 'fmristat', 2);
        R = maroi(roi_file);
        Y = get_marsy(R, D, 'mean');
        E = estimate(D, Y);
        
        [e_specs, e_names] = event_specs(E);
        n_events = size(e_specs, 2);
        
        onses = {};
        durses = {};
        
        for eno = 1:size(e_specs, 2)
            [ons, dur] = event_onsets(D, e_specs(:,eno));
            onses{eno} = ons;
            durses{eno} = dur;
        end
        
        %ets = event_types_named(E);
        %n_event_types = length(ets);
        bin_size = tr(E);
        fir_length = 24;
        bin_no = fir_length/bin_size;
        opts = struct('percent',1);
        
        for e_s = 1:n_events
            pct_ev(:,e_s) = event_fitted_fir(E, e_specs(:,e_s), bin_size, bin_no, opts);
            %pct_ev(:, e_t) = event_fitted_fir(E, ets(e_t).e_spec, bin_size, ...
            %   bin_no, opts);
        end
        
        xsubjs = repmat(subjs(s),size(pct_ev,1),1);
        
        pct_signal = cat(1, pct_signal, pct_ev);
        
        
        % save variable pct_signal directly to text file
        fprintf( '    **  Saving %s ...\n', filename{r} );
        fid1 = fopen( filename{r}, 'wt' );           % open file for writing
        
        [ pName, bName, ext ] = fileparts( filename{r} );
        tmp = sprintf( '%9s\t', e_names{:} );
        
        % make event names more descriptive
        tmp = regexprep( tmp, '\<stim_0\>', 'warm' );
        tmp = regexprep( tmp, '\<stim_1\>', 'mild' );
        tmp = regexprep( tmp, '\<stim_2\>', 'moderate' );
        
        fprintf( fid1, '%s\t%s\n', bName, tmp );     % write header
        tmp = num2str( pct_signal, '%9.6f\t' );
        for ss = 1:length(xsubjs)
            fprintf( fid1, '%s\t%s\n', xsubjs{ss}, tmp(ss,:) );
        end
        fclose( fid1 );
        
    end
    
end        % for r = 1:length(ROI)       % loop thru each ROI

% return to original working directory
cd( cwd );

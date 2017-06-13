function spm_12_first_level_spec_est()
%-----------------------------------------------------------------------
% MATLAB non-rWLS Batch Script
% spm SPM - SPM8 (****)
% Written 8/26/2015
% Includes the following modules:
% % FMRI MODEL SPECIFICATION
% % RWLS MODEL ESTIMATION
% % Written by Sebastian Atalla

% Possible error source: Underscores in ART regressor file have proven to
% be inconsistent, may present a possible source of error. Be sure to check
% that the format in the script matches the format used in the actual
% regressor file.
%-----------------------------------------------------------------------

% enter subjects to run (one per line)
subjs = cell2mat(inputdlg('Enter one subject per line:','Subjects (one per line)', 20, {'' ''}, 'on'));

% create waitbar
wb = waitbar(0,'Running First Level...');

% for each subject, run preprocessing
for k = 1:size(subjs,1)
    clear b; % clear b variable
    % get analysis subdirectory
    b.analys = cellstr(['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,:) '\Analysis']);
    % for each run, get niftis
    for r = 1:4
        clear runfld d condfld f tempfld g;
        runfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,1:end) '\Functional\' subjs(k,1:end) '_run_' num2str(r)];
        cd(runfld); 
        d = dir('sw*.nii');
        b.runs{r} = cellstr(strcat(runfld,filesep,{d.name})');
        
        condfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,:) '\Onsets'];
        cd(condfld);
        fstr = strcat('Onsets',num2str(r),'*.mat');
        f = dir(fstr);
        b.onset{r} = cellstr(strcat(condfld,filesep,{f.name})');
        
        tempfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,1:end) '\Functional\' subjs(k,1:end) '_run_' num2str(r)];
        cd(tempfld)
        %If the following line (gstr) fails, adding an underscore (_) after "swarun" may fix it
        gstr = strcat('art_regression_outliers_and_movement_swarun*',num2str(r),'*-t000-0001.mat');
        g = dir(gstr);
        b.art{r} = cellstr(strcat(tempfld,filesep,{g.name})');
    end
    % create matlabbatch, and run job
    try
        matlabbatch = batch_job(b);
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        savefig('stat_design.fig')
        spm_jobman('interactive', matlabbatch);
        % update waitbar
        waitbar(k/size(subjs,1),wb);
    catch emsg % if failed, display subject
        disp(['Error with ' subjs(k,:) ': ' emsg.message]);
    end
end
disp('Done');

%% SPM Preprocessing

function [matlabbatch] = batch_job(b)

matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.dir = b.analys;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.units = 'secs';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.RT = 2;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.fmri_t = 16;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.fmri_t0 = 8;

for r = 1:4
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).scans = b.runs{r};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).multi = b.onset{r};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).multi_reg = b.art{r};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(r).hpf = 128;
end

matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.bases.hrf.derivs = [1 1];
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.volt = 1;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.global = 'None';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mthresh = 0.8;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mask = {''};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.cvi = 'none';

matlabbatch{2}.spm.tools.rwls.fmri_rwls_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.tools.rwls.fmri_rwls_est.method.Classical = 1;
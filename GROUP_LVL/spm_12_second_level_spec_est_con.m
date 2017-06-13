function spm_12_second_level_spec_est_con()
%-----------------------------------------------------------------------
% MATLAB Preprocessing Script
% spm SPM - SPM12 (6470)
% Written 5/14/2017 by Sebastian Atalla
% Includes the following modules:
% % FACTORIAL DESIGN
% % MODEL ESTIMATION
% % CONTRAST MANAGER
%-----------------------------------------------------------------------

% enter subjects to run (one per line)
subjs.group1 = cell2mat(inputdlg('Enter one subject per line from Group 1:','Subjects (one per line)', 20, {'' ''}, 'on'));
subjs.group2 = cell2mat(inputdlg('Enter one subject per line from Group 2:','Subjects (one per line)', 20, {'' ''}, 'on'));

% create waitbar
wb = waitbar(0,'Performing Group Level Analysis');

clear b; %clear b

parent = 'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\Second_Level_Jobs';

cd parent

for r = 1:8
    % need to direct each r (1:8) con job into the respective folder
    if r == 1
        con = 'warm_grtr_baseline_000';
    elseif r == 2
        con = 'mild_grtr_baseline_000';
    elseif r == 3
        con = 'mod_grtr_baseline_000';
    elseif r == 4
        con = 'allpain_grtr_baseline_000';
    elseif r == 5
        con = 'allpain_grtr_warm_000';
    elseif r == 6
        con = 'mod_grtr_warm_000';
    elseif r == 7
        con = 'mild_grtr_warm_000';
    elseif r == 8
        con = 'mod_grtr_mild_000';
    end
    
    subdir{r} = strcat(con,num2str(r));
    mkdir(strcat(con,num2str(r)));
    b.analys{r} = cellstr(strcat(parent, filesep, subdir{r}));
   
    for j = 1:size(subjs.group1, 1)
        clear d runfld
        % get each con*.nii (1:8) from the analsysis folder for each subject
        % (1:sizesubjs)
        runfld = ['X:\Research_Data\KL2_Subject_Data\' subjs.group1(j,1:4) '\' subjs.group1(j,1:end) '\Analysis'];
        cd(runfld);
        d = dir('con*.nii');
        b.runs.group1{r} = cellstr(strcat(runfld,filesep,{d(r).name})');
    end
    for k = 1:size(subjs.group2, 1)
        clear d runfld
        % get each con*.nii (1:8) from the analsysis folder for each subject
        % (1:sizesubjs)
        runfld = ['X:\Research_Data\KL2_Subject_Data\' subjs.group2(k,1:4) '\' subjs.group2(k,1:end) '\Analysis'];
        cd(runfld);
        d = dir('con*.nii');
        b.runs.group2{r} = cellstr(strcat(runfld,filesep,{d(r).name})');
    end

    %Need to acquire covariates
    %perhaps another loop here
    
    
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

matlabbatch{1}.spm.stats.factorial_design.dir = {'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\Second_Level_Jobs\mod_grtr_mild_0008'};
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = {
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_002\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_003\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_005\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_011\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_012\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_013\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_014\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_016\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_017\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_021\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_029\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_008\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_014\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_015\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_016\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_024\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_025\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_034\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_051\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_054\Analysis\con_0008.nii,1'
                                                           };
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_019\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_022\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_054\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_037\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_038\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_039\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_041\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\SDIP_046\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_010\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_018\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_028\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_029\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_032\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_043\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_048\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_057\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_060\Analysis\con_0008.nii,1'
                                                           'X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\WPAD_061\Analysis\con_0008.nii,1'
                                                           };
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
%%
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [0.06526
                                                      0.82897
                                                      0.36498
                                                      0.33986
                                                      0.51681
                                                      0.06056
                                                      0.09488
                                                      1.61737
                                                      0.2787
                                                      0.49346
                                                      -2.60018
                                                      -0.79803
                                                      -0.50257
                                                      -0.89118
                                                      1.76489
                                                      0.19913
                                                      1.78808
                                                      0.4062
                                                      0.43296
                                                      -1.37005
                                                      0.1922
                                                      -0.25374
                                                      -2.61444
                                                      1.5475
                                                      -0.11974
                                                      -0.17832
                                                      0.26946
                                                      -0.59653
                                                      -0.58329
                                                      -0.11367
                                                      -0.31574
                                                      -1.08184
                                                      -0.43402
                                                      0.93343
                                                      -1.00262
                                                      -0.30662
                                                      0.78519
                                                      0.78269];
%%
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Residual Gray Matter Volume';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
%%
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [2
                                                      0
                                                      0
                                                      0
                                                      2
                                                      0
                                                      5
                                                      0
                                                      0
                                                      0
                                                      3
                                                      0
                                                      0
                                                      0
                                                      1
                                                      0
                                                      1
                                                      0
                                                      1
                                                      4
                                                      2
                                                      0
                                                      1
                                                      2
                                                      1
                                                      0
                                                      2
                                                      2
                                                      2
                                                      8
                                                      0
                                                      4
                                                      3
                                                      7
                                                      13
                                                      3
                                                      3
                                                      5];
%%
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'GDS';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Healthy > AD';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'AD > Healthy';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
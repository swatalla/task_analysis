%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generate 1st Level Contrasts for Data using Artifact Detection Toolbox (ART)
%
%Written by Sebastian Atalla
%8/24/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%% Test
% get_subj_name = uigetdir(cd, 'Choose folder containing desired subject (i.e. Z:/pain_in_older_adults/:');
% cd(get_subj_name)
% clear subj_dir
% subj_dir = dir(cd);
% 
% gen_sel = questdlg('SDIP or WPAD?',...
%     'Gender Menu',...
%     'SDIP','WPAD');
% 
% subj_sel = listdlg('PromptString','Choose subject',...
%     'ListString',{subj_dir.name});
% 
% %insert subject list here:
% subjs = {subj_dir(subj_sel).name};
% subjs = cell2mat(subjs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For ART_first_level_contrast_developer.m, consider condensing
% the script by using a FOR loop instead of an IF/ELSEIF
% loop. This will greatly condense the structure; save to indexed
% "reg_array_run_{r}" and horzcat outside of loop one all reg_arrays
% have been created. Maybe use ifexist or ~isempty to see if the reg_array
% for the target run exists or is not empty
%
% Other things to add are reading the outlier directly out of the .xlsx file
% by summing the # of 1s in the column that indicate outliers. This will
% allow looping over multiple subjects instead of running one at a time

% Also, may be able to assign a numerical value to each contrast so it can
% loop over that as well (i.e. for k=1:8)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Subject Prompt
prompt_subj = {'Enter the subject ID (e.g. WPAD_005/SDIP_021): '};
dlg_title = 'Subject ID';
num_lines = 1;
subj_sel = inputdlg(prompt_subj);
subjs = subj_sel;

%% Static Contrasts
% warm, mild, mod, ramp
warm_grtr_base = [1 0 0 0];
mild_grtr_base = [0 1 0 0];
mod_grtr_base = [0 0 1 0];
all_grtr_base = [0 0.5 0.5 0];
all_grtr_warm = [-1 0.5 0.5 0];
mod_grtr_warm = [-1 0 1 0];
mild_grtr_warm = [-1 1 0 0];
mod_grtr_mild = [0 -1 1 0];

% x,y,z,pitch,roll,yaw,norm
motion = [0 0 0 0 0 0 0];

%% Dialog - This can be cleaned up; maybe use inputdlg
prompt_runs = {'Enter the total number of runs available: '};
dlg_title = 'Total Runs';
num_lines = 1;
total_runs = inputdlg(prompt_runs);
total_runs = str2double(total_runs);

for k = 1:1:total_runs
    prompt_otlrs(k) = {sprintf('Enter the total number of outliers for run %d: ', k)};
    dlg_title = sprintf('Run %d', k);
    num_lines = 1;
    answer_otlrs(k) = inputdlg(prompt_otlrs(k));
    run_outliers(k) = str2double(answer_otlrs(k));
    
end

%% Contrast Generator
if total_runs == 4
    reg_array_run_1 = zeros(1, run_outliers(1));
    reg_array_run_2 = zeros(1, run_outliers(2));
    reg_array_run_3 = zeros(1, run_outliers(3));
    reg_array_run_4 = zeros(1, run_outliers(4));
    
    %1 warm > baseline
    con_warm_grtr_base = horzcat(warm_grtr_base, reg_array_run_1, motion,...
        warm_grtr_base, reg_array_run_2, motion,...
        warm_grtr_base, reg_array_run_3, motion,...
        warm_grtr_base, reg_array_run_4, motion);
    
    %2 mild > baseline
    con_mild_grtr_base = horzcat(mild_grtr_base, reg_array_run_1, motion,...
        mild_grtr_base, reg_array_run_2, motion,...
        mild_grtr_base, reg_array_run_3, motion,...
        mild_grtr_base, reg_array_run_4, motion);
    
    %3 moderate > baseline
    con_mod_grtr_base = horzcat(mod_grtr_base, reg_array_run_1, motion,...
        mod_grtr_base, reg_array_run_2, motion,...
        mod_grtr_base, reg_array_run_3, motion,...
        mod_grtr_base, reg_array_run_4, motion);
    
    %4 all pain > baseline
    con_all_grtr_base = horzcat(all_grtr_base, reg_array_run_1, motion,...
        all_grtr_base, reg_array_run_2, motion,...
        all_grtr_base, reg_array_run_3, motion,...
        all_grtr_base, reg_array_run_4, motion);
    
    %5 all pain > warm
    con_all_grtr_warm = horzcat(all_grtr_warm, reg_array_run_1, motion,...
        all_grtr_warm, reg_array_run_2, motion,...
        all_grtr_warm, reg_array_run_3, motion,...
        all_grtr_warm, reg_array_run_4, motion);
    
    %6 moderate > baseline
    con_mod_grtr_warm = horzcat(mod_grtr_warm, reg_array_run_1, motion,...
        mod_grtr_warm, reg_array_run_2, motion,...
        mod_grtr_warm, reg_array_run_3, motion,...
        mod_grtr_warm, reg_array_run_4, motion);
    
    %7 mild > warm
    con_mild_grtr_warm = horzcat(mild_grtr_warm, reg_array_run_1, motion,...
        mild_grtr_warm, reg_array_run_2, motion,...
        mild_grtr_warm, reg_array_run_3, motion,...
        mild_grtr_warm, reg_array_run_4, motion);
    
    %8 moderate > mild
    con_mod_grtr_mild = horzcat(mod_grtr_mild, reg_array_run_1, motion,...
        mod_grtr_mild, reg_array_run_2, motion,...
        mod_grtr_mild, reg_array_run_3, motion,...
        mod_grtr_mild, reg_array_run_4, motion);
    
elseif total_runs == 3
    reg_array_run_1 = zeros(1, run_outliers(1));
    reg_array_run_2 = zeros(1, run_outliers(2));
    reg_array_run_3 = zeros(1, run_outliers(3));
    
    %1 warm > baseline
    con_warm_grtr_base = horzcat(warm_grtr_base, reg_array_run_1, motion,...
        warm_grtr_base, reg_array_run_2, motion,...
        warm_grtr_base, reg_array_run_3, motion);
    
    
    %2 mild > baseline
    con_mild_grtr_base = horzcat(mild_grtr_base, reg_array_run_1, motion,...
        mild_grtr_base, reg_array_run_2, motion,...
        mild_grtr_base, reg_array_run_3, motion);
    
    %3 moderate > baseline
    con_mod_grtr_base = horzcat(mod_grtr_base, reg_array_run_1, motion,...
        mod_grtr_base, reg_array_run_2, motion,...
        mod_grtr_base, reg_array_run_3, motion);
    
    %4 all pain > baseline
    con_all_grtr_base = horzcat(all_grtr_base, reg_array_run_1, motion,...
        all_grtr_base, reg_array_run_2, motion,...
        all_grtr_base, reg_array_run_3, motion);
    
    %5 all pain > warm
    con_all_grtr_warm = horzcat(all_grtr_warm, reg_array_run_1, motion,...
        all_grtr_warm, reg_array_run_2, motion,...
        all_grtr_warm, reg_array_run_3, motion);
    
    %6 moderate > baseline
    con_mod_grtr_warm = horzcat(mod_grtr_warm, reg_array_run_1, motion,...
        mod_grtr_warm, reg_array_run_2, motion,...
        mod_grtr_warm, reg_array_run_3, motion);
    
    %7 mild > warm
    con_mild_grtr_warm = horzcat(mild_grtr_warm, reg_array_run_1, motion,...
        mild_grtr_warm, reg_array_run_2, motion,...
        mild_grtr_warm, reg_array_run_3, motion);
    
    %8 moderate > mild
    con_mod_grtr_mild = horzcat(mod_grtr_mild, reg_array_run_1, motion,...
        mod_grtr_mild, reg_array_run_2, motion,...
        mod_grtr_mild, reg_array_run_3, motion);
    
elseif total_runs == 2
    reg_array_run_1 = zeros(1, run_outliers(1));
    reg_array_run_2 = zeros(1, run_outliers(2));
    
    %1 warm > baseline
    con_warm_grtr_base = horzcat(warm_grtr_base, reg_array_run_1, motion,...
        warm_grtr_base, reg_array_run_2, motion);
    
    %2 mild > baseline
    con_mild_grtr_base = horzcat(mild_grtr_base, reg_array_run_1, motion,...
        mild_grtr_base, reg_array_run_2, motion);
    
    %3 moderate > baseline
    con_mod_grtr_base = horzcat(mod_grtr_base, reg_array_run_1, motion,...
        mod_grtr_base, reg_array_run_2, motion);
    
    %4 all pain > baseline
    con_all_grtr_base = horzcat(all_grtr_base, reg_array_run_1, motion,...
        all_grtr_base, reg_array_run_2, motion);
    
    %5 all pain > warm
    con_all_grtr_warm = horzcat(all_grtr_warm, reg_array_run_1, motion,...
        all_grtr_warm, reg_array_run_2, motion);
    
    %6 moderate > baseline
    con_mod_grtr_warm = horzcat(mod_grtr_warm, reg_array_run_1, motion,...
        mod_grtr_warm, reg_array_run_2, motion);
    
    %7 mild > warm
    con_mild_grtr_warm = horzcat(mild_grtr_warm, reg_array_run_1, motion,...
        mild_grtr_warm, reg_array_run_2, motion);
    
    %8 moderate > mild
    con_mod_grtr_mild = horzcat(mod_grtr_mild, reg_array_run_1, motion,...
        mod_grtr_mild, reg_array_run_2, motion);
    
elseif total_runs == 1
    reg_array_run_1 = zeros(1, run_outliers(1));
    
    %1 warm > baseline
    con_warm_grtr_base = horzcat(warm_grtr_base, reg_array_run_1, motion);
    
    %2 mild > baseline
    con_mild_grtr_base = horzcat(mild_grtr_base, reg_array_run_1, motion);
    
    %3 moderate > baseline
    con_mod_grtr_base = horzcat(mod_grtr_base, reg_array_run_1, motion);
    
    %4 all pain > baseline
    con_all_grtr_base = horzcat(all_grtr_base, reg_array_run_1, motion);
    
    %5 all pain > warm
    con_all_grtr_warm = horzcat(all_grtr_warm, reg_array_run_1, motion);
    
    %6 moderate > baseline
    con_mod_grtr_warm = horzcat(mod_grtr_warm, reg_array_run_1, motion);
    
    %7 mild > warm
    con_mild_grtr_warm = horzcat(mild_grtr_warm, reg_array_run_1, motion);
    
    %8 moderate > mild
    con_mod_grtr_mild = horzcat(mod_grtr_mild, reg_array_run_1, motion);
else
end

%% Matlab BATCH

%insert subject list here:

for s=1:length(subjs)
    
    
    %insert correct path and filename here:
    filename=['X:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\PSC\' subjs{s} '\Analysis\SPM.mat'];
    
    %edit the contrast name and vector below.
    %in the third line, choose whether to replicate over sessions
    % 'replsc' = "replicate and scale"
    % 'none' = "don't replicate"
    % 'repl' = "replicate"
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'warm>baseline';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = con_warm_grtr_base;
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'mild>baseline';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = con_mild_grtr_base;
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'mod>baseline';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = con_mod_grtr_base;
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'allpain>baseline';
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = con_all_grtr_base;
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'allpain>warm';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = con_all_grtr_warm;
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'mod>warm';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.convec = con_mod_grtr_warm;
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'mild>warm';
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.convec = con_mild_grtr_warm;
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.spmmat = {filename};
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'mod>mild';
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = con_mod_grtr_mild;
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    
    % TO ADD ADDITIONAL CONTRASTS,
    % copy and paste the 3 lines of code above and change the number in the
    % curly braces after ".consess"
    % EXAMPLE:
    
    %matlabbatch{1}.spm.stats.con.spmmat = {filename};
    %matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CON2NAME';
    %matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 1 0 0 0 0 0 0 0 0];
    %matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
    
    %delete existing contrasts?  0=no, 1=yes.
    
    matlabbatch{1}.spm.stats.con.delete = 1;
    
    spm_jobman('run',matlabbatch);
end


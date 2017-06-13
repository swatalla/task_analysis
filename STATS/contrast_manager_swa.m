function contrast_manager_swa()
% Contrast Manager for SPM12
% Use after ART Contrast Developer
% Written by Sebastian Atalla

% enter subjects to run (one per line)
subjs = cell2mat(inputdlg('Enter one subject per session:','Subjects (one per session)', 1, {'' ''}, 'on'));

% create waitbar
wb = waitbar(0,'Running Contrast Manager...');

% for each subject, run preprocessing
for k = 1:size(subjs,1)
    spmfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,1:end) '\Analysis'];
    cd(spmfld);
    d = dir('SPM.mat');
    b.spm = cellstr(strcat(spmfld,filesep,{d.name})');
end
    disp([b.spm]);

try
    matlabbatch = batch_job(b);
    spm_jobman('initcfg');
    spm('defaults','FMRI');
    spm_jobman('interactive', matlabbatch);
    % update waitbar
    waitbar(k/size(subjs,1),wb);
catch emsg % if failed, display subject
    disp(['Error with ' subjs(k,:) ': ' emsg.message]);
end
end

function [matlabbatch] = batch_job(b)
matlabbatch{1}.spm.stats.con.spmmat = b.spm;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'warm>baseline';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'mild>baseline';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'moderate>baseline';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'allpain>baseline';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0.5 0.5 0];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'allpain>warm';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [-1 0.5 0.5 0];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'moderate>warm';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [-1 0 1 0];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'mild>warm';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [-1 1 0 0];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'moderate>mild';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 -1 1 0];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'replsc';
matlabbatch{1}.spm.stats.con.delete = 0;
end
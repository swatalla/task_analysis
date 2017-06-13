% RESEL Recovery Script
% Finds the RESEL count for all subjects specified
% For use with 3dClustSim/AFNI
% Written by Sebastian Atalla
% Edited 1/27/17 - removed duplicate xlswrite();

% enter subjects to run (one per line)
subjs = cell2mat(inputdlg('Enter one subject per line:','Subjects (one per line)', 20, {'' ''}, 'on'));
filename = 'Y:\Research_Data\KL2_Subject_Data\Current_Projects\APS_2017\RESEL.xlsx';
headers = {'Subject','FWHMx','FWHMy','FWHMz','z','pitch','roll','yaw','norm'};

xlswrite(filename,headers,1,'A1');
% for each subject, run RESEL count
for k = 1:size(subjs,1)
    % get SPM.mat file
    spmfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,1:end) '\Analysis'];
    
    % Change to SPM.mat directory
    cd(spmfld)
    
    % FWHM RESEL Recovery Block
    load SPM.mat
    M = SPM.xVol.M; 
    VOX = sqrt(diag(M(1:3,1:3)'*M(1:3,1:3)))'; 
    FWHM = SPM.xVol.FWHM; 
    FWHMmm= FWHM.*VOX;
    disp(subjs(k,1:end));
    disp(FWHMmm);
    
    
    subj_des = sprintf('A%s',num2str((1+((k-1)*4))+1));
    
    xlswrite(filename,subject,subj_des);

end

clear;
marsbar('on');

subjs = cell2mat(inputdlg('Enter one subject per line:','Subjects (one per line)', 20, {'' ''}, 'on'));
wb = waitbar(0,'Fixing Image Path');

for k = 1:size(subjs,1)
    spmPath = ['/Users/atalla.3/Desktop/R21PSC/' subjs(k,1:end) '/Analysis'];

    spmMat = fullfile(spmPath, 'SPM.mat');
    S = load(spmMat);
    S.SPM.swd = deal(spmPath);
    SPM = S.SPM;
    save(spmMat, 'SPM')
    
    imgPath = ['/Volumes/ioSafe/monroe/Research_Data/R21_Subject_Data/' subjs(k,1:4) '/' subjs(k,1:end) '/'];
    
    D = mardo(spmMat);
    D = cd_images(D, imgPath);
    save_spm(D);

    waitbar(k/size(subjs,1),wb);
end
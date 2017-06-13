function Convert_to_Nifti(mainpath,subjfolders,parrec,outfolders,options)
% Convert par/rec files to nii using r2agui
% 
% Inputs (optional):
% mainpath - path to subject folders
% subjfolders - cell array of subject folders with subfolders to par/rec
% files
% parrec - cell array of .par file prefixes (see example)
% outfolders - cell array of outfolders (must be equal in number to parrec
% cell array)
% options - options to be set for convert_r2a (possible fields to set:
% outputformat, prefix, usefullprefix, pathpar, subaan, usealtfolder,
% altfolder, angulation, rescale, dim) 
%
% Example:
% mainpath = '/Volumes/X/Study/';
% subjfolders = {'Subj1/RawData','Subj2/RawData','Subj3/RawData'};
% parrec = {'*T1W*.PAR','*Funct-Resting*.PAR'};
% outfolders = {'Structural','RestingState'};
% Convert_to_Nifti(mainpath,subjfolders,parrec,outfolders)
% 
% Note: If the default filenames are the corresponding outfolders.
% Therefore, if only using using one prefix (e.g., parrec = {'*.PAR'}), be
% sure to set options. Also, if no inputs are used, you will be asked to
% choose/enter the appropriate files, etc.
%

% find convert_r2a if not in matlab path
if isempty(which('convert_r2a'))
rpath = uigetdir(pwd,'Choose the path to the "convert_r2a" file');
if ~any(rpath), return; end;
addpath(rpath);
end
% if no args, set mainpath, subjfolders, parrec, outfolders
if nargin==0
% main path
mainpath = uigetdir(pwd,'Choose main path to all subject folders');
% subjects
subjfolders = cell2mat(inputdlg('Enter subject folders (and subfolders) to par files (e.g. Subj1/RawData):','Subject Folders',20));
subjfolders = arrayfun(@(x){subjfolders(x,:)},1:size(subjfolders,1));
% parrec files
parrec = cell2mat(inputdlg('Enter .par file prefix to search (e.g. *T1W*.par) one per line:','.par prefix',20));
parrec = arrayfun(@(x){parrec(x,:)},1:size(parrec,1));
% output folders
outfolders = cell2mat(inputdlg('Enter output folders (relative to subject folders) to save files to:','Output Folders',20));
outfolders = arrayfun(@(x){outfolders(x,:)},1:size(outfolders,1));
% output format
options.outputformat = listdlg('PromptString','Choose output format:','ListString',{'Nifti','Analyze'});
elseif nargin < 5 % default is Nifti
options.outputformat = 1;
end
% for select subjects
h = waitbar(0,'Running r2agui');
for i = 1:numel(subjfolders)
% for each parrec
for x = 1:numel(parrec)
% find parrec file; if none, skip
clear d; d = dir(fullfile(mainpath,subjfolders{i},parrec{x}));
if isempty(d), continue; end;
% for each parFile
for x1 = 1:numel(d)
clear sourcepath outpath; % set sourcepath, outpath
sourcepath = fullfile(mainpath,subjfolders{i},d(x1).name);
if ~isempty(fileparts(subjfolders{i}))
outpath = fullfile(mainpath,fileparts(subjfolders{i}),outfolders{x});
else % if only input subjfolder
outpath = fullfile(mainpath,subjfolders{i},outfolders{x});    
end
if ~isdir(outpath), mkdir(outpath); end; % mkdir if needed
try
% running
disp(['Running r2agui for ' d(x1).name ' for ' subjfolders{i}]);
% set options if less than 5 args
if nargin < 5
options.prefix = outfolders{x};
options.usefullprefix = 1;
options.pathpar = fileparts(sourcepath);
options.subaan = 1;
options.usealtfolder = 1;
options.altfolder = [fileparts(fileparts(outpath)) filesep]; 
options.angulation = 1;
options.rescale = 1;
options.dim = 3;
end
% run convert_r2a
convert_r2a({[filesep d(x1).name]},options);
% update waitbar
waitbar(i/1:numel(subjfolders),h);
catch exception % if problem
disp(['Problem with ' d(x1).name ' (' subjfolders{i} '): ' exception.message]);
end
end
end
end
% close waitbar
if ishandle(h), close(h); end;
% done
disp('Done');

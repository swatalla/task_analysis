%--------------------------------------------------------------------------------------
% Program to extract event onset times for event related task 
% Author-Jenni Blackford
% Written-August 2011, modified by Meg Bennignfield March 2012 for MID task
%modified by Todd Monroe Dec 4 2012 for WPAD study


%--------------------------------------------------------------------------------------

%test subject is {'NIRR003'}


clear

subjs ={ 'WPAD_010' } ;
%for AD subjects, subjs={'WPAD_51_AD'}; 
csvs={ 'WPAD_10' };


%specify base directory (directory where matlab looks for excel file) this
%is the timing EXL file

   % base=('K:\NIRR DATA\Imaging\EPrime\MIDchng\') ;all of the subjects are
   % in the same EXL file so this step is not necessary

% set destination directory (where the onset.mat files will be saved)
  
    dest = ('X:\Research_Data\KL2_Subject_Data\WPAD\');

for s = 1:length(subjs) 
   
cd([dest subjs{s}]);
mkdir(['Onsets']);
mkdir(['Jobs']);
mkdir(['Analysis']);

cd(['Onsets']);
    
%-----RUN_ 1--------BEGIN COPY HERE----------------------------
%filename defines variable so MatLab can find the csv file from medoc

filename= ['X:\Research_Data\KL2_Subject_Data\WPAD\WPAD_010\Raw_Timing_Files\' csvs{s} '_run1.csv']; %*** change this to next RUN_***

%for AD subjects:
%filename= ['Z:\TimingFiles\' csvs{s} '_run1_AD.csv']; %*** change this to next RUN_***


%read  csv file with header into MatLab
%this line specifies which cells to import from excel file
   
    [timing]=csvread(filename, 1,1);


%create array (type of object in MatLab) for condition names
%0=warm or JNW; 1=WP or Mild; 2=MP or Moderate

   names = cell(1,4);
   names{1} = 'stim_0';
   names{2} = 'stim_1';
   names{3} = 'stim_2';
   names{4} = 'ramps';
   
   
 
%create array for duration times for each event
durations = cell(1,4);
 

   %duration for the ramp times will be pulled from the timing file
 
   durramps=cat(1, timing(1,15), timing (1,27), timing(1,3), timing (1,33), timing(1,9), timing (1,21),  timing(1,18), timing (1,30), timing(1,6), timing (1,36), timing(1,12), timing (1,24));
 
   

   
   %duration for stimuli = 16 seconds 
   durations{1} = 16;
   durations{2} = 16;
   durations{3} = 16;
   durations{4} = durramps/1000;

   
   
%create array to hold onset data
    onsets=cell(1,4);

%pull onset times from excel file


onsstim0= cat(1, timing(1,14), timing (1,26));
onsstim1= cat(1, timing(1,2), timing (1,32));
onsstim2= cat(1, timing(1,8), timing (1,20));
onsramps= cat(1, timing(1,13), timing (1,25),timing(1,16), timing (1,28), timing(1,1), timing(1,31), timing(1,4), timing (1,34),timing(1,7), timing (1,19), timing(1,10), timing (1,22));




   onsets{1}= onsstim0/1000;
   onsets{2}= onsstim1/1000;
   onsets{3}= onsstim2/1000;
   onsets{4}= onsramps/1000;
   

 
%RUN_File is a variable that designates the name for onsets.mat file that will be
%saved in next step
%need file to have different name for each RUN_ to specify onsets for first
%level.

   RUN_file = strcat('Onsets1') ;  %change this to Onsets2, Onsets3, Onsets4 for add'l RUN_s
  
   %save a file called whatever the current value of the RUN_File variable
   %that contains the objects names, onstes, and durations
   save(RUN_file,'names', 'onsets', 'durations') 
  
   %RUN_ 2/3
   filename= ['X:\Research_Data\KL2_Subject_Data\WPAD\WPAD_010\Raw_Timing_Files\' csvs{s} '_run2.csv']; %*** change this to next RUN_***

%for AD subjects:
%filename= ['Z:\TimingFiles\' csvs{s} '_run2_AD.csv']; %*** change this to next RUN_***


%read  csv file with header into MatLab
%this line specifies which cells to import from excel file
   
    [timing]=csvread(filename, 1,1);


%create array (type of object in MatLab) for condition names
%0=warm or JNW; 1=WP or Mild; 2=MP or Moderate

   names = cell(1,4);
   names{1} = 'stim_0';
   names{2} = 'stim_1';
   names{3} = 'stim_2';
   names{4} = 'ramps';
   
   
 
%create array for duration times for each event
durations = cell(1,4);
 

   %duration for the ramp times will be pulled from the timing file
 
   durramps=cat(1, timing(1,9), timing (1,21), timing(1,15), timing (1,27), timing(1,3), timing (1,33),  timing(1,12), timing (1,24), timing(1,18), timing (1,30), timing(1,6), timing (1,36));
 
   

   
   %duration for stimuli = 16 seconds 
   durations{1} = 16;
   durations{2} = 16;
   durations{3} = 16;
   durations{4} = durramps/1000;

   
   
%create array to hold onset data
    onsets=cell(1,4);

%pull onset times from excel file


onsstim0= cat(1, timing(1,8), timing (1,20));
onsstim1= cat(1, timing(1,14), timing (1,26));
onsstim2= cat(1, timing(1,2), timing (1,32));
onsramps= cat(1, timing(1,7), timing (1,19), timing(1,10), timing (1,22), timing(1,13), timing(1,25), timing(1,16), timing (1,28), timing(1,1), timing (1,31), timing(1,4), timing (1,34));




   onsets{1}= onsstim0/1000;
   onsets{2}= onsstim1/1000;
   onsets{3}= onsstim2/1000;
   onsets{4}= onsramps/1000;
   

 
%RUN_File is a variable that designates the name for onsets.mat file that will be
%saved in next step
%need file to have different name for each RUN_ to specify onsets for first
%level.

   RUN_file = strcat('Onsets2') ;  %change this to Onsets2, Onsets3, Onsets4 for add'l RUN_s
  
   %save a file called whatever the current value of the RUN_File variable
   %that contains the objects names, onstes, and durations
   save(RUN_file,'names', 'onsets', 'durations') 
  
   %RUN_ 2/3
   filename= ['X:\Research_Data\KL2_Subject_Data\WPAD\WPAD_010\Raw_Timing_Files\' csvs{s} '_run3.csv']; %*** change this to next RUN_***

%for AD subjects:
%filename= ['Z:\TimingFiles\' csvs{s} '_run3_AD.csv']; %*** change this to next RUN_***


%read  csv file with header into MatLab
%this line specifies which cells to import from excel file
   
    [timing]=csvread(filename, 1,1);


%create array (type of object in MatLab) for condition names
%0=warm or JNW; 1=WP or Mild; 2=MP or Moderate

   names = cell(1,4);
   names{1} = 'stim_0';
   names{2} = 'stim_1';
   names{3} = 'stim_2';
   names{4} = 'ramps';
   
   
 
%create array for duration times for each event
durations = cell(1,4);
 

   %duration for the ramp times will be pulled from the timing file
 
   durramps=cat(1, timing(1,9), timing (1,21), timing(1,15), timing (1,27), timing(1,3), timing (1,33),  timing(1,12), timing (1,24), timing(1,18), timing (1,30), timing(1,6), timing (1,36));
 
   

   
   %duration for stimuli = 16 seconds 
   durations{1} = 16;
   durations{2} = 16;
   durations{3} = 16;
   durations{4} = durramps/1000;

   
   
%create array to hold onset data
    onsets=cell(1,4);

%pull onset times from excel file


onsstim0= cat(1, timing(1,8), timing (1,20));
onsstim1= cat(1, timing(1,14), timing (1,26));
onsstim2= cat(1, timing(1,2), timing (1,32));
onsramps= cat(1, timing(1,7), timing (1,19), timing(1,10), timing (1,22), timing(1,13), timing(1,25), timing(1,16), timing (1,28), timing(1,1), timing (1,31), timing(1,4), timing (1,34));




   onsets{1}= onsstim0/1000;
   onsets{2}= onsstim1/1000;
   onsets{3}= onsstim2/1000;
   onsets{4}= onsramps/1000;
   

 
%RUN_File is a variable that designates the name for onsets.mat file that will be
%saved in next step
%need file to have different name for each RUN_ to specify onsets for first
%level.

   RUN_file = strcat('Onsets3') ;  %change this to Onsets2, Onsets3, Onsets4 for add'l RUN_s
  
   %save a file called whatever the current value of the RUN_File variable
   %that contains the objects names, onstes, and durations
   save(RUN_file,'names', 'onsets', 'durations') 
   
   %RUN_ 4
   filename= ['X:\Research_Data\KL2_Subject_Data\WPAD\WPAD_010\Raw_Timing_Files\' csvs{s} '_run4.csv']; %*** change this to next RUN_***

%for AD subjects:
%filename= ['Z:\TimingFiles\' csvs{s} '_run4_AD.csv']; %*** change this to next RUN_***


%read  csv file with header into MatLab
%this line specifies which cells to import from excel file
   
    [timing]=csvread(filename, 1,1);


%create array (type of object in MatLab) for condition names
%0=warm or JNW; 1=WP or Mild; 2=MP or Moderate

   names = cell(1,4);
   names{1} = 'stim_0';
   names{2} = 'stim_1';
   names{3} = 'stim_2';
   names{4} = 'ramps';
   
   
 
%create array for duration times for each event
durations = cell(1,4);
 

   %duration for the ramp times will be pulled from the timing file
 
   durramps=cat(1, timing(1,15), timing (1,33), timing(1,9), timing (1,21), timing(1,3), timing (1,27),  timing(1,18), timing (1,36), timing(1,12), timing (1,24), timing(1,6), timing (1,30));
 
   

   
   %duration for stimuli = 16 seconds 
   durations{1} = 16;
   durations{2} = 16;
   durations{3} = 16;
   durations{4} = durramps/1000;

   
   
%create array to hold onset data
    onsets=cell(1,4);

%pull onset times from excel file


onsstim0= cat(1, timing(1,14), timing (1,32));
onsstim1= cat(1, timing(1,8), timing (1,20));
onsstim2= cat(1, timing(1,2), timing (1,26));
onsramps= cat(1, timing(1,13), timing (1,31),timing(1,16), timing (1,34), timing(1,7), timing(1,19), timing(1,10), timing (1,22),timing(1,1), timing (1,25), timing(1,4), timing (1,28));




   onsets{1}= onsstim0/1000;
   onsets{2}= onsstim1/1000;
   onsets{3}= onsstim2/1000;
   onsets{4}= onsramps/1000;
   

 
%RUN_File is a variable that designates the name for onsets.mat file that will be
%saved in next step
%need file to have different name for each RUN_ to specify onsets for first
%level.

   RUN_file = strcat('Onsets4') ;  %change this to Onsets2, Onsets3, Onsets4 for add'l RUN_s
  
   %save a file called whatever the current value of the RUN_File variable
   %that contains the objects names, onstes, and durations
   save(RUN_file,'names', 'onsets', 'durations') 
  
end
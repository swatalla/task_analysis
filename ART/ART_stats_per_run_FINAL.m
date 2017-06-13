
subjs = cell2mat(inputdlg('Enter one subject per line:','Subjects (one per line)', 20, {'' ''}, 'on'));
filename = 'C:\Users\atallas\Documents\ART_Subject_Motion_PerRun_MEAN.xlsx';
headers = {'Subject','run #','x','y','z','pitch','roll','yaw','norm'};

xlswrite(filename,headers,1,'A1');

for k = 1:size(subjs,1)
    clear b t;
    for r = 1:4
        try
            clear runfld d;
            runfld = ['Y:\Research_Data\KL2_Subject_Data\' subjs(k,1:4) '\' subjs(k,1:end) '\Functional\' subjs(k,1:end) '_run_' num2str(r)];
            cd(runfld)
            
            d = dir('art_regression_outliers_and_movement*.mat');
            load(d.name,'R');
            [nrow,ncol] = size(R);
            b.avg{r} = mean(R(1:end,(ncol-6):ncol));
            
            
            a.ls{r} = {b.avg{r}(1,1),b.avg{r}(1,2),b.avg{r}(1,3),b.avg{r}(1,4),b.avg{r}(1,5),b.avg{r}(1,6),b.avg{r}(1,7)};
            subject = {subjs(k,1:end)};
            z.NumRun{r} = {strcat('run_',num2str(r))};
            
            subj_des = sprintf('A%s',num2str((1+((k-1)*4))+1));
            run_des = sprintf('B%s',num2str(((r+1)+((k-1)*4))));
            cell_des = sprintf('C%s',num2str(((r+1)+((k-1)*4))));
            
            xlswrite(filename,subject,1,subj_des);
            xlswrite(filename,z.NumRun{r},1,run_des);

            xlswrite(filename,a.ls{r}(1,:),1,cell_des);
            
        catch
        end
        
    end
    disp(subjs(k,1:end))
end


%     a.ls{r} = {'x','y','z','pitch','roll','yaw','norm';
%      b.avg{r}(1,1),b.avg{r}(1,2),b.avg{r}(1,3),b.avg{r}(1,4),b.avg{r}(1,5),b.avg{r}(1,6),b.avg{r}(1,7)};

%     xlswrite(filename,a.ls{r}(1,:),1,cell_des);
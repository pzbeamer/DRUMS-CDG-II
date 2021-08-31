clear all
close all

T = readtable('../PatientInfo07212021.csv','Headerlines',2);

for pt = 22:872
    pt_id = T{pt,1}{1};
    
    for i=1:4
        if isfile(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/ForwardEvaluation/nomHRs/', pt_id, '_val', num2str(i),'_nomHR.mat'))
            load(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/ForwardEvaluation/nomHRs/', pt_id, '_val', num2str(i),'_nomHR.mat'));
            pt_id
            val_start = data.val_start;
            val_end = data.val_end;
            Hdata = data.Hdata;
            Pdata = data.Pdata;
            
            HRbeforeVal = mean(Hdata(1:round(val_start)));
            HRadfterVal = mean(Hdata(round(val_end):end));
            SBPbeforeVal = mean(Pdata(1:round(val_start)));
            SBPafterVal = mean(Pdata(round(val_end):end));
        end
    end
end
%% No saveDat
clear all

T=readtable('../Data Processing/PatientInfo07212021.csv');

ct=0;
ct1=0;
ct2=0;
ct3=0;
ctfile=0;
%'HPV592_20150825_optimized.mat','HPV592_20151211_optimized.mat','HPV593_20160419_optimized.mat'
%pt = 654,655,656
%have no saveDat, suggesting major workspace issue/ spreadsheet

for pt=3:872
    pt_id=T{pt,1}{1};
    if isfile(strcat('../Results/Optimizations/',pt_id,'_optimized.mat'))
        ctfile=ctfile+1;

        load(strcat('../Results/Optimizations/',pt_id,'_optimized.mat'))
        
        try
            saveDat;
            if saveDat.flag(1)==1
                flagBadErr{1,ct1+1}=pt_id;
                ct1=ct1+1;
            end
            if saveDat.flag(2)==1
            	flagDiverge{1,ct2+1}=pt_id;
                ct2=ct2+1;
            end
            if saveDat.flag(1)==1 && saveDat.flag(2)==1
                ct3=ct3+1;
            end
            clear saveDat;
            
        catch
            pt
            flags{1,ct+1}=pt_id;
            ct=ct+1;
        end
    end
end
    


save ('../Results/Analysis/flagDiverge.mat','flagDiverge')
save ('../Results/Analysis/flagBadErr.mat','flagBadErr')
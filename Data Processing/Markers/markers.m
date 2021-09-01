T = readtable('../PatientInfo07212021.csv','Headerlines',2);
beta=cell(2,872);
ct=1;
for pt = 6:40
    pt
    pt_id = T{pt,1}{1}
    for i = 1
        pt_file_name = strcat(pt_id,'_val_nomHR.mat');
        
        if isfile(strcat('../Valsalva/nomHR_residuals/',pt_file_name))
            load(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/ForwardEvaluation/nomHRs/',pt_file_name),'data');
            load(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/LSA/Vals_New/',pt_file_name(1:end-9),'WS.mat'),'val_dat');
            %can't load drive on cluster
            
%% Beta
            EKG=val_dat(:,2);
            Tall=val_dat(:,1);
            inds=makeR(Tall,EKG); % calls makeR.m
            Rpeaks=Tall(inds); % for not is is over the whole time even rest
            %figure;
            %plot(Rpeaks,EKG(inds),'o',Tall,EKG,'m');
            diffs=diff(Rpeaks);
            maxRint=max(diffs)*10^3;
            minRint=min(diffs)*10^3;
            maxSP=max(val_dat(:,4));
            baseSP=mean([data.Pdata(1:data.i_ts)' data.Pdata(data.i_t4:end)']);
            bet_a=(maxRint-minRint)/(maxSP-baseSP);
            %bet_a=bet_a*10^6;
            beta{1,ct}=bet_a;
            beta{2,ct}=pt_id;
            ct=ct+1;
%% Gamma 
            pt_id
            gamma = max(data.Hdata(data.i_te:data.i_t3))/min(data.Hdata(data.i_t3:data.i_t4))

%% Baselines

            val_start = data.val_start;
            val_end = data.val_end;
            Hdata = data.Hdata;
            Pdata = data.Pdata;
            
            HRbeforeVal = mean(Hdata(1:round(val_start)));
            HRafterVal = mean(Hdata(round(val_end):end));
            SBPbeforeVal = mean(Pdata(1:round(val_start)));
            SBPafterVal = mean(Pdata(round(val_end):end));

%% Alpha

pressure = data.Pdata(data.i_t1:data.i_te);
          
          time = data.Tdata(data.i_t1:data.i_te);
          
          maximum = find(pressure == max(pressure));
          minimum = find(pressure == min(pressure));
          alpha(1,pt-3) = (pressure(maximum) - pressure(minimum))...
              /(time(maximum)-time(minimum));
          
%% Max HR and BP

%Phase 2


%Phase 3

        save('../../Results/markers.mat','alpha','beta','gamma','HRbeforeVal','HRafterVal','SBPbeforeVal','SBPafterVal')
        end
    end    
end
clear all
close all
format shortg
T=readtable('../PatientInfo07212021.csv');
load('../../Results/Summary/summary.mat','uniqueTimes');
pots_pats=cell(872,1);
oldcount=1;
newcount=1;
c=0;
p = 0;


for pt=27



    p = 0;
    T{pt,1}{1}
    if any(uniqueTimes(2,pt-2))
        c=c+1;
        p = 1;
         if isfile(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/LSA/AS/',T{pt,1}{1},'_AS_WS.mat'));
            disp("isfile");
            
            load(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/LSA/AS/',T{pt,1}{1},'_AS_WS.mat'));

            %rest_ind=1;
            %end_ind=last index
            start_ind_a=find(abs(Tdata-AS_start)==min(abs(Tdata-AS_start)));
            end_avg_ind_a=find(abs(Tdata-(AS_start-5))==min(abs(Tdata-(AS_start-5))));
            
            
            begin_avg_ind_a=find(abs(Tdata-(AS_start-AS_rest))==min(abs(Tdata-(AS_start-AS_rest))));

            avg_HR_before_a=median(Hdata(begin_avg_ind_a:end_avg_ind_a));
            maxHR_a=max(movmean(Hdata(start_ind_a:end), 50));
            figure(pt+2)
            subplot(2,1,2)
            hold on
            plot(Tdata,Hdata,'linewidth',3)
            if T{pt,3}>19
                yline(avg_HR_before_a+30,'r','linewidth',3)
            else
                yline(avg_HR_before_a+40,'r','linewidth',3)

            end
            xline(AS_start,'b')
            title('AS')



            

%             if (maxHR_a>=avg_HR_before_a+30 && T{pt,3}>19) || (maxHR_a>=avg_HR_before_a+40)
%                 disp(strcat(T{pt,1}," Meets Qualifications"));
%                 pots_pats(pt-2)=T{pt,1};
%                 newcount=newcount+1;
% 
%             end
        end
    end
    if any(uniqueTimes(1,pt-2))
        if p == 0
            c = c+1;
        end
        if isfile(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/LSA/HUT/',T{pt,1}{1},'_HUT_WS.mat')) && oldcount==newcount 
            disp("isfile");
            load(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/LSA/HUT/',T{pt,1}{1},'_HUT_WS.mat'));

            %rest_ind=1;
            %end_ind=last index
            start_ind_h=find(abs(Tdata-HUT_start)==min(abs(Tdata-HUT_start)));
            end_avg_ind_h=find(abs(Tdata-(HUT_start-15))==min(abs(Tdata-(HUT_start-15))));
            
            begin_avg_ind_h=find(abs(Tdata-(HUT_start-HUT_rest))==min(abs(Tdata-(HUT_start-HUT_rest))));
            

            avg_HR_before_h=median(Hdata(begin_avg_ind_h:end_avg_ind_h));
            maxHR_h=max(movmean(Hdata(start_ind_h:end), 100));
            
            
            
            figure(pt+2)
            subplot(2,1,1)

            hold on
            plot(Tdata,Hdata,'linewidth',3)
            if T{pt,3}>19
                yline(avg_HR_before_h+30,'r','linewidth',3)
            else
                yline(avg_HR_before_h+40,'r','linewidth',3)
            end
            xline(HUT_start,'b')

            title('HUT')

%             if (maxHR_h>=avg_HR_before_h+30 && T{pt,3}>19) || (maxHR_h>=avg_HR_before_h+40)
%                 disp(strcat(T{pt,1}," Meets Qualifications"));
%               
%                 pots_pats(pt-2)=T{pt,1};
%                 newcount=newcount+1;
%             end
        end
    end
%     if oldcount~=newcount
%         oldcount=newcount;
%     end
    
end

save('../../Results/POTS_Patients/potspats.mat','pots_pats');
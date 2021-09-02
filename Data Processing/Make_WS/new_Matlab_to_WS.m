%% READ TABLE 

clear all  
T = readtable('../PatientInfo07212021.csv','Headerlines',2);
% Td = readtable('../HPV_demographic_info_2_9_21.csv'); %THIS WILL PRODUCE WARNINGS BUT IT'S FINE d = demographics
% HPV_numbers = Td.HPV_nummer;
% Ages = Td.Alder;
% Sexes = zeros(length(Ages),1); 
% for i = 1:length(Ages)
%     if ~isempty(Td.Male_(i))
%         Sexes(i) = 1;
%     end
% end

%% Column Numbers 
pts = 1;
ages = 3;
heights = 4;
weights = 5;
genders = 6;
beta2jas = 7;
beta2nejs = 8;
m2jas = 9;
m2nejs = 10;
NOPjas = 11;
NOPnejs = 12;
Starttimeofdatas = 13;
Notes = 14;
HUTrests = 15;
HUTstarts = 16;
HUTends = 17;
HUTNG = 18; %Change from previous table 2/14/21 - all below are +1
HUTnotes = 19;
ASrests = 20;
ASstarts = 21;
ASends = 22;
ASnotes = 23;
DBrests = 24; %Deep breathing 
DBstarts = 25;
DBends = 26;
DBnotes = 27;
Vals = [28:32;33:37;38:42;43:47]; %Each row a new val, cols rest, start, end,rest end, notes


%% Other Variables 
max_HPV_num = 872; % will change for all values
rtas = 180; %desired rest time for AS
rthut = 270; %desired rest time for HUT
rtdb = 100; %desired rest time for DB
make_AS = 1;
make_HUT = 0;
make_DB = 0;
make_VAL = 0;

%% Load In Matlab Files 
%index 50 does not have blood pressure
%index 784 has issue, not with spread, calibration occurs during it which 
%might explain it, the issue comes with getting the systolic bp measure

%% WHICH PATIENT ARE WE LOOKING AT? CHANGE THIS TO MOVE ON TO NEW PATIENT 
%Patient numbers range from 3-872, we've got to go through all of them
%Many patients will not have any data, and if this is the case no figures
%will show up. If that happens just move on to the next one.

for pt=[3:12]
    %% PREPROCESS DATA AND STUFF 
    pt
    pt_id = T{pt,1}{1}
    if isfile(strcat('/Volumes/GoogleDrive/.shortcut-targets-by-id/1Vnypyb_cIdCMJ49vzcg8V7cWblpVCeYZ/HPV_Data/MATLAB_Files/',pt_id,'.mat'))
        load(strcat('/Volumes/GoogleDrive/.shortcut-targets-by-id/1Vnypyb_cIdCMJ49vzcg8V7cWblpVCeYZ/HPV_Data/MATLAB_Files/',pt_id,'.mat'))
        start_time_of_file = 0;
        automatically_match_channels = 1;

        if strcmp(titles(2,:),'Blodtryk, finger')
            titles=titles(:,1:15);
            titles(2,:)='Blodtryk finger';
        end

        if automatically_match_channels == 1 && pt~=337
            channels = ['EKG            ';'Hjertefrekvens ';'Blodtryk finger'];
            channel_inds = zeros(3,1);
            for j = 1:size(channels,1)
                for k = 1:size(titles,1)
                    if min(channels(j,:) == titles(k,:)) == 1
                        channel_inds(j) = k;
                    end
                end
            end
            if min(channel_inds) == 0
                error('Unable to automatically match channels - match manually')
            end
        else
            channel_inds = [1,2,3]; %Put in indecies for channels for EKG, HR, BP
            %Position in channel_inds is what column in dat you want it to be
            %Number is what column it is in the data from labchart
        end


        %Assemble data
        %ttt=T{pt,Starttimeofdatas}
        %tstart = str2double(T{pt,Starttimeofdatas}{1});
        %tstart=celltime_to_seconds(T{pt,Starttimeofdatas});
        tstart=0;
        if isnumeric(tstart) %If tstart is a number don't do anything
        elseif isnan(str2double(T{pt,Starttimeofdatas}{1})) && isempty(str2double(T{pt,Starttimeofdatas}{1}))
            tstart = 0; %Assume if nothing is written then start time is 0
        elseif isnan(str2double(T{pt,Starttimeofdatas}{1}))
            error(strcat('Not numerical input for tstart, check index i = ',num2str(pt)))
        else
            error(strcat('Undefined error concerning tstart, check index i = ',num2str(pt)))
        end
        
        sz=size(dataend);
        endtime=dataend(1,1);
        cols=sz(2);
        if cols>1
            for i=2:cols
                endtime=endtime+(dataend(1,i)-dataend(end,i-1));
            end
        end

        dat = zeros(endtime,4);
        if length(tickrate) ~= 1
            if mean(tickrate) == tickrate(1)
                tickrate = tickrate(1);
            else
                error(strcat('Check tickrate - something strange. Index ',num2str(pt)))
            end
        end

        dummy_time_vec= tstart:1/tickrate:endtime/tickrate-1/tickrate;
        dat(:,1) = dummy_time_vec+start_time_of_file;
        for j = 1:length(channel_inds)
            alldata=data(datastart(channel_inds(j),1):dataend(channel_inds(j),1));
            for i=2:cols
                alldata=[alldata data(datastart(channel_inds(j),i):dataend(channel_inds(j),i))];
            end
            dat(:,j+1) = alldata;%data(datastart(channel_inds(j)):dataend(channel_inds(j))); %i+1 b/c time in column 1
        end
        t = dat(:,1);


        Age = T{pt,ages};
        Sex = T{pt,genders};
        cell_row_for_pt=T(pt,:);

        %% ---- AS ---- (SOPHIE CAN IGNORE)
        if make_AS==1
            if ~isempty(T{pt,ASrests}{1})
                AS_rest = celltime_to_seconds(T{pt,ASrests});
                AS_start = celltime_to_seconds(T{pt,ASstarts});
                AS_end = celltime_to_seconds(T{pt,ASends});
                AS_times = [AS_rest,AS_end];
                AS_inds = zeros(1,length(AS_times));
                for j = 1:length(AS_inds)
                    AS_inds(j) = find(abs(t-AS_times(j)) == min(abs(t-AS_times(j))));
                end
                if AS_inds(1)==AS_inds(2) || AS_start > endtime/1000 || AS_end > endtime/1000
                    strcat('Nicole says AS Error with ',pt_id)
                    return
                end
                AS_s = AS_inds(1):AS_inds(2);
                AS_dat = dat(AS_s,:);

                s = (1:100:length(AS_dat(:,1)))'; %Sampling vector 2.5 Hz
                %Calculate needed quantities before you subsample down
                pkprom = 25.*ones(max_HPV_num,1);
                [SPdata S] = SBPcalc_ben(AS_dat(:,1),AS_dat(:,4),1,0);
                SPdata = SPdata(s);
                sdat = AS_dat(s,:);
                Tdata = sdat(:,1);
                ECG = sdat(:,2);
                Hdata = sdat(:,3);
                Pdata = sdat(:,4);
                ASrestind = find(abs(Tdata-AS_rest) == min(abs(Tdata-AS_rest)));
                ASendind = find(abs(Tdata-AS_end) == min(abs(Tdata-AS_end)));
                ASstartind = find(abs(Tdata-AS_start) == min(abs(Tdata-AS_start)));

                flag = 0;
                if Tdata(ASstartind)-Tdata(ASrestind)<rtas
                    flag = 1;
                end

                notes = T{pt,ASnotes};
                if ~isempty(notes)
                    disp(strcat('There are AS notes for i=',num2str(pt)))
                end
                if flag>0
                    disp(strcat('AS rest time does not meet desired for i=',num2str(pt)))
                end


                save(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/Workspaces/AS/',pt_id,'_AS_WS.mat'),... %Name of file
                         'Age','ECG','Hdata','Pdata','Sex','SPdata','Tdata','flag',...
                         'AS_rest','AS_start','AS_end','notes','cell_row_for_pt') %Variables to save
            end
        end
        


           %% ---- HUT ---- (SOPHIE CAN IGNORE)
        if make_HUT==1
            if ~isempty(T{pt,HUTrests}{1})
                HUT_rest = celltime_to_seconds(T{pt,HUTrests});
                HUT_start = celltime_to_seconds(T{pt,HUTstarts});
                HUT_end = celltime_to_seconds(T{pt,HUTends});
                HUT_times = [HUT_rest,HUT_end];
                HUT_inds = zeros(1,length(HUT_times));
                for j = 1:length(HUT_inds)
                        find(abs(t-HUT_times(j)) == min(abs(t-HUT_times(j))));
                        HUT_inds(j) = find(abs(t-HUT_times(j)) == min(abs(t-HUT_times(j))));
                end

                HUT_s = HUT_inds(1):HUT_inds(2);
                HUT_dat = dat(HUT_s,:);
                if HUT_inds(1)==HUT_inds(2) || HUT_start > endtime/1000 || HUT_end > endtime/1000
                    strcat('Nicole says HUT Error with ',pt_id)
                    return
                end
                s = (1:100:length(HUT_dat(:,1)))'; %Sampling vector 2.5 Hz
                %Calculate needed quantities before you subsample down
                pkprom = 25.*ones(max_HPV_num,1);
                [SPdata S] = SBPcalc_ben(HUT_dat(:,1),HUT_dat(:,4),1);
                SPdata = SPdata(s);
                sdat = HUT_dat(s,:);
                Tdata = sdat(:,1);
                ECG = sdat(:,2);
                Hdata = sdat(:,3);
                Pdata = sdat(:,4);
                HUTrestind = find(abs(Tdata-HUT_rest) == min(abs(Tdata-HUT_rest)));
                HUTendind = find(abs(Tdata-HUT_end) == min(abs(Tdata-HUT_end)));
                HUTstartind = find(abs(Tdata-HUT_start) == min(abs(Tdata-HUT_start)));

                flag = 0;
                if Tdata(HUTstartind)-Tdata(HUTrestind)<rthut
                    flag = 1;
                end

                notes = T{pt,HUTnotes};
                if ~isempty(notes)
                    disp(strcat('There are HUT notes for i=',num2str(pt)))
                end
                if flag>0
                    disp(strcat('HUT rest time is less than desired for i=',num2str(pt)))
                end

               

                save(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/Workspaces/HUT/',pt_id,'_HUT_WS.mat'),... %Name of file
                         'Age','ECG','Hdata','Pdata','Sex','SPdata','Tdata','flag',...
                         'HUT_rest','HUT_start','HUT_end','notes','cell_row_for_pt') %Variables to save
            end
        end
        
                %% ---- DB ---- (SOPHIE CAN IGNORE)
        if make_DB==1
            if ~isempty(T{pt,DBrests}{1})
                DB_rest = celltime_to_seconds(T{pt,DBrests});
                DB_start = celltime_to_seconds(T{pt,DBstarts});
                DB_end = celltime_to_seconds(T{pt,DBends});
                DB_times = [DB_rest,DB_end];
                DB_inds = zeros(1,length(DB_times));
                for j = 1:length(DB_inds)
                    DB_inds(j) = find(abs(t-DB_times(j)) == min(abs(t-DB_times(j))));
                end
                if DB_inds(1)==DB_inds(2) || DB_start > endtime/1000 || DB_end > endtime/1000
                    strcat('Nicole says DB Error with ',pt_id)
                    return
                end
                DB_s = DB_inds(1):DB_inds(2);
                DB_dat = dat(DB_s,:);

                s = (1:100:length(DB_dat(:,1)))'; %Sampling vector 2.5 Hz
                %Calculate needed quantities before you subsample down
                pkprom = 25.*ones(max_HPV_num,1);
                [SPdata S] = SBPcalc_ben(DB_dat(:,1),DB_dat(:,4),1);
                SPdata = SPdata(s);
                sdat = DB_dat(s,:);
                Tdata = sdat(:,1);
                ECG = sdat(:,2);
                Hdata = sdat(:,3);
                Pdata = sdat(:,4);
                DBrestind = find(abs(Tdata-DB_rest) == min(abs(Tdata-DB_rest)));
                DBendind = find(abs(Tdata-DB_end) == min(abs(Tdata-DB_end)));
                DBstartind = find(abs(Tdata-DB_start) == min(abs(Tdata-DB_start)));

                flag = 0;
                if Tdata(DBstartind)-Tdata(DBrestind)<rtdb
                    flag = 1;
                end

                notes = T{pt,DBnotes};
                if ~isempty(notes)
                    disp(strcat('There are DB notes for i=',num2str(pt)))
                end
                if flag>0
                    disp(strcat('DB rest time does not meet desired for i=',num2str(pt)))
                end


                save(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/Workspaces/DB/',pt_id,'_DB_WS.mat'),... %Name of file
                         'Age','ECG','Hdata','Pdata','Sex','SPdata','Tdata','flag',...
                         'DB_rest','DB_start','DB_end','notes','cell_row_for_pt') %Variables to save
            end
        end
        
        %% Valsalva (SOPHIE CAN IGNORE)
        
        if make_VAL==1
            rt1 = 30;
            rt2 = 30; %Make sure these agree with those above

            val_check = zeros(1,4);
            for i = 1:4
                val_check(i) = ~isempty(T{pt,Vals(i,1)}{1});
            end
            num_of_vals = sum(val_check);
            
            if num_of_vals > 0
                for i = 1:4
                    if val_check(i)%1:num_of_vals 
                        val_rest_start = celltime_to_seconds(T{pt,Vals(i,1)});
                        val_start = celltime_to_seconds(T{pt,Vals(i,2)});
                        val_end = celltime_to_seconds(T{pt,Vals(i,3)});
                        val_rest_end = celltime_to_seconds(T{pt,Vals(i,4)});
                        
                        val_times = [val_rest_start,val_rest_end]; %Rest start and Rest end
                        val_inds = zeros(1,length(val_times));
                        for j = 1:length(val_inds)
                            val_inds(j) = find(abs(t-val_times(j)) == min(abs(t-val_times(j))));
                        end
                        val_s = val_inds(1):val_inds(2);
                        val_dat = dat(val_s,:);
 
                        s = (1:100:length(val_dat(:,1)))'; %Sampling vector 2.5 Hz
                        sdat = val_dat(s,:);
                        Tdata = sdat(:,1);
                        ECG = sdat(:,2);
                        Hdata = sdat(:,3);
                        Pdata = sdat(:,4);
                        Pth = zeros(length(Tdata),1);
                        VALstartind = find(abs(Tdata-val_start) == min(abs(Tdata-val_start)));
                        VALendind = find(abs(Tdata-val_end) == min(abs(Tdata-val_end)));
                        VALresteind = find(abs(Tdata-val_rest_end) == min(abs(Tdata-val_rest_end)));
                        Pth(VALstartind:VALendind) = 40.*ones(length(VALstartind:VALendind),1);
                        
                        
                        %Calculate needed quantities before you subsample down
                        Rdata_not_sampled = makeresp(val_dat(:,1),val_dat(:,2),0);%Be careful, I added line 8 in the function, may cause problems.
                        Rdata = Rdata_not_sampled(s);
                        

                     
                   
%% SOPHIE SPOT

%Change this minPeakDistance variable whenever the systolic blood pressure figures look bad. Remember
%increasing minPeakDistance captures more peaks and decreasing it captures fewer. Also, try stay
%within like .1-.5 as values. If no values in there work just pick the least bad one you can find.

                        
                        minPeakDistance = .30;
                        [SPdata S] = SBPcalc_ben(val_dat(:,1),val_dat(:,4),minPeakDistance,1);
                        
                        %% Valsalva continued (SOPHIE CAN IGNORE)
                        
                        
                        SPdata = SPdata(s);
                        
                        %SPdata2 = S(val_dat(s,1));
                        %figure(15);
                        %clf
                        %plot(Tdata,SPdata1,'g',val_dat(:,1),val_dat(:,4),'b',Tdata,SPdata2,'r');

                        
                        
                        
                        
                        
                        
                        % FLAGGING SHORTENED REST PERIODS
                        % "Column" 4 is a 3x1 vector,entries are as follows:
                        % flag(1) = 1 if rest before valsalva is shorter than rt1, 0 o/w
                        % flag(2) = 1 if rest after valsalva is shorter than rt2, 0 o/w
                        % flag(3) = 1 if time between valsalva end and start of next manenuver
                        % is less than rt2, 0 if this time is larger than rt2 or if flag(2) = 0
                        flag = zeros(3,1);
                        if val_start - val_rest_start < rt1
                            flag(1) = 1;
                        end
                        if val_rest_end - val_end < rt2
                            flag(2) = 1;
                        end
                        indices = [HUTstarts ASstarts DBstarts Vals(1,2) Vals(2,2) Vals(3,2) Vals(4,2)];
                        times = zeros(1,7);
                        for ii = 1:7
                            if ~isempty(T{pt,indices(ii)}{1})
                                times(ii)  = celltime_to_seconds(T{pt,indices(ii)}) - val_end;
                            end
                        end
                        times = sort(times,'ascend');
                        if times(find(times > 0)) < rt2 
                            flag(3) = 1;
                        end
                        
                        notes = T{pt,Vals(i,5)};
                        if ~isempty(notes)
                            disp(strcat('There are Val',num2str(i),' notes for i=',num2str(pt)))
                        end
                        if flag>0
                            disp(strcat('Val',num2str(i),' rest time does not meet desired for i=',num2str(pt)))
                        end
                        
                        save(strcat('/Volumes/GoogleDrive/Shared drives/REU shared/Workspaces/Vals/',pt_id,'_val',num2str(i),'_WS.mat'),... %Name of file
                         'Age','ECG','Hdata','Pdata','Pth','Rdata','Sex','SPdata','Tdata','flag',...
                         'val_rest_start','val_start','val_end','val_rest_end','notes','cell_row_for_pt','val_dat')
                    end
                end
                
            end
        end
    end
end

%% Subfunctions (SOPHIE CAN IGNORE)
function [time_in_seconds] = celltime_to_seconds(cell_with_string_time)
    t = cell_with_string_time{1};
    
    if sum(t == '.') == 0 %Make sure there is a .0 at the end
        t = strcat(t,'.0');
    end
    
    len = length(t);
    
    if len >= 3
        if t(end-2) == '.' %Gaurd against the auto formating of .00 instead of .0
            t = t(1:end-1);
        end
    end
    
    if sum(t == '.') ~=0 && sum(t == ':') ~=0
        c_ind = find(t==':');
        p_ind = find(t=='.');
        if p_ind - c_ind == 2 %Gaurd against 34:6.0 instead of 34:06.0
            t = strcat(t(1:c_ind),'0',t(p_ind-1:end));
        end 
    end
    
    
        
            
    
    
    if len >= 9 %Hours max
        hour = str2double(t(1:end-8));
        min = str2double(t(end-6:end-5));
        second = str2double(t(end-3:end));
    elseif len >= 6 %Minutes max
        hour = 0;
        min = str2double(t(1:end-5));
        second = str2double(t(end-3:end));
    elseif len >= 3 %Seconds max
        hour = 0;
        min = 0;
        second = str2double(t(1:end));
    end
    
    time_in_seconds = hour*60*60 + min*60 + second;
    

end

clear
addpath('../Make_WS')
T = readtable('../PatientInfo07212021.csv','Headerlines',2);

%% New Variables
num_rows_in_T = 872;
counts = zeros(12,num_rows_in_T);% HUT rest, AS rest, DB rest, Val1 restb, Val1 reste, Val2 restb, Val2 reste, Val3 restb, Val3 reste, Val4 restb, Val4 reste, patient age
betweenTimes = zeros(7,num_rows_in_T); %before HUT, AS, DB, Val1-4
patientTotals = zeros(8,1); %patient total, hut, as, db, val1-4
lengths = zeros(7,num_rows_in_T);

uniqueTimes = zeros(7,num_rows_in_T); %betweenTimes omitting non-unique patients
uniqueCounts = zeros(12,num_rows_in_T); %,counts omitting non-unique patients
uniqueTotals = zeros(8,1); %unique totals
uniqueLengths = zeros(7,num_rows_in_T); 

missingManeuvers = zeros(7,num_rows_in_T); %which patients who have data are missing each maneuver
switches = zeros(8,1);  %tracks individual visit's maneuvers
oldswitches = zeros(8,1); %tracks each unique patient's # of maneuvers
timesBefore = zeros(1,num_rows_in_T);
n = 0;
oldpat = "HPV1";

%NG
ng = cell(1,872);




%% Column numbers
% Load in table and manipulate it to be useful
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
% Val1rests = 28;
% Val1starts = 29;
% Val1ends = 30;
% Val1restends = 31;
% Val1notes = 32;
% Val2rests = 33;
% Val2starts = 34;
% Val2ends = 35;
% Val2restends = 36;
% Val2notes = 37;
% Val3rests = 38;
% Val3starts = 39;
% Val3ends = 40;
% Val3restends = 41;
% Val3notes = 42;
% Val4rests = 43;
% Val4starts = 44;
% Val4ends = 45;
% Val4restends = 46;
% Val4notes = 47;
% % cuff = zeros(11,4); Sheet is currently messed up - need pulse in each
% cuff spot - fix later and be careful
% % for i = 1:12
% %     cuff(i,:) = 43+4*i:46+4*i;
% % end

%% Doin' the job
 

for pt = 3:num_rows_in_T%500:500 %Done through 500
%     load('HPV3_20151209.mat')
    pt
    pt_id = T{pt,1}{1};
    timesNeeded = zeros(14,1); %start and end times for each maneuver

    switches = zeros(8,1); %1 for patient has maneuver, 0 for no
    
    %% ---- HUT ----


    if ~isempty(T{pt,HUTrests}{1})&& ~isempty(T{pt,HUTends}{1}) && ~isempty(T{pt,HUTstarts}{1})
        counts(1,pt-2) = celltime_to_seconds(T{pt,HUTstarts})-celltime_to_seconds(T{pt,HUTrests}); %HUT rest time
        patientTotals(2) = patientTotals(2)+1;
        switches(2) = 1;
        timesNeeded(1) = celltime_to_seconds(T{pt,HUTstarts});
        timesNeeded(2) = celltime_to_seconds(T{pt,HUTends});
        lengths(1,pt-2) = celltime_to_seconds(T{pt,HUTends}) - celltime_to_seconds(T{pt,HUTstarts});
    end

%% ---- AS ----


    if ~isempty(T{pt,ASrests}{1}) && ~isempty(T{pt,ASstarts}{1}) && ~isempty(T{pt,ASends}{1})
        counts(2,pt-2) = celltime_to_seconds(T{pt,ASstarts})-celltime_to_seconds(T{pt,ASrests}); %AS rest time
        patientTotals(3) = patientTotals(3)+1;
        switches(3) = 1;
        timesNeeded(3) = celltime_to_seconds(T{pt,ASstarts});
        timesNeeded(4) = celltime_to_seconds(T{pt,ASends});
        lengths(2,pt-2) = celltime_to_seconds(T{pt,ASends}) - celltime_to_seconds(T{pt,ASstarts});
    end


%% ---- Deep breathing (DB) ----


    if ~isempty(T{pt,DBrests}{1}) && ~isempty(T{pt,DBstarts}{1}) && ~isempty(T{pt,DBends}{1})
        counts(3,pt-2) = celltime_to_seconds(T{pt,DBstarts})-celltime_to_seconds(T{pt,DBrests}); %DB rest time
        patientTotals(4) = patientTotals(4)+1;
        switches(4) = 1;
        timesNeeded(5) = celltime_to_seconds(T{pt,DBstarts});
        timesNeeded(6) = celltime_to_seconds(T{pt,DBends});
        lengths(3,pt-2) = celltime_to_seconds(T{pt,DBends}) - celltime_to_seconds(T{pt,DBstarts});
    end

%% ---- Valsalva ----

    % How many Valsavas?
    val_check = zeros(1,4);
    
    
    for i = 1:4
        val_check(i) = ~isempty(T{pt,Vals(i,1)}{1}) && ~isempty(T{pt,Vals(i,4)}{1}) && ~isempty(T{pt,Vals(i,2)}{1}) && ~isempty(T{pt,Vals(i,3)}{1});
       if val_check(i)
                
            %valthi1=T{pt,Vals(i,1)} %b rest
            %valthi2=T{pt,Vals(i,2)} %starts
            %valthi3=T{pt,Vals(i,3)} %end
            %valthi4=T{pt,Vals(i,4)} %end rest
            counts(2+2*i,pt-2) = celltime_to_seconds(T{pt,Vals(i,2)})-celltime_to_seconds(T{pt,Vals(i,1)}); %val beginning rest
            counts(3+2*i,pt-2) = celltime_to_seconds(T{pt,Vals(i,4)})-celltime_to_seconds(T{pt,Vals(i,3)}); %val end rest
            patientTotals(4+i) = patientTotals(4+i)+1;
            switches(4+i) = 1;
            timesNeeded(5+2*i) = celltime_to_seconds(T{pt,Vals(i,2)});
            timesNeeded(6+2*i) = celltime_to_seconds(T{pt,Vals(i,3)});
            lengths(3+i,pt-2) = celltime_to_seconds(T{pt,Vals(i,3)}) - celltime_to_seconds(T{pt,Vals(i,2)});
            
       end
    end
    num_of_vals = sum(val_check);
    
    %% Nitroglycerin
    if ~isempty(T{pt,HUTNG}{1})
        ng(1,pt-2) = T{pt,HUTNG};
    end
    
    
    %% Times between maneuvers
    %order times of maneuvers
    [timesOrdered, order] = sort(timesNeeded);
    %find where maneuvers occur in ordered list
    HUTloc = find(order == 1);
    ASloc = find(order == 3);
    DBloc = find(order == 5);
    v1loc = find(order == 7);
    v2loc = find(order == 9);
    v3loc = find(order == 11);
    v4loc = find(order == 13);
    locs = [HUTloc, ASloc, DBloc,v1loc, v2loc, v3loc, v4loc];
    
    %calculate time between start of each maneuver and end of the last
    %(or the beginning of time)
  
    
    for i = 1:7
        if locs(i) == 1
            betweenTimes(i,pt-2) = timesOrdered(locs(i));
        else
            betweenTimes(i,pt-2) = timesOrdered(locs(i)) - timesOrdered(locs(i)-1);
        end
        
    end
    
    
    
      
    
%% ---- Count unique patients ----
    %compares patient names to determine if data comes from the same
    %patient as previous row
    newpat = 'HPV';
    ind = 4; %index
    ptname = T{pt,1}{1}; %patient number
    if ~strcmp(ptname(1),'H') %if the patient doesn't start with 'HPV', add it on
        ptname = strcat('HPV',ptname);
    end 
    addletters = ptname(ind); %letter to concatenate
       
    while ~isnan(str2double(addletters)) %go through each index of patname until you reach a non-number
        newpat = strcat(newpat, addletters);
        ind = ind+1;
        if ind <= strlength(ptname)
            addletters = ptname(ind);
        else
            addletters = '.'; %if the index is greater than the length of patname, break out of loop
        end    
    end
    
    
    
    if any(counts(:,pt-2),'all') %Tests if patient has data
        patientTotals(1)=patientTotals(1)+1;
        timesBefore(1,pt-2) = timesOrdered(find(timesOrdered(:,1) > 0,1),1);
        counts(12,pt-2) = T{pt,ages};
        if ~strcmp(newpat,oldpat) %tests if patient is unique
            %record patient data as unique
            uniqueCounts(:,pt-2) = counts(:,pt-2);
            uniqueTimes(:,pt-2) = betweenTimes(:,pt-2);
            uniqueTotals = uniqueTotals + switches;
            uniqueTotals(1) = uniqueTotals(1)+1;
            uniqueLengths(:,pt-2) = lengths(:,pt-2);
            for i = 2:8 %since we have a new patient, we update last patient's missing maneuvers
                if oldswitches(i) == 0
                    missingManeuvers(i-1,pt-3) = 1;
                end
            end
            %if the last patient was missing every maneuver, we omit them
            if missingManeuvers(:,pt-3) == ones(7,1)
                missingManeuvers(:,pt-3) = zeros(7,1);
            end
            %update oldswitches to new patient
            oldswitches = switches;
            n = 0;  
        else
            n = n +1;
            for i = 2:8 %If a patient isn't unique, they still might have data their previous visits didn't
                if oldswitches(i) == 0 && switches(i) == 1 %if they didn't have maneuver on previous visits but do now, record these data as unique
                    
                    if i-1 > 4
                        uniqueCounts(2*(i-1) - 4,pt-2 - n) = counts(2*(i-1) - 4,pt-2);
                        uniqueCounts(2*(i-1) - 3,pt-2 - n) = counts(2*(i-1) - 3,pt-2);
                    else
                         uniqueCounts(i,pt-2 - n) = counts(i,pt-2);
                    end
                   
                    
                    uniqueTimes(i-1 ,pt-2 - n) = betweenTimes(i-1,pt-2);
                    uniqueTotals(i) = uniqueTotals(i) +switches(i);
                    uniqueLengths(i-1,pt-2 - n) = lengths(i-1,pt-2);
                end
            end
            %update oldswitches
            oldswitches = oldswitches + switches;
        end
        
    end
    
    oldpat = newpat;
    
    
end 
save('../../Results/Summary/summary.mat','counts','uniqueCounts', 'betweenTimes','uniqueTimes','patientTotals','uniqueTotals','uniqueLengths','lengths');

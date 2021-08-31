
% Feed in patient data and desired amount of rest, and it chops off unneeded time
% Returns data without unneeded time
function [newdata] = TimeCut(data, restTime)

    %% Calculate times

    % Calculate available time at start and end of maneuver
    timeAvailableS = data.val_start - data.Tdata(1);
    timeAvailableE = data.Tdata(end) - data.val_end;
    
    %Rest time before and after
    restTimeS = restTime(1);
    restTimeE = restTime(2);
    
    
    %Test if the rest time asked for exceeds available time
    if timeAvailableS < restTimeS
        restTimeS = timeAvailableS;
    end
    if timeAvailableE < restTimeE
        restTimeE = timeAvailableE;
    end
    
    
    %how much time are we cutting out?
    timeCutS = timeAvailableS - restTimeS;
    timeCutE = timeAvailableE - restTimeE;
  
    
    %Cut all the data out
    startTime  = find(data.Tdata >= data.Tdata(1) + timeCutS);
    endTime    = find(data.Tdata >= data.Tdata(end) - timeCutE);
    startTimeV = find(data.val_dat(:,1) >= data.val_dat(1,1) + timeCutS);
    endTimeV   = find(data.val_dat(:,1) >= data.val_dat(end,1) - timeCutE);
    
    %% Make new data
    
    %Remake time series data
    newdata.Tdata   = data.Tdata(startTime:endTime);
    newdata.Hdata   = data.Hdata(startTime:endTime);
    newdata.Pthdata = data.Pthdata(startTime:endTime);
    newdata.Rdata   = data.Rdata(startTime:endTime);
    newdata.Pdata   = data.Pdata(startTime:endTime);
    newdata.val_dat = data.val_dat(startTimeV:endTimeV,:);
    
    

    %Remake valsalva phase indices
    index1        = min(find(data.Tdata >= newdata.Tdata(1)));
    i_ts          = data.i_ts + 1 - index1; 
    newdata.i_ts  = i_ts;
    newdata.i_t1  = data.i_t1 + 1 - index1; 
    newdata.i_t2  = data.i_t2 + 1 - index1; 
    newdata.i_te  = data.i_te + 1 - index1 ; 
    newdata.i_t3  = data.i_t3 + 1 - index1; 
    newdata.i_t4  = data.i_t4 + 1 - index1 ;
    
    %Make time start at 0
    newdata.val_start    = data.val_start - newdata.Tdata(1);
    newdata.val_end      = data.val_end - newdata.Tdata(1);
    newdata.Tdata        = newdata.Tdata - newdata.Tdata(1);
    newdata.val_dat(:,1) = newdata.val_dat(:,1) - newdata.val_dat(1,1);
    
    %Remake mins,maxes, averages
    newdata.HminR  = min(newdata.Hdata(1:i_ts - 1)); 
    newdata.HmaxR  = max(newdata.Hdata(1:i_ts - 1)); 
    newdata.Hbar   = trapz(newdata.Hdata(1:i_ts - 1))/(i_ts - 1); 
    newdata.Rbar   = trapz(newdata.Rdata(1:i_ts - 1))/(i_ts - 1); 
    newdata.Pbar   = trapz(newdata.Pdata(1:i_ts - 1))/(i_ts - 1); 
    newdata.Pthbar = trapz(newdata.Pthdata(1:i_ts-1))/(i_ts-1); 
     
    
    %Allocate age and dt
    newdata.age = data.age;
    newdata.dt  = data.dt;
    
    
end
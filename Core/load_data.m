
%Feed a patient workspace, and it returns data necessary for optimization
function [data] = load_data(data,pt_id)
    pt_id
    load(strcat('G:\Shared drives\REU shared\Workspaces\Vals\',pt_id,'_val1_WS.mat')); %Tess

    %% Time Indices
    % Calculate mean distance between timepoints
    dt = mean(diff(Tdata));
    
    
    % Rescale times to start at 0
    val_start = val_start - Tdata(1); 
    val_end   = val_end - Tdata(1); 
    Tdata     = Tdata - Tdata(1);
    val_dat(:,1) = val_dat(:,1) - val_dat(1,1);

    % Determine start and end times of the data set 
    t_start = Tdata(1); 
    if Tdata(end) > 60 
        t_end = val_end + 30;
    else 
        t_end = Tdata(end); 
    end 

    % Find the indices of the time data points that are closest to the VM start
    % and end times 
    [~,i_ts] = min(abs(Tdata - val_start)); 
    [~,i_te] = min(abs(Tdata - val_end)); 

    %% Find steady-state baseline values up to VM start

    HminR = min(Hdata(1:i_ts - 1)); 
    HmaxR = max(Hdata(1:i_ts - 1)); 
    Hbar = trapz(Hdata(1:i_ts - 1))/(i_ts - 1); 
    Rbar = trapz(Rdata(1:i_ts - 1))/(i_ts - 1); 
    Pbar = trapz(SPdata(1:i_ts - 1))/(i_ts - 1); 

    %% Find time for end of phase I 
    % Select the point at which the SBP recuperates to baseline within 10 s of
    % the end of the breath hold 
    [~,i_t1] = min(abs(SPdata(i_ts:i_ts+round(5/dt)) - Pbar)); 
    i_t1 = i_ts + i_t1; 

    %% Find time for middle of phase II 
    % Select the point that which the SBP reaches a minimum during phase II 
    [~,i_t2] = min(SPdata(i_t1:i_te-round(1/dt))); % subtract 1 second to avoid drop off from breath hold
    i_t2 = i_t2 + i_t1; 

    %% Find time for end of phase III 
    % Select the point at which the SBP recuperates to baseline within 5 s of
    % the end of the breath hold 
    [~,i_t3] = min(abs(SPdata(i_te:i_te+round(5/dt)) - Pbar)); 
    i_t3 = i_te + i_t3; 

    %% Find time for end of phase IV 
    % Select the point at which the SBP returns to baseline after the overshoot
    ind = find(SPdata(i_t3:end) <= Pbar, 1, 'first'); 
    if isempty(ind) == 1
        i_t4 = length(SPdata); 
    else 
        i_t4 = i_t3 + ind; 
    end 

    %Check in case t4 = tr
    if i_t4 == i_t3 
        ind2 = find(SPdata(tr+round(5/dt):end) >= Pbar,1,'last');
        t4 = tr + round(5/dt) + ind2 - 1; 
    end  

    %% Make thoracic pressure signal 

    Rdata = Rdata*1000; 
    Rnew = -Rdata; 

    a = findpeaks(Rnew(1:i_ts-1)); 
    b = findpeaks(-Rnew(1:i_ts-1)); 
    b = -b; 
    R_exh = mean(a); 
    R_inh = mean(b);
    R_amp = R_exh - R_inh; 

    Amp_norm = 6 - 3.5; 
    Amp      = Amp_norm/R_amp; 
    RR       = Amp*Rnew; 

    a      = findpeaks(-RR(1:i_ts-1));
    R_exh  = -mean(a); 
    m      = 3.5 - R_exh;
    P_resp = RR+m ; 

    %Thoracic pressure 
    Pth = zeros(size(Tdata)); 
    for i = 1:length(Tdata)
        t = Tdata(i); 
            if (t > val_start) && (t < val_end)
                p = 40*(1 - exp(-2*(t - val_start)));
            else 
                p = P_resp(i); 
            end 
         Pth(i) = p; 
    end 

    % Smooth out Pth 
    Pth = movmean(Pth,10);

    % Find average baseline Pth 
    Pthbar = trapz(Pth(1:i_ts-1))/(i_ts-1); 
    
    
    %% Create data structure 

    %Remember to delete sampling when the workspaces are prepared!!!!!!
    data.Tdata     = Tdata;
    data.Pdata     = SPdata;
    data.Hdata     = Hdata;
    data.Pthdata   = Pth;
    data.Rdata     = Rdata; 
    data.Pbar      = Pbar;
    data.Pthbar    = Pthbar;
    data.HminR     = HminR;
    data.HmaxR     = HmaxR;
    data.Hbar      = Hbar; 
    data.Rbar      = Rbar; 
    data.val_start = val_start; 
    data.val_end   = val_end; 
    data.i_ts      = i_ts; 
    data.i_t1      = i_t1; 
    data.i_t2      = i_t2; 
    data.i_te      = i_te;
    data.i_t3      = i_t3; 
    data.i_t4      = i_t4;  
    data.age       = Age; 
    data.dt        = dt; 
    data.val_dat   = val_dat;
end


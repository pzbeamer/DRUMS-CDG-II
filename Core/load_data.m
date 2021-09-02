%Feed a patient workspace, and it returns data necessary for generating
%nominal parameters
function [data pars] = load_pars(pt_id)
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

%% PARAMETERS  

A    = 5;          
B    = 0.5;           

Kb   = 0.1;          
Kpb  = 5;
Kpr  = 1; 
Ks   = 5; 

%taub  = 0.9;           
taupb = 1.8;          
taupr = 6;
taus  = 10;          
tauH  = 0.5;

qw   = .04;        
qpb  = 10*(1 - Kb);          
qpr  = 1; 
qs   = 10*(1 - Kb);          

Ds   = 3;            

%% Patient specific parameters

sw  = Pbar;           
spr = Pthbar;  

%Intrinsic HR
HI = 118 - .57*Age;  
if HI < Hbar 
    HI = Hbar;
end 
%Maximal HR
HM = 208 - .7*Age;    
Hs = (1/Ks)*(HM/HI - 1); 

%% Calculate sigmoid shifts

Pc_ss  = Pbar; 
ewc_ss = 1 - sqrt((1 + exp(-qw*(Pc_ss - sw)))/(A + exp(-qw*(Pc_ss - sw)))); 

Pa_ss  = Pbar - Pthbar; 
ewa_ss = 1 - sqrt((1 + exp(-qw*(Pa_ss - sw)))/(A + exp(-qw*(Pa_ss - sw)))); 

n_ss   = B*ewc_ss + (1 - B)*ewa_ss;

Tpb_ss = .8;
Ts_ss  = .2; 

%Steady-state sigmoid shifts 
spb = n_ss + log(Kpb/Tpb_ss - 1)/qpb;  
ss  = n_ss -  log(Ks/Ts_ss - 1)/qs;   

%% At end of expiration and inspiration

Gpr_ss = 1/(1 + exp(qpr*(Pthbar - spr)));

Tpr_ss = Kpr*Gpr_ss; 
Hpr = (HmaxR - HminR)/HI/Tpr_ss ;

Hpb = (1 - Hbar/HI + Hpr*Tpr_ss + Hs*Ts_ss)/Tpb_ss;

%% Outputs

pars = [A; B;              
    Kpb; Kpr; Ks;               %Gains
    taupb; taupr; taus; tauH; %Time Constants
    qw; qpb; qpr; qs;               %Sigmoid Steepnesses
    sw; spb; spr; ss;               %Sigmoid Shifts
    HI; Hpb; Hpr; Hs;               %Heart Rate Parameters 
    Ds];                            %Delay

%% Parameter bounds

%Vary nominal parameters by +/- 50%
lb  = pars*.5; 
ub  = pars*1.5;

%B - Convex combination
lb(2)  = .01;                       
ub(2)  = 1;                                      

%tau_pb - M p/m 2 SD 
lb(6)  = max(6.5 - 2*5.7,0.01);    
ub(6)  = 6.5 + 2*5.7;               

%tau_pr - M p/m 2 SD 
lb(7)  = max(9.6 - 2*10.8,0.01);    
ub(7)  = 9.6 + 2*10.8;                                                   

%s_w - M p/m 2 SD
lb(14) = max(123 - 2*20,0.01);      
ub(14) = 123 + 2*20;               

%s_pb - M p/m 2 SD
lb(15) = max(0.54 - 2*5e-3,0.01);   
ub(15) = 0.54 + 2*5e-3;        

%s_pr - M p/m 2 SD
lb(16) = max(4.88 - 2*0.21,0.01); 
ub(16) = 4.88 + 2*0.21;             

%s_s - M p/m 2 SD
lb(17) = max(0.05 - 2*5e-3,0.01);  
ub(17) = 0.05 + 2*5e-3;          

%H_I - M p/m 2 SD 
lb(18) = max(100 - 2*7,0.01);     
ub(18) = 100 + 2*7;           

%H_pb - M p/m 2 SD 
lb(19) = max(0.5 - 2*0.2,0.01);     
ub(19) = 0.5 + 2*0.2;             

%H_pr -  M p/m 2 SD - calc
lb(20) = max(0.3 - 2*0.4,0.01);   
ub(20) = 0.3 + 2*0.4;              

%H_s - M p/m 2 SD - calc
lb(21) = max(0.3 - 2*0.4,0.01);     
ub(21) = 0.3 + 2*0.4;                         

%% Outputs

pars = log(pars);
lb   = log(lb);
ub   = log(ub); 

%% Create data structure 

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
data.pars      = pars;
end


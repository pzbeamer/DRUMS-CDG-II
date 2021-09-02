%Feed a patient workspace, and it returns data necessary for optimization
function [pars, lb, ub] = load_global(data, INDMAP)

global pars0
age    = data.age;  

%Initial mean values
Pbar   = data.Pbar;
HminR  = data.HminR; 
HmaxR  = data.HmaxR; 
Hbar   = data.Hbar; 

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
spr = data.Pthbar;  

%Intrinsic HR
HI = 118 - .57*age;  
if HI < Hbar 
    HI = Hbar;
end 
%Maximal HR
HM = 208 - .7*age;    
Hs = (1/Ks)*(HM/HI - 1); 

%% Calculate sigmoid shifts

Pc_ss  = data.Pbar; 
ewc_ss = 1 - sqrt((1 + exp(-qw*(Pc_ss - sw)))/(A + exp(-qw*(Pc_ss - sw)))); 

Pa_ss  = data.Pbar - data.Pthbar; 
ewa_ss = 1 - sqrt((1 + exp(-qw*(Pa_ss - sw)))/(A + exp(-qw*(Pa_ss - sw)))); 

n_ss   = B*ewc_ss + (1 - B)*ewa_ss;

Tpb_ss = .8;
Ts_ss  = .2; 

%Steady-state sigmoid shifts 
spb = n_ss + log(Kpb/Tpb_ss - 1)/qpb;  
ss  = n_ss -  log(Ks/Ts_ss - 1)/qs;   

%% At end of expiration and inspiration

Gpr_ss = 1/(1 + exp(qpr*(data.Pthbar - spr)));

Tpr_ss = Kpr*Gpr_ss; 
Hpr = (HmaxR - HminR)/HI/Tpr_ss ;

Hpb = (1 - Hbar/HI + Hpr*Tpr_ss + Hs*Ts_ss)/Tpb_ss;

%% Outputs

pars0 = [A; B;                       %1-2
    Kpb; Kpr; Ks;                   %Gains 3-5
    taupb; taupr; taus; tauH;       %Time Constants 6-9
    qw; qpb; qpr; qs;               %Sigmoid Steepnesses 9-12
    sw; spb; spr; ss;               %Sigmoid Shifts 14-17
    HI; Hpb; Hpr; Hs;               %Heart Rate Parameters 18-21
    Ds];                            %Delay 22


scaled = .2 *rand(size(pars0))-.1;%zeros(size(pars0));
pars = pars0;
pars(INDMAP') = pars0(INDMAP') .* (1+scaled(INDMAP'));
%% Parameter bounds

%Vary nominal parameters by +/- 50%
lb  = pars0*.125; 
ub  = pars0*8;

%B - Convex combination
lb(2)  = .01;                       
ub(2)  = 1;                                      

% %tau_pb - M p/m 2 SD 
% lb(6)  = max(6.5 - 2*5.7,0.01);    
% ub(6)  = 6.5 + 2*5.7;               
% 
% %tau_pr - M p/m 2 SD 
% lb(7)  = .01;    
% ub(7)  = 31.2;     
% 
% %tau_s is 8
% 
% %tau_H
% lb(9) = 0.01;
% ub(9) = 1.5;
% 
% %q_w
% lb(10) = 0.01;
% ub(10) = 0.09;
% 
% %s_w - M p/m 2 SD
% lb(14) = max(123 - 2*20,0.01);      
% ub(14) = 123 + 2*20;               
% 
% % %s_pb - M p/m 2 SD
% % lb(15) = max(0.54 - 2*5e-3,0.01);   
% % ub(15) = 0.54 + 2*5e-3;        
% 
% %s_pr - M p/m 2 SD
% lb(16) = max(4.88 - 2*0.21,0.01); 
% ub(16) = 4.88 + 2*0.21;             
% 
% % %s_s - M p/m 2 SD
% % lb(17) = max(0.05 - 2*5e-3,0.01);  
% % ub(17) = 0.05 + 2*5e-3;          
% 
% %H_I - M p/m 2 SD 
% lb(18) = max(100 - 2*7,0.01);     
% ub(18) = 100 + 2*7;           
% 
% %H_pb - M p/m 2 SD 
% lb(19) = max(0.5 - 2*0.2,0.01);     
% ub(19) = 0.5 + 2*0.2;             
% 
% %H_pr -  M p/m 2 SD - calc
%  lb(20) = max(0.3 - 2*0.4,0.01);   
%  ub(20) = (0.3 +2*0.4);              
% 
% %H_s - M p/m 2 SD - calc
% lb(21) = max(0.3 - 2*0.4,0.01);     
% ub(21) = 1.5;                         

 lb(22) = 2;     
 ub(22) = 6;
%% Outputs

pars = log(pars);
lb   = log(lb);
ub   = log(ub); 

end 


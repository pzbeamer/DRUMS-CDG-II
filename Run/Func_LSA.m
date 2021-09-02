%Runs local sensitivity analysis for one patient. Input: patient id.
%Output: sens file
function [sens] = Func_LSA(pt_id)
addpath('../Core');

%% Load data  

if isfile(strcat('G:\Shared drives\REU shared\Workspaces\Vals\',pt_id,'_val1_WS.mat'))
       load(strcat('G:\Shared drives\REU shared\Workspaces\Vals\',pt_id,'_val1_WS.mat'))
       
echoon  = 0; 
printon = 0; 

%% Run Forward Evaluation
Func_ForwardModel(pt_id, 30);

%% Create Data Structure

data.Tdata     = Tdata;
data.Pdata     = SPdata; 
data.Hdata     = Hdata;
data.Pthdata   = Pth;
data.Rdata     = Rdata; 
data.Pdata     = Pdata;
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

%% Get nominal parameter values

%Global parameters
ODE_TOL  = 1e-8;
DIFF_INC = sqrt(ODE_TOL);

gpars.ODE_TOL  = ODE_TOL;
gpars.DIFF_INC = DIFF_INC; 
gpars.echoon = echoon;

data.gpars = gpars; 

%% Sensitivity Analysis

%senseq finds the non-weighted sensitivities
sens = senseq(pars,data);

sens = abs(sens); 

% ranked classical sensitivities
[M,N] = size(sens);
for i = 1:N 
    sens_norm(i)=norm(sens(:,i),2);
end

%sens_norm = sens_norm(1:end-2); 
[Rsens,Isens] = sort(sens_norm,'descend');
display([Isens]); 

params = {'$A$', '$B$', ...
    '$K_{pb}$','$K_{pr}$','$K_s$', ...
    '$\tau_{pb}$','$\tau_{pr}$','$\tau_s$','$\tau_H$',...
    '$q_w$','$q_{pb}$','$q_{pr}$','$q_{s}$', ...
    '$s_w$','$s_{pb}$','$s_{pr}$','$s_{s}$', ...
    '$H_I$','$H_{pb}$','$H_{pr}$','$H_{s}$', ...
    '$D_s$'}; 
save(strcat('Sens/sens',pt_id,'.mat'));
end

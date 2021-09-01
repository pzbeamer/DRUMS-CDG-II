%DriverBasic_sens creates sens files in loop

clear all
close all

tic 

T = readtable('../PatientInfo07192021.csv','Headerlines',2);

for pt=[37 48 59 60 65 66 67]
    pt
    pt_id = T{pt,1}{1}  
    
   
    %% Load data and preprocess data 
    if isfile(strcat('../MatFiles/',pt_id,'_val1_WS.mat'))
       load(strcat('../Valsalva/nomHR_residuals/',pt_id,'_val1_nomHR.mat'))

    echoon  = 1; 
    printon = 0; 
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

    save(strcat('Sens/sens',pt_id,'_val1.mat')); 
    
     end

    elapsed_time = toc
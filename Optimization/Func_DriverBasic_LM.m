%DriverBasic_LM

function [pars optpars Init xhist error HR_LM] = Func_DriverBasic_LM(data,INDMAP)
%     clear all
    %close all
    addpath('../Core');
    

    %% Get nominal parameter values

    [pars,low,hi] = load_global(data, INDMAP); 

    %Global parameters
    
    ALLPARS  = pars;
    ODE_TOL  = 1e-8; 
    DIFF_INC = sqrt(ODE_TOL);

    gpars.INDMAP   = INDMAP;
    gpars.ALLPARS  = ALLPARS;
    gpars.ODE_TOL  = ODE_TOL;
    gpars.DIFF_INC = DIFF_INC;
 

    data.gpars = gpars;

    %% Optimization - lsqnonlin

    optx   = pars(INDMAP); 
    opthi  = hi(INDMAP);
    optlow = low(INDMAP);

    maxiter = 30; 
    mode    = 2; 
    nu0     = 2.d-1; 
    
    [xopt, histout, costdata, jachist, xhist, rout, sc] = ...
         newlsq_v2(optx,'opt_wrap',1.d-3,maxiter,...
         mode,nu0,opthi,optlow,data); 

    pars_LM = pars;
    pars_LM(INDMAP) = xopt; 

    [HR_LM,rout,J,Outputs,Init] = model_sol(pars_LM,data);

    optpars = exp(pars_LM);
    disp('optimized parameters')
    disp([INDMAP' optpars(INDMAP) exp(hi(INDMAP)) exp(low(INDMAP))])

    time = Outputs(:,1); 
    Tpb_LM  = Outputs(:,2);
    Ts_LM   = Outputs(:,3);
    Tpr_LM  = Outputs(:,4); 
    
    start = min(find(data.Tdata >= data.val_start));
    slut = min(find(data.Tdata >= data.val_end));
    scaler = sqrt(length(data.Hdata(start:slut)));
    error(1) = norm((data.Hdata(start:slut)-HR_LM(start:slut))./data.Hdata(start:slut)/scaler);
    error(2) = (max(data.Hdata(start:slut)) - max(HR_LM(start:slut)))/max(data.Hdata(start:slut));
    

end
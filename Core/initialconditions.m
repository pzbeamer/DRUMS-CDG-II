function Init = initialconditions(pars,data)

%% PARAMETERS 

A  = pars(1);
B  = pars(2);

Kpb = pars(3);
Kpr = pars(4);
Ks  = pars(5); 

qw  = pars(10); 
qpb = pars(11);
qpr = pars(12); 
qs  = pars(13);

sw  = pars(14); 
spb = pars(15);
spr = pars(16); 
ss  = pars(17);

%% INITIAL CONDITIONS

Pc_0  = data.Pdata(1); 
ewc_0 = 1 - sqrt((1 + exp(-qw*(Pc_0 - sw)))/(A + exp(-qw*(Pc_0 - sw)))); 

Pa_0  = data.Pdata(1) - data.Pthdata(1); 
ewa_0 = 1 - sqrt((1 + exp(-qw*(Pa_0 - sw)))/(A + exp(-qw*(Pa_0 - sw)))); 

n_0   = B*ewc_0 + (1 - B)*ewa_0;

Gpb_0 = 1/(1 + exp(-qpb*(n_0 - spb)));
Gpr_0 = 1/(1 + exp(qpr*(data.Pthdata(1) - spr)));
Gs_0  = 1/(1 + exp(qs*(n_0 - ss))); 

Tpb_0 = Kpb*Gpb_0; 
Tpr_0 = Kpr*Gpr_0;
Ts_0  = Ks*Gs_0; 

%% OUTPUT

Init = [Tpb_0; Tpr_0; Ts_0; data.Hdata(1)];

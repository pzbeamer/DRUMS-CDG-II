function [HR,rout,J,Outputs,Init] = model_sol(pars,data)

global pars0 echoon
pars
pars = exp(pars); 

%% Unpack structure 

tspan   = data.Tdata;
Pdata   = data.Pdata; 
Pthdata = data.Pthdata; 
Rdata   = data.Rdata; 
Hdata   = data.Hdata; 
dt      = data.dt; 


%% Get initial conditions 

Init = initialconditions(pars0,data);

%% Write data files up to event

%Write initial conditions vector
fid = fopen('FortranData/Init.txt','w');
fprintf(fid,'%6i \n',length(Init)); 
for i = 1:length(Init)
   fprintf(fid,'%26.18E \n',Init(i));
end
fclose(fid);

%Write parameter vector - MUST HAVE LENGTH OF VECTOR FIRST! 
fid = fopen('FortranData/Pars.txt','w');
fprintf(fid,'%6i \n',length(pars));
for i = 1:length(pars)
   fprintf(fid,'%26.18E \n',pars(i));
end
fclose(fid);

%Write time vector - MUST HAVE LENGTH OF VECTOR FIRST!
fid = fopen('FortranData/Time.txt','w');
fprintf(fid,'%6i \n',length(tspan));
for i = 1:length(tspan)
   fprintf(fid,'%26.18E \n',tspan(i));
end
fclose(fid);

%Write time vector - MUST HAVE LENGTH OF VECTOR FIRST!
fid = fopen('FortranData/dt.txt','w');
fprintf(fid,'%26.18E \n',dt);
fclose(fid);

%Write mean blood pressure (from movmean) vector - MUST HAVE LENGTH OF VECTOR FIRST!
fid = fopen('FortranData/Pmean.txt','w');
fprintf(fid,'%6i \n',length(Pdata));
for i = 1:length(Pdata)
   fprintf(fid,'%26.18E \n',Pdata(i));
end
fclose(fid);

%Write thoracic pressure vector - MUST HAVE LENGTH OF VECTOR FIRST!
fid = fopen('FortranData/Pthdata.txt','w');
fprintf(fid,'%6i \n',length(Pthdata));
for i = 1:length(Pthdata)
   fprintf(fid,'%26.18E \n',Pthdata(i));
end
fclose(fid);

%Write thoracic pressure vector - MUST HAVE LENGTH OF VECTOR FIRST!
fid = fopen('FortranData/Rdata.txt','w');
fprintf(fid,'%6i \n',length(Rdata));
for i = 1:length(Rdata)
   fprintf(fid,'%26.18E \n',Rdata(i));
end
fclose(fid);
 
%% Solve model 

if echoon == 1
    if contains(computer,'PC')
        fileexe_path = which ('driver.exe');
        system_command_string = [fileexe_path, ' '];
        [status,blah] = system(system_command_string,'-echo');
    else
        [status,blah] = unix('./driver','-echo');
    end 
else
    if contains(computer,'PC')
        fileexe_path = which ('driver.exe');
        system_command_string = [fileexe_path, ' '];
        [status,blah] = system(system_command_string);
    else
        [status,blah] = unix('./driver');
    end 
end 
s    = load('cont.out');
time = s(:,1); 
Tpb  = s(:,2); 
Tpr  = s(:,3); 
Ts  = s(:,4); 
HR  = s(:,5); 


if round(time(end-1),2) == round(tspan(end),2) && length(time)>length(tspan)  
    time = time(1:end-1); 
    Tpb = Tpb(1:end-1);
    Tpr = Tpr(1:end-1); 
    Ts = Ts(1:end-1);
    HR = HR(1:end-1); 
end 
%% Interdpolate solution and calculate outputs
[~,startm] = max(find(time <= data.val_start)); %add valstart and valend to the parameters
[~,slutm] = max(find(time <= data.val_end));
[~,startd] = max(find(tspan <= data.val_start)); 
[~,slutd] = max(find(tspan <= data.val_end));

HRmodelM   = max(HR(startm:slutm));
HRdataM    = max(Hdata(startd:slutd));
HRdatamean = mean(Hdata(startd:slutd));
HRmovmean = movmean(Hdata,40);

rout     = [(HR' - Hdata')/HRdatamean/sqrt(length(Hdata)) ... 
            (HRmodelM - HRdataM)/HRdataM]';

J = rout'*rout;

Outputs = [time,Tpb,Ts,Tpr]; 

%add in plot made with initial heart rate to check that they are the same
%as th



%DriverBasic_forwardModel generates sensitivity files
addpath('../Run');
T = readtable('../Data Processing/PatientInfo07212021.csv','Headerlines',2);

for pt=[37]
    pt
    pt_id = T{pt,1}{1}  
    Func_ForwardModel(pt_id);
        figure(1) 
        hold on
        plot(Tdata,Hdata,'LineWidth',2.5)
        plot(Tdata,HR,'LineWidth',2.5)
end
%DriverBasic_Sens generates sensitivity files
addpath('../Run');
T = readtable('../Data Processing/PatientInfo07212021.csv','Headerlines',2);

for pt=[37 48 59 60 65 66 67]
    pt
    pt_id = T{pt,1}{1}  
    Func_LSA(pt_id);
end
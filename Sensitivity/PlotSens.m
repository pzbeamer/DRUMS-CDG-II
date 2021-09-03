%% Read Table and pick sample group of patients
T = readtable('../Data Processing/PatientInfo07212021.csv','Headerlines',2);

sample = ["HPV20_20120919", "HPV22_20130903", "HPV27_20140124", ... 
    "HPV28_20140124", "HPV32_20140217", "HPV33_20140217", "HPV34_20140217"]

%% Generate Plots
Func_plotRankedLS(sample); % Generate plot of parameter sensitivities for VM1 and VM2
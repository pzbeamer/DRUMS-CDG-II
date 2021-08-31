clear all
close all
load('../../Results/Summary/summary.mat');


for i = 1:12
    if i <= 7
        betweenTimes(i,:) = sort(betweenTimes(i,:),'descend');
        averageBetween(i) = mean(betweenTimes(i,1:find(betweenTimes(i,:)==0)));
        uniqueTimes(i,:) = sort(uniqueTimes(i,:),'descend');
        lengths(i,:) = sort(lengths(i,:),'descend');
        averageLength(i) = mean(lengths(i,1:find(lengths(i,:)==0)));
        uniqueLengths(i,:) = sort(uniqueLengths(i,:),'descend');
    end
    uniqueCounts(i,:) = sort(uniqueCounts(i,:),'descend');
    counts(i,:) = sort(counts(i,:),'descend');
    
end


%% Times Between
uniqueHT = uniqueTimes(1,1:find(uniqueTimes(1,:)==0)-1);
uniqueAS = uniqueTimes(2,1:find(uniqueTimes(2,:)==0)-1);
uniqueDB = uniqueTimes(3,1:find(uniqueTimes(3,:)==0)-1);
uniqueV1 = uniqueTimes(4,1:find(uniqueTimes(4,:)==0)-1);
uniqueV2 = uniqueTimes(5,1:find(uniqueTimes(5,:)==0)-1);
uniqueV3 = uniqueTimes(6,1:find(uniqueTimes(6,:)==0)-1);
uniqueV4 = uniqueTimes(7,1:find(uniqueTimes(7,:)==0)-1);


unique = [uniqueHT,uniqueAS, uniqueDB, uniqueV1, uniqueV2, uniqueV3, uniqueV4];
groups = [ones(size(uniqueHT)),2*ones(size(uniqueAS)),3*ones(size(uniqueDB)),4*ones(size(uniqueV1)),5*ones(size(uniqueV2)),6*ones(size(uniqueV3)),7*ones(size(uniqueV4))];

hold on

% boxplot(unique,groups,'Notch', 'on','Widths',0.8)
% xlabel('Patient Groups')
% ylabel('Time (seconds)')
% title('Time Before Test')

%% Rest Recorded
restHT = uniqueCounts(1,1:find(uniqueCounts(1,:)==0)-1);
restAS = uniqueCounts(2,1:find(uniqueCounts(2,:)==0)-1);
restDB = uniqueCounts(3,1:find(uniqueCounts(3,:)==0)-1);
restbV1 = uniqueCounts(4,1:find(uniqueCounts(4,:)==0)-1);
restbV2 = uniqueCounts(6,1:find(uniqueCounts(5,:)==0)-1);
restbV3 = uniqueCounts(8,1:find(uniqueCounts(6,:)==0)-1);
restbV4 = uniqueCounts(10,1:find(uniqueCounts(7,:)==0)-1);
resteV1 = uniqueCounts(5,1:find(uniqueCounts(8,:)==0)-1);
resteV2 = uniqueCounts(7,1:find(uniqueCounts(9,:)==0)-1);
resteV3 = uniqueCounts(9,1:find(uniqueCounts(10,:)==0)-1);
resteV4 = uniqueCounts(11,1:find(uniqueCounts(11,:)==0)-1);
age = uniqueCounts(12,1:find(uniqueCounts(12,:)==0)-1);

restb4 = [restHT, restAS, restDB];
restvals = [restbV1, resteV1, restbV2, resteV2, restbV3, resteV3, restbV4, resteV4];

groups2 = [ones(size(restHT)),2*ones(size(restAS)),3*ones(size(restDB))];
groupsvals = [ones(size(restbV1)),2*ones(size(restbV2)),3*ones(size(restbV3)),4*ones(size(restbV4)),5*ones(size(resteV1)),6*ones(size(resteV2)),7*ones(size(resteV3)),8*ones(size(resteV4))];

% Rest before HT, AS, and DB
% boxplot(restb4,groups2,'Notch', 'on','Widths',0.8)
% xlabel('Patient Groups')
% ylabel('Time (seconds)')
% title('Rest Before Each Test')

% Rest before and after Valsalvas
figure(1)
boxplot(restvals,groupsvals,'Notch', 'on','Widths',0.8,'DataLim',[0,400],'ExtremeMode','clip');
xlabel('Patient Groups')
ylabel('Time (seconds)')
title('Rest Before and After Valsalvas')
saveas(figure(1),'../../Results/Summary/Figures/boxplotValsalvas.jpg');



%boxplot(uniqueV2,'Notch', 'on','Labels', {labels(5)})
%% Patient Age

fig = figure(2);
histogram(age)
xlabel('Ages')
ylabel('Density')
title('Patient Ages')
saveas(fig,'../../Results/Summary/Figures/patientages.jpg');


%% Average Lengths

lengthHT = uniqueLengths(1,1:find(uniqueLengths(1,:)==0)-1);
lengthAS = uniqueLengths(2,1:find(uniqueLengths(2,:)==0)-1);
lengthDB = uniqueLengths(3,1:find(uniqueLengths(3,:)==0)-1);
lengthV1 = uniqueLengths(4,1:find(uniqueLengths(4,:)==0)-1);
lengthV2 = uniqueLengths(5,1:find(uniqueLengths(5,:)==0)-1);
lengthV3 = uniqueLengths(6,1:find(uniqueLengths(6,:)==0)-1);
lengthV4 = uniqueLengths(7,1:find(uniqueLengths(7,:)==0)-1);
fig = figure(3);

boxplot(lengthAS,'Notch', 'on','Widths',0.8,'DataLim',[0,300],'ExtremeMode','clip')
xlabel('Active Stand')
ylabel('Length')
title('Active Stand Lengths')
saveas(fig,'../../Results/Summary/Figures/ASlength.jpg');



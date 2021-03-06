
clear all
close all
%We need patient info, markers,and which patients have pots
T=readtable('../Data Processing/PatientInfo07212021.csv');
load('../Results/POTS_Patients/potspats.mat')
load('../Results/Markers/markers.mat')
counter = 1;

%Go through each row of PatientInfo
for pt = 3:872
    
    %patient id
    pt_id = T{pt,1}{1}
    T2{pt,1} = pt_id;
    
        
    % If they have an optimized file
    if isfile(strcat('../Results/Optimizations/',pt_id,'_optimized.mat'))
        
        load(strcat('../Results/Optimizations/',pt_id,'_optimized.mat'))
        
        %Grab patients for plotting
        if pt == 9
            x = saveDat.optpars(1,:);
        elseif pt == 23
            y = saveDat.optpars(1,:);
        end
        
        try 
            %Discard flagged optimizations
            if ~any(saveDat.flag)


                % Check if they have tachycardia marked in spreadsheet and
                % record
                if ~isnan(T{pt,90}) && ~isnan(T{pt,91})

                    POTS(counter) = max(T{pt,90},T{pt,91});

                elseif ~isnan(T{pt,90})

                    POTS(counter) = T{pt,90};

                elseif ~isnan(T{pt,91})

                    POTS(counter) = T{pt,91};

                else

                    POTS(counter) = 0;

                end

                %Record optimized data for clustering
                %We can take the first random start since they converge (no
                %flags)
                
                opt_pars(counter,1:5) = saveDat.optpars(1,1:5);
                nom_pars(counter,1:5) = saveDat.parsfull(1,[16 17 18 19 21]);
                tones(counter,1)      = max(saveDat.symp(1,:));
                tones(counter,2)      = max(saveDat.para(1,:));
                markers(counter,1:16) = markerdat.markers(pt,:);

                
                %Increment
                counter = counter +1;


            else
                
            end
        catch
            
        end
    end
end
%% Cluster (self explanatory)

%Cluster optimal parameters, nominal parameters, and max tones (excluding
%bad data)
good = [];
for i = 1:length(nom_pars(:,1))
    
    if min(nom_pars(i,:)) > 0 && min(markers(i,:)) > 0
        
        good = [good; i];
        
    end
    
end
 p = [opt_pars(good,:),...
     nom_pars(good,:),...
     tones(good,:),...
     markers(good,:)];


%p = opt_pars;
clustering = kmeans(log(p),2);


POTS = POTS(good);
save('../Results/Analysis/4plots.mat','opt_pars','POTS','clustering','nom_pars','tones','p','markers')



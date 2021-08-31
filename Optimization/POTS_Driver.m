
% Feed it rows in the table of patient info, and it optimizes these
% patients
function POTS_Driver(index)
    addpath('../Core')
    format shortg;

    %Table with patient records, patient ids are the first column
    T = readtable('../Data\ Processing/PatientInfo07212021.csv','Headerlines',2);
    
    %Parameters to estimate (taupb, taus, spb, spr, Hpr)
    INDMAP = [6 8 14 15 20];

    %Loop over patients 
    for pt = index
        %patiend id is the first column in table
        pt_id = T{pt,1}{1};
        % Wrap each patient in try catch so that we can run tons of datasets
        % on cluster without worrying about errors crashing program
        try
            %How much rest time are we cutting out?
            restCut = 0;
            %Preallocate save data structure
            %optimized parameters
            saveDat.optpars = zeros(8,5);
            %nominal parameters
            saveDat.pars = zeros(8,5);
            %parameters optimized
            saveDat.INDMAP = INDMAP;
            %History of parameters
            saveDat.xhist = cell(8,30);
            %Rest time used
            saveDat.restTime = 30;
            %Initial conditions
            saveDat.Init = zeros(8,4);
            %Residual error
            saveDat.error = zeros(8,1);
            %Flag if error is bad
            saveDat.flag = zeros(2,1);

            % if there's a file, execute optimization
            if isfile(strcat('MatFiles/',pt_id,'_val1_WS.mat'))

               %preallocate error matrix
               error = zeros(4,2);
               %Construct file to read
               pt_WS = strcat(pt_id,'_val1_WS.mat')
               %Load needed patient data
               data = load_data(pt_WS);

               %Find the optimal amount of rest time before Valsalva
               for i = 0:3 %reducing rest before in intervals of 5 seconds

                    %% run optimization
                    %cut the data to 30-5*i seconds rest before
                    newdata = TimeCut(data,[30-5i,30]);
                    %Call optimization
                    [pars optpars Init xhist error2 HR_LM] = Func_DriverBasic_LM(newdata,INDMAP);
                    %residual error
                    error(i+1,:) = error2;

                    %% Save necessary stats

                    %Find start and end times of val
                    start = min(find(newdata.Tdata >= newdata.val_start));
                    slut = min(find(newdata.Tdata >= newdata.val_end));
                    %scale for error
                    scaler = sqrt(length(newdata.Hdata(start:slut)));
                    %if the rest time was good enough, save stuff and break
                    %out of loop

                    
                    if error(i+1,1) < .8/scaler || error(i+1,2) < 5/max(newdata.Hdata(start:slut))
                        figure(pt)
                        hold on
                        plot(newdata.Tdata,newdata.Hdata)
                        plot(newdata.Tdata,HR_LM)
                        %Save the amount of rest to cut for future random
                        %starts
                        restCut = i;
                        %set data to be the cut data
                        data = newdata;
                        %save relevant values from optimization
                        saveDat.restTime = 30 - restCut * 5;
                        saveDat.error(1) = error(i+1,1);
                        saveDat.pars(1,:) = exp(pars(INDMAP'));
                        saveDat.Init(1,:) = Init;
                        saveDat.optpars(1,:) = optpars(INDMAP);
                        saveDat.xhist(1,1:length(xhist)) = xhist;
                        %break out of rest time comparison loop
                        break

                    elseif i == 3

                        %Rest cut is the amount of time which obtained best residual error if none are satisfactory
                        figure(pt)
                        hold on
                        plot(newdata.Tdata,newdata.Hdata)
                        plot(newdata.Tdata,HR_LM)
                        restCut = find(error(:,1) == min(error(:,1)))-1;
                        %Cut data to the appropriate length for future random
                        %starts
                        data = TimeCut(data,[30 - 5 * restCut, 30]);
                        [pars optpars Init xhist error2 HR_LM] = Func_DriverBasic_LM(data,INDMAP);

                        %flag dataset as poor with residual error
                        saveDat.flag(1,1) = 1;
                        %save relevant values from optimization
                        saveDat.restTime = 30 - restCut * 5;
                        saveDat.error(1) = error(restCut+1,1);
                        saveDat.pars(1,:) = exp(pars(INDMAP'));
                        saveDat.Init(1,:) = Init;
                        saveDat.optpars(1,:) = optpars(INDMAP);
                        saveDat.xhist(1,1:length(xhist)) = xhist;

                    end

               end
               %data = TimeCut(data,[saveDat.restTime,30]);
               %Run 7 additional optimizations with random nominal parameter values
                for k = 2:8
                    %% Optimization
                    %data = TimeCut(data,[30,30]);
                    [pars optpars Init xhist error2 HR_LM]  = Func_DriverBasic_LM(data,INDMAP);

                    %% save necessary stats
                    figure(pt)
                    hold on
                    plot(data.Tdata,data.Hdata)
                    plot(data.Tdata,HR_LM)
                    saveDat.error(k) = error2(1);
                    saveDat.pars(k,:) = exp(pars(INDMAP'));
                    saveDat.Init(k,:) = Init;
                    saveDat.optpars(k,:) = optpars(INDMAP);
                    saveDat.xhist(k,1:length(xhist)) = xhist;

                end

                %% Flag divergent patients
                for i = 1:length(saveDat.optpars(1,:))-1
                    
                    % If the average of optimized parameters deviate
                    % significantly from median, we flag patient as
                    % divergent
                    if abs((mean(saveDat.optpars(:,i)) - median(saveDat.optpars(:,i)))/median(saveDat.optpars(:,i))) > .15

                        saveDat.flag(2,1) = 1;

                    end

                end

                    %% Save to file
                    save(strcat('Optimized/',pt_id,'_optimized.mat'),'saveDat');

            end
            
        % If patient data causes a fatal error for whatever reason, save only a flag.
        catch
            
            flag = 1;
            save(strcat('Optimized/',pt_id,'_optimized.mat'),'flag');
        
        end
    end
end




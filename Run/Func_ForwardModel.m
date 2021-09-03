% Runs forward model. Inputs: patient file name and rest time. Outputs: HR and taus

function Func_ForwardModel(pt_id,restTime)
    %pass in a file name to read and a vector of rest times needed
    %restTime = [start end]
    %Call "Driver basic" in an automated way
    %DriverBasic 

    %close all
    tic; 

    %% Inputs

    echoon  = 0; 
    printon = 0; 

    %% Load data and preprocess data 
    load(strcat('G:\Shared drives\REU shared\Workspaces\Vals\',pt_id,'_val1_WS.mat')); 
    
    dt = mean(diff(Tdata)); 

% Rescale times to start at 0
val_start = val_start - Tdata(1); 
val_end   = val_end - Tdata(1); 
Tdata     = Tdata - Tdata(1); 

% Determine start and end times of the data set 
t_start = Tdata(1); 
if Tdata(end) > 60 
    t_end = val_end + 30;
else 
    t_end = Tdata(end); 
end 
    
% Find the indices of the time data points that are closest to the VM start
% and end times 
[~,i_ts] = min(abs(Tdata - val_start)); 
[~,i_te] = min(abs(Tdata - val_end)); 

%% Find steady-state baseline values up to VM start

HminR = min(Hdata(1:i_ts - 1)); 
HmaxR = max(Hdata(1:i_ts - 1)); 
Hbar = trapz(Hdata(1:i_ts - 1))/(i_ts - 1); 
Rbar = trapz(Rdata(1:i_ts - 1))/(i_ts - 1); 
Pbar = trapz(SPdata(1:i_ts - 1))/(i_ts - 1); 

%% Find time for end of phase I 
% Select the point at which the SBP recuperates to baseline within 10 s of
% the end of the breath hold 
[~,i_t1] = min(abs(SPdata(i_ts:i_ts+round(5/dt)) - Pbar)); 
i_t1 = i_ts + i_t1; 

%% Find time for middle of phase II 
% Select the point that which the SBP reaches a minimum during phase II 
[~,i_t2] = min(SPdata(i_t1:i_te-round(1/dt))); % subtract 1 second to avoid drop off from breath hold
i_t2 = i_t2 + i_t1; 

%% Find time for end of phase III 
% Select the point at which the SBP recuperates to baseline within 5 s of
% the end of the breath hold 
[~,i_t3] = min(abs(SPdata(i_te:i_te+round(5/dt)) - Pbar)); 
i_t3 = i_te + i_t3; 

%% Find time for end of phase IV 
% Select the point at which the SBP returns to baseline after the overshoot
ind = find(SPdata(i_t3:end) <= Pbar, 1, 'first'); 
if isempty(ind) == 1
    i_t4 = length(SPdata); 
else 
    i_t4 = i_t3 + ind; 
end 

%Check in case t4 = tr
if i_t4 == i_t3 
    ind2 = find(SPdata(tr+round(5/dt):end) >= Pbar,1,'last');
    t4 = tr + round(5/dt) + ind2 - 1; 
end  

%% Make thoracic pressure signal 

Rdata = Rdata*1000; 
Rnew = -Rdata; 

a = findpeaks(Rnew(1:i_ts-1)); 
b = findpeaks(-Rnew(1:i_ts-1)); 
b = -b; 
R_exh = mean(a); 
R_inh = mean(b);
R_amp = R_exh - R_inh; 

Amp_norm = 6 - 3.5; 
Amp      = Amp_norm/R_amp; 
RR       = Amp*Rnew; 

a      = findpeaks(-RR(1:i_ts-1));
R_exh  = -mean(a); 
m      = 3.5 - R_exh;
P_resp = RR+m ; 

%Thoracic pressure 
Pth = zeros(size(Tdata)); 
for i = 1:length(Tdata)
    t = Tdata(i); 
        if (t > val_start) && (t < val_end)
            p = 40*(1 - exp(-2*(t - val_start)));
        else 
            p = P_resp(i); 
        end 
     Pth(i) = p; 
end 
      
% Smooth out Pth 
Pth = movmean(Pth,10);

% Find average baseline Pth 
Pthbar = trapz(Pth(1:i_ts-1))/(i_ts-1); 

%% Create data structure 

data.Tdata     = Tdata;
data.Pdata     = SPdata; 
data.Hdata     = Hdata;
data.Pthdata   = Pth;
data.Rdata     = Rdata; 
data.Pbar      = Pbar;
data.Pthbar    = Pthbar;
data.HminR     = HminR;
data.HmaxR     = HmaxR;
data.Hbar      = Hbar; 
data.Rbar      = Rbar; 
data.val_start = val_start; 
data.val_end   = val_end; 
data.i_ts      = i_ts; 
data.i_t1      = i_t1; 
data.i_t2      = i_t2; 
data.i_te      = i_te;
data.i_t3      = i_t3; 
data.i_t4      = i_t4;  
data.age       = Age; 
data.dt        = dt; 

%Global parameters substructure
gpars.echoon = echoon; 

data.gpars   = gpars; 

%% Get nominal parameter values

pars = load_global(data,[1:22]); 
pars

%% Solve model with nominal parameters 

[HR,~,~,Outputs] = model_sol(pars,data);


    time = Outputs(:,1);
    T_pb = Outputs(:,2);
    T_s   = Outputs(:,3);
    T_pr  = Outputs(:,4); 
    

%% Set limits for the axes of each plot 

    Tlims   = [t_start, t_end]; 
    Plims   = [min(Pdata)-10, max(Pdata)+10];
    Pthlims = [-1 41]; 
    Hlims   = [min(Hdata)-5,  max(Hdata)+5]; 
    efflims = [-.1 1.25]; 

% %% Save results in a .mat file
%     
%     %pt = pt_file_name;
%     %clear i
%     %clear pt_file_name
%     %save(strcat('../nomHR/',pt(1:(end-7)),'_nomHR.mat'))
%     
 %% Figures
%     %% Data Heart Rate
%         figure(1) 
%         plot(Tdata,Hdata,'LineWidth',2.5)
% 
%     %% Model Heart Rate
%         figure(2)
%         plot(Tdata,HR,'LineWidth',2.5)
%     
%     %% VM BP with SBP
%         figure(3)
%             hold on
%             set(gca,'Fontsize',28)
%     %Highlight the stages of the VM
%     %{
%     %      xline(Tdata(i_t2)-15,'k--')
%     %      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 300],'FaceColor',[.85 .85 .85])
%     %      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 300],'FaceColor',[.95 .95 .95])
%     %      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 300],'FaceColor',[.85 .85 .85])
%     %      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 300],'FaceColor',[.95 .95 .95])
%     % 
%     %      plot(ones(2,1)*val_start,Plims,'k--')
%     %      plot(ones(2,1)*Tdata(i_t1),Plims,'k--')
%     %      plot(ones(2,1)*Tdata(i_t2),Plims,'k--')
%     %      plot(ones(2,1)*val_end,Plims,'k--')
%     %      plot(ones(2,1)*Tdata(i_t3),Plims,'k--')
%     %      plot(ones(2,1)*Tdata(i_t4),Plims,'k--')
%     %}
%             plot(val_dat(:,1),val_dat(:,4),'Color',[0 .7 1],'LineWidth',2.5)
%             plot(Tdata-Tdata(1),SPdata,'b','LineWidth',3)
%             yticks([ 60  120  180])
%             xticks([0 15 30 45])
%             ylabel('BP (mmHg)')
%             xlim([0 50])
%             ylim([45 200])
%      
%     %% VM HR
%         figure(4)
%         set(gca,'Fontsize',28)
%         % Highlight the stages of the VM
%         %{
%              xline(Tdata(i_t2),'k--')
%              rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
%              rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
%              rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
%              rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
%         %}
%         hold on
%         plot(Tdata-Tdata(1), Hdata,'b','LineWidth',3)
%         plot(Tdata,HR,'Color','r','LineWidth',3)
%    
%         xlabel('Time (s)')
%         ylabel('HR (bpm)')
%         xlim([0 50])
%         ylim([60 130])
%         yticks([80 100 120])
%         xticks([0 15 30 45])
% 
% %    print('-dpng')
% %    print('-depsc2')
% 
%     %% VM Thoracic Pressure
%           figure() 
%              hold on
%             %Highlight stages of the VM
%             %{
%              xline(Tdata(i_t2),'k--')
%              rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
%              rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
%              rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
%              rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
%              plot(Tdata,Pth,'Color','b','LineWidth',3)
%              %}
%              plot(Tdata,Pth,'Color','b','LineWidth',3)
%              set(gca,'Fontsize',28)
% 
%              xlim([0 50])
%              ylim([0 45])
%              xticks([0 15 30 45])
%              yticks([20 40])
%              xlabel('Time (s)')
%              ylabel('Pth (mmHg)')
%    
% %      print('-dpng')
% %      print('-depsc2')
% 
%     %% Tones
%           figure()
%           set(gca,'Fontsize',28)
%           hold on
%           % Highlight the stages of the VM
%           %{
%      rectangle('Position',[val_start -0.3 Tdata(i_t1)-val_start 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1) -0.3 val_end-Tdata(i_t1) 2],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end -0.3 Tdata(i_t3)-val_end 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3) -0.3 Tdata(i_t4)-Tdata(i_t3) 2],'FaceColor',[.95 .95 .95])
%           %}
%          plot(Tdata, T_pb * exp(pars(19)),'LineWidth',3)
%          plot(Tdata,T_pr*exp(pars(20)),'LineWidth',3)  
%          plot(Tdata,T_s*exp(pars(21)),'LineWidth',3)
% 
%          xlim([0 50])
%          ylim([-.2 1])
%          xticks([0 15 30 45])
%          yticks([0 .4 .8])
%          ylabel('Neural Outflow')
%          xlabel('Time (s)')
%          legend('Parasympathetic','Respiratory','Sympathetic')
% 
% %      print('-dpng')
% %      print('-depsc2')
%    
%     %% Four Panel Figure
% figure()
%    subplot(2,2,1);
%    set(gca,'Fontsize',20)
%    hold on
%    % Highlighting the stages of the VM
%    %{
%             xline(Tdata(i_t2),'k--')
%             rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
%             rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
%             rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
%             rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
%             
%             plot(ones(2,1)*val_start,Plims,'k--')
%             plot(ones(2,1)*Tdata(i_t1),Plims,'k--')
%             plot(ones(2,1)*Tdata(i_t2),Plims,'k--')
%             plot(ones(2,1)*val_end,Plims,'k--')
%             plot(ones(2,1)*Tdata(i_t3),Plims,'k--')
%             plot(ones(2,1)*Tdata(i_t4),Plims,'k--')
%    %}
%    hold on
%    plot(val_dat(:,1),val_dat(:,4),'Color',[0 .7 1],'LineWidth',1)
%    plot(Tdata-Tdata(1),SPdata,'b','LineWidth',3)
%    
%    yticks([ 60  120  180])
%    xticks([0 15 30 45])
%    ylabel('BP (mmHg)')
%    xlim([0 50])
%    ylim([45 200])
%    
%    subplot(2,2,2);
%    set(gca,'Fontsize',20)
% % Highlight stages of the VM
% %{
%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 500],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 500],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 500],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 500],'FaceColor',[.95 .95 .95])
% %}
%    hold on
%    plot(Tdata-Tdata(1)-15, Hdata,'b','LineWidth',3)
%    plot(Tdata-15,HR,'Color','r','LineWidth',3)
% 
%    xlabel('Time (s)')
%    ylabel('HR (bpm)')
%    xlim([0 50])
%    ylim([60 130])
%    yticks([80 100 120])
%    xticks([0 15 30 45])
% 
% subplot(2,2,3);   
%     set(gca,'Fontsize',20)
%     hold on
% % Highlight stages of the VM
% %{
%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
% %}     
%     plot(Tdata,Pth,'Color','b','LineWidth',3)
%     
%     xlim([0 50])
%     ylim([0 45])
%     xticks([0 15 30 45])
%     yticks([20 40])
%     xlabel('Time (s)')
%     ylabel('Pth (mmHg)')
% 
%  subplot(2,2,4); 
%      set(gca,'Fontsize',20)
%      hold on
%      % Highlight stages of the VM
%      %{
% %      rectangle('Position',[val_start-15 -0.3 Tdata(i_t1)-val_start 2],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t1)-15 -0.3 val_end-Tdata(i_t1) 2],'FaceColor',[.95 .95 .95])
% %      rectangle('Position',[val_end-15 -0.3 Tdata(i_t3)-val_end 2],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t3)-15 -0.3 Tdata(i_t4)-Tdata(i_t3) 2],'FaceColor',[.95 .95 .95])
%      %}
%      plot(Tdata-Tdata(1)-15, T_pb * exp(pars(19)),'LineWidth',3)
%      plot(Tdata-15,T_pr,'LineWidth',3)  
%      plot(Tdata-15,T_s,'LineWidth',3)
%      
%      xlim([0 50])
%      ylim([-.2 1])
%      xticks([0 15 30 45])
%      yticks([0 .4 .8])
%      xlabel('Time (s)')
%      legend('Parasympathetic','Resiratory','Sympathetic')
     
    elapsed_time = toc;
end


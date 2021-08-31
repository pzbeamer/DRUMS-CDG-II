function [Sigs]=DriverBasicME(data,INDMAP,Opt_pars,k,pt)

%% Get nominal parameter values

pars = load_global(data,INDMAP); 

%% Solve model with nominal parameters 
pars(INDMAP)=log(Opt_pars(k,:));
[HR,~,~,Outputs] = model_sol(pars,data);

time = Outputs(:,1);
T_s   = Outputs(:,3);
T_pb = Outputs(:,2);
T_pr  = Outputs(:,4);

Sigs=[T_s T_pb];

%% Set limits for the axes of each plot 
    Tdata     = data.Tdata;
    SPdata    = data.Pdata;
    Hdata     = data.Hdata;
    Pth       = data.Pthdata;
    Rdata     = data.Rdata;
    Pbar      = data.Pbar;
    Pthbar    = data.Pthbar;
    HminR     = data.HminR;
    HmaxR     = data.HmaxR;
    Hbar      = data.Hbar; 
    Rbar      = data.Rbar; 
    val_start = data.val_start; 
    val_end   = data.val_end; 
    i_ts      = data.i_ts; 
    i_t1      = data.i_t1; 
    i_t2      = data.i_t2; 
    i_te      = data.i_te;
    i_t3      = data.i_t3; 
    i_t4      = data.i_t4;  
    Age       = data.age; 
    dt        = data.dt; 
    val_dat   = data.val_dat;

   
% Determine start and end times of the data set 
t_start = Tdata(1); 
if Tdata(end) > 60 
    t_end = val_end + 30;
else 
    t_end = Tdata(end); 
end 

Tlims   = [t_start, t_end]; 
Plims   = [min(SPdata)-10, max(SPdata)+10];
Pthlims = [-1 41]; 
Hlims   = [min(Hdata)-5,  max(Hdata)+5]; 
efflims = [-.1 .2]; 

%% Save results in a .mat file 
%save nomHR.mat 


%elapsed_time = toc


% figure(1)
% plot(Tdata,Hdata,'LineWidth',2.5)
% 
% figure(2)
% plot(Tdata,HR,'LineWidth',2.5)
% 
% figure(3)
% plot(val_dat(:,1),val_dat(:,4),'LineWidth',2.5)

<<<<<<< HEAD
figure()

hold on
%    set(gca,'Fontsize',28)
% 
     xline(Tdata(i_t2),'k--')
     rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.8 .8 .8])
     rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.9 .9 .9])
     rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.8 .8 .8])
     rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.9 .9 .9])

%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 300],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 300],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 300],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 300],'FaceColor',[.95 .95 .95])
=======
% figure()
% 
% hold on
% %    set(gca,'Fontsize',28)
% % 
%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.9 .9 .9])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.9 .9 .9])
% 
% %      xline(Tdata(i_t2)-15,'k--')
% %      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 300],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 300],'FaceColor',[.95 .95 .95])
% %      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 300],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 300],'FaceColor',[.95 .95 .95])
% %      plot(ones(2,1)*val_start,Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t1),Plims,'k--')
% %     plot(ones(2,1)*Tdata(i_t2),Plims,'k--')
% %      plot(ones(2,1)*val_end,Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t3),Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t4),Plims,'k--')
% 
%    hold on
%    plot(val_dat(:,1),val_dat(:,4),'Color',[0 .7 1],'LineWidth',1)
%    plot(Tdata-Tdata(1),SPdata,'b','LineWidth',3)
% %    yticks([ 60  120  180])
% %    xticks([0 15 30 45])
%    ylabel('BP (mmHg)')
% %    xlim([0 50])
% %    ylim([45 200])
% %    
%    
% %    figure()
% %    
% %    set(gca,'Fontsize',28)
% %      xline(Tdata(i_t2)-15,'k--')
% %      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 200],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 200],'FaceColor',[.95 .95 .95])
% %      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 200],'FaceColor',[.85 .85 .85])
% %      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.95 .95 .95])
% %    
% %    hold on
% %    plot(Tdata-Tdata(1)-15, Hdata,'b','LineWidth',3)
% %    xlabel('Time (s)')
% %    ylabel('HR (bpm)')
% % %    xlim([0 50])
% % %    ylim([60 130])
% % %    yticks([80 100 120])
% % %    xticks([0 15 30 45])
% %    
%    print('-dpng')
%    print('-depsc2')
%    
% 
% figure()
%    
%    set(gca,'Fontsize',28)
%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
%    
%    hold on
%    plot(Tdata-Tdata(1), Hdata,'b','LineWidth',3)
%    plot(Tdata,HR,'Color','r','LineWidth',3)
%    
% 
%    xlabel('Time (s)')
%    ylabel('HR (bpm)')
% %    xlim([0 50])
% %    ylim([60 130])
% %    yticks([80 100 120])
% %    xticks([0 15 30 45])
%    
%    print('-dpng')
%    print('-depsc2')
%    
%    
%  figure() 
%     
%      hold on
%      plot(Tdata,Pth,'Color','b','LineWidth',3)
%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
%      plot(Tdata,Pth,'Color','b','LineWidth',3)
%      set(gca,'Fontsize',28)
% % 
% %      xlim([0 50])
% %      ylim([0 45])
% %      xticks([0 15 30 45])
% %      yticks([20 40])
% %      xlabel('Time (s)')
% %      ylabel('Pth (mmHg)')
% %      
%      print('-dpng')
%      print('-depsc2')
%      
%      
%      figure()
%      set(gca,'Fontsize',28)
%      hold on
%      rectangle('Position',[val_start -0.3 Tdata(i_t1)-val_start 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1) -0.3 val_end-Tdata(i_t1) 2],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end -0.3 Tdata(i_t3)-val_end 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3) -0.3 Tdata(i_t4)-Tdata(i_t3) 2],'FaceColor',[.95 .95 .95])
%      plot(Tdata-Tdata(1), T_pb * exp(pars(19)),'LineWidth',3)
%      plot(Tdata,T_pr*exp(pars(20)),'LineWidth',3)  
%      plot(Tdata,T_s*exp(pars(21)),'LineWidth',3)
%      
% %      xlim([0 50])
% %      ylim([-.2 1])
% %      xticks([0 15 30 45])
% %      yticks([0 .4 .8])
% %      %ylabel('Neural Outflow')
%      xlabel('Time (s)')
%      %legend('Parasympathetic','Respiratory','Sympathetic')
%      
%      print('-dpng')
%      print('-depsc2')
%      
%      
%      return





figure(pt)
subplot(2,2,1);
hold on
   set(gca,'Fontsize',20)

%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])

     xline(Tdata(i_t2)-15,'k--')
     rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 500],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 500],'FaceColor',[.95 .95 .95])

>>>>>>> f8ab25530ff02cfed0e742f92fa4d0ce8cff0632
%      plot(ones(2,1)*val_start,Plims,'k--')
%      plot(ones(2,1)*Tdata(i_t1),Plims,'k--')
%     plot(ones(2,1)*Tdata(i_t2),Plims,'k--')
%      plot(ones(2,1)*val_end,Plims,'k--')
%      plot(ones(2,1)*Tdata(i_t3),Plims,'k--')
%      plot(ones(2,1)*Tdata(i_t4),Plims,'k--')

   hold on
<<<<<<< HEAD
   plot(val_dat(:,1),val_dat(:,4),'Color',[0 .7 1],'LineWidth',1)
   plot(Tdata-Tdata(1),SPdata,'b','LineWidth',3)
=======
   plot(val_dat(:,1)-15,val_dat(:,4),'Color',[0 .7 1],'LineWidth',1)
   plot(Tdata-Tdata(1)-15,SPdata,'b','LineWidth',3)
>>>>>>> f8ab25530ff02cfed0e742f92fa4d0ce8cff0632
%    yticks([ 60  120  180])
%    xticks([0 15 30 45])
   ylabel('BP (mmHg)')
%    xlim([0 50])
<<<<<<< HEAD
%    ylim([45 200])
%    
   
%    figure()
%    
%    set(gca,'Fontsize',28)
%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 200],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.95 .95 .95])
%    
%    hold on
%    plot(Tdata-Tdata(1)-15, Hdata,'b','LineWidth',3)
%    xlabel('Time (s)')
%    ylabel('HR (bpm)')
% %    xlim([0 50])
% %    ylim([60 130])
% %    yticks([80 100 120])
% %    xticks([0 15 30 45])
%    
   print('-dpng')
   print('-depsc2')
   

figure()
   
   set(gca,'Fontsize',28)
     xline(Tdata(i_t2),'k--')
     rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
   
   hold on
   plot(Tdata-Tdata(1), Hdata,'b','LineWidth',3)
   plot(Tdata,HR,'Color','r','LineWidth',3)
=======
    ylim([45 200])
   
%   figure()
 subplot(2,2,2);  
   set(gca,'Fontsize',20)

%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])

     xline(Tdata(i_t2)-15,'k--')
     rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 500],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 500],'FaceColor',[.95 .95 .95])

   
   hold on
   plot(Tdata-Tdata(1)-15, Hdata,'b','LineWidth',3)
   plot(Tdata-15,HR,'Color','r','LineWidth',3)
%    plot(Tdata-Tdata(1), HR_LM,'r','LineWidth',4)
>>>>>>> f8ab25530ff02cfed0e742f92fa4d0ce8cff0632
   

   xlabel('Time (s)')
   ylabel('HR (bpm)')
%    xlim([0 50])
<<<<<<< HEAD
%    ylim([60 130])
%    yticks([80 100 120])
%    xticks([0 15 30 45])
   
   print('-dpng')
   print('-depsc2')
   
   
 figure() 
    
     hold on
     plot(Tdata,Pth,'Color','b','LineWidth',3)
     xline(Tdata(i_t2),'k--')
     rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 400],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 400],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 400],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 400],'FaceColor',[.95 .95 .95])
     plot(Tdata,Pth,'Color','b','LineWidth',3)
     set(gca,'Fontsize',28)
% 
%      xlim([0 50])
%      ylim([0 45])
%      xticks([0 15 30 45])
%      yticks([20 40])
%      xlabel('Time (s)')
%      ylabel('Pth (mmHg)')
%      
     print('-dpng')
     print('-depsc2')
     
     
     figure()
     set(gca,'Fontsize',28)
     hold on
     rectangle('Position',[val_start -0.3 Tdata(i_t1)-val_start 2],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1) -0.3 val_end-Tdata(i_t1) 2],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end -0.3 Tdata(i_t3)-val_end 2],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3) -0.3 Tdata(i_t4)-Tdata(i_t3) 2],'FaceColor',[.95 .95 .95])
     plot(Tdata-Tdata(1), T_pb * exp(pars(19)),'LineWidth',3)
     plot(Tdata,T_pr*exp(pars(20)),'LineWidth',3)  
     plot(Tdata,T_s*exp(pars(21)),'LineWidth',3)
     
%      xlim([0 50])
%      ylim([-.2 1])
%      xticks([0 15 30 45])
%      yticks([0 .4 .8])
%      %ylabel('Neural Outflow')
     xlabel('Time (s)')
     %legend('Parasympathetic','Respiratory','Sympathetic')
     
     print('-dpng')
     print('-depsc2')
     
     
     return



% figure(pt)
% 
% 
% 
% %figure()
% subplot(2,2,1);
% hold on
%    set(gca,'Fontsize',20)
% 
% %      xline(Tdata(i_t2),'k--')
% %      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
% %      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
% 
%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 300],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 300],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 300],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 300],'FaceColor',[.95 .95 .95])
% 
% %      plot(ones(2,1)*val_start,Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t1),Plims,'k--')
% %     plot(ones(2,1)*Tdata(i_t2),Plims,'k--')
% %      plot(ones(2,1)*val_end,Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t3),Plims,'k--')
% %      plot(ones(2,1)*Tdata(i_t4),Plims,'k--')
% 
%    hold on
%    plot(val_dat(:,1)-15,val_dat(:,4),'Color',[0 .7 1],'LineWidth',1)
%    plot(Tdata-Tdata(1)-15,SPdata,'b','LineWidth',3)
%    yticks([ 60  120  180])
%    xticks([0 15 30 45])
%    ylabel('BP (mmHg)')
%    xlim([0 50])
%    ylim([45 200])
%    
% %   figure()
%  subplot(2,2,2);  
%    set(gca,'Fontsize',20)
% 
% %      xline(Tdata(i_t2),'k--')
% %      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
% %      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
% 
%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 200],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.95 .95 .95])
% 
%    
%    hold on
%    plot(Tdata-Tdata(1)-15, Hdata,'b','LineWidth',3)
%    plot(Tdata-15,HR,'Color','r','LineWidth',3)
% %    plot(Tdata-Tdata(1), HR_LM,'r','LineWidth',4)
%    
% 
%    xlabel('Time (s)')
%    ylabel('HR (bpm)')
%    xlim([0 50])
%    ylim([60 130])
%    yticks([80 100 120])
%    xticks([0 15 30 45])
%    
%    
%  %figure() 
% subplot(2,2,3);    
%      hold on
% 
% %      xline(Tdata(i_t2),'k--')
% %      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
% %      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
% %      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
%      plot(Tdata,Pth,'Color','b','LineWidth',3)
% 
%      xline(Tdata(i_t2)-15,'k--')
%      rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 200],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 200],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.95 .95 .95])
%      plot(Tdata-15,Pth,'Color','b','LineWidth',3)
% 
%      set(gca,'Fontsize',20)
%      xlim([0 50])
%      ylim([0 45])
%      xticks([0 15 30 45])
%      yticks([20 40])
%      xlabel('Time (s)')
%      ylabel('Pth (mmHg)')
%      
% 
%  subplot(2,2,4);    
%  %    figure()
% 
%      
% 
%      set(gca,'Fontsize',20)
%      hold on
%      rectangle('Position',[val_start-15 -0.3 Tdata(i_t1)-val_start 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t1)-15 -0.3 val_end-Tdata(i_t1) 2],'FaceColor',[.95 .95 .95])
%      rectangle('Position',[val_end-15 -0.3 Tdata(i_t3)-val_end 2],'FaceColor',[.85 .85 .85])
%      rectangle('Position',[Tdata(i_t3)-15 -0.3 Tdata(i_t4)-Tdata(i_t3) 2],'FaceColor',[.95 .95 .95])
%      plot(Tdata-Tdata(1)-15, T_pb * exp(pars(19)),'LineWidth',3)
%      plot(Tdata-15,T_pr,'LineWidth',3)  
%      plot(Tdata-15,T_s,'LineWidth',3)
%      
%      xlim([0 50])
%      ylim([-.2 1])
%      xticks([0 15 30 45])
%      yticks([0 .4 .8])
%      xlabel('Time (s)')
%      %legend('Parasympathetic','Resiratory','Sympathetic')
%      
=======
   ylim([60 130])
%    yticks([80 100 120])
%    xticks([0 15 30 45])
   
   
 %figure() 
subplot(2,2,3);    
     hold on

%      xline(Tdata(i_t2),'k--')
%      rectangle('Position',[val_start -10 Tdata(i_t1)-val_start 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t1) -10 val_end-Tdata(i_t1) 200],'FaceColor',[.9 .9 .9])
%      rectangle('Position',[val_end -10 Tdata(i_t3)-val_end 200],'FaceColor',[.8 .8 .8])
%      rectangle('Position',[Tdata(i_t3) -10 Tdata(i_t4)-Tdata(i_t3) 200],'FaceColor',[.9 .9 .9])
%      plot(Tdata,Pth,'Color','b','LineWidth',3)

     xline(Tdata(i_t2)-15,'k--')
     rectangle('Position',[val_start-15 -10 Tdata(i_t1)-val_start 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1)-15 -10 val_end-Tdata(i_t1) 500],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end-15 -10 Tdata(i_t3)-val_end 500],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3)-15 -10 Tdata(i_t4)-Tdata(i_t3) 500],'FaceColor',[.95 .95 .95])
     plot(Tdata-15,Pth,'Color','b','LineWidth',3)

     set(gca,'Fontsize',20)
      xlim([0 50])
     ylim([0 45])
%      xticks([0 15 30 45])
%      yticks([20 40])
     xlabel('Time (s)')
     ylabel('Pth (mmHg)')
     

 subplot(2,2,4);    
 %    figure()

     

     set(gca,'Fontsize',20)
     hold on
     rectangle('Position',[val_start-15 -0.3 Tdata(i_t1)-val_start 20],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t1)-15 -0.3 val_end-Tdata(i_t1) 20],'FaceColor',[.95 .95 .95])
     rectangle('Position',[val_end-15 -0.3 Tdata(i_t3)-val_end 20],'FaceColor',[.85 .85 .85])
     rectangle('Position',[Tdata(i_t3)-15 -0.3 Tdata(i_t4)-Tdata(i_t3) 20],'FaceColor',[.95 .95 .95])
     plot(Tdata-Tdata(1)-15, T_pb * exp(pars(19)),'LineWidth',3)
     plot(Tdata-15,T_pr,'LineWidth',3)  
     plot(Tdata-15,T_s,'LineWidth',3)
     
%      xlim([0 50])
      ylim([-.2 2])
%      xticks([0 15 30 45])
%      yticks([0 .4 .8])
     xlabel('Time (s)')
     %legend('Parasympathetic','Resiratory','Sympathetic')
     
>>>>>>> f8ab25530ff02cfed0e742f92fa4d0ce8cff0632
      return

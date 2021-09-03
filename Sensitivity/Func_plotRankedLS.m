function plotRankedLS(sample)
Snormv1 = zeros(22,10);
Snormv2 = zeros(22,10);

for j = 1:length(sample)
    sample(j)
    pt_id = sample(j);
    load(strcat('Sens/sens',pt_id,'_val1.mat'));
    sens_norm1 = sens_norm;
    load(strcat('Sens/sens',pt_id,'_val2.mat'));
    sens_norm2 = sens_norm;
    Snormv1(:,j) = sens_norm1'/max(sens_norm1);
    Snormv2(:,j) = sens_norm2'/max(sens_norm1);
end

for i = 1:22 %number of parameters
    avgsv1(i) = mean(Snormv1(i,:));
    avgsv2(i) = mean(Snormv2(i,:));
    errv1(i) = std(Snormv1(i,:))/sqrt(length(pt));
    errv2(i) = std(Snormv2(i,:))/sqrt(length(pt));
end

[~,paramsens] = sort(avgsv1,'descend');
avgsv1 = avgsv1(paramsens);
avgsv2 = avgsv2(paramsens);

%% Figures

% Scatterplot with error bars
hfig1 = figure()
hold on 

set(gcf,'units','normalized','outerposition',[0 0 .75 .75]);
set(gcf,'renderer','Painters')
xlim([0 length(paramsens)+1])
ylabel('Ranked Sensitivities')
xlabel('Parameters')
title('Ranked Relative Sensitivities')
Xtick = 1:length(paramsens);
set(gca,'xtick',Xtick)
set(gca,'TickLabelInterpreter','latex')
Xlabel = params(paramsens); 
set(gca,'XTickLabels',Xlabel)
set(gca,'YScale','log')
set(gca,'XTickLabels',Xlabel)
ylim([1e-3 1])
ytick = [1e-3 1e-2 1e-1 1]; 

hold on
%     
% txt = '$\eta_1$'; 
% text(24,8e-2,txt,'interpreter','latex','FontSize',40)
% txt = '$\eta_2$'; 
% text(24,8e-4,txt,'interpreter','latex','FontSize',40)

e1 = errorbar([1:length(Rsens)],avgsv1,errv1,'o','MarkerFaceColor','r');
e1.Color = 'r';
e1.LineWidth = 1;
e2 = errorbar([1:length(Rsens)],avgsv2,errv2,'o','MarkerFaceColor','b');
e2.Color = 'b';
e2.LineWidth = 1;
legend('Valsalva 1','Valsalva 2');

print(hfig1,'-depsc2','LSA.eps')
print(hfig1,'-dpng','LSA.png') 


% Bar Chart Ranked Sensitivities (for one patient... would need to update
% for many)

% eta1 = 1e-1; 
% eta2 = 1e-3; 
% 
% hfig2 = figure();
% clf
% set(gcf,'units','normalized','outerposition',[0 0 .75 .75]);
% set(gcf,'renderer','Painters')
% set(gca,'FontSize',25)
% h=bar([1:length(Rsens)],Rsens./max(Rsens),'b','facealpha',.5);
% hold on 
% xlim([0 length(Isens)+1])
% grid on
% ylabel('Ranked LSA')
% xlabel('Parameters')
% %title('Ranked Relative Sensitivities')
% Xtick = 1:length(Isens);
% set(gca,'xtick',Xtick)
% set(gca,'TickLabelInterpreter','latex')
% Xlabel = params(Isens); 
% set(gca,'XTickLabels',Xlabel)
% set(gca,'YScale','log')
% set(gca,'XTickLabels',Xlabel)
% ylim([1e-4 1])
% ytick = [1e-4 1e-3 1e-2 1e-1 1]; 
% set(gca,'Ytick',ytick)
% hold on
% set(gca,'FontSize',25)
% plot([0 length(Rsens)+1],eta1*ones(2,1),'k--',[0 length(Rsens)+1],eta2*ones(2,1),'k--')
% txt = '$\eta_1$'; 
% text(24,8e-2,txt,'interpreter','latex','FontSize',40)
% txt = '$\eta_2$'; 
% text(24,8e-4,txt,'interpreter','latex','FontSize',40)
% 
% print(hfig2,'-depsc2','LSAbar.eps')
% print(hfig2,'-dpng','LSAbar.png') 
end

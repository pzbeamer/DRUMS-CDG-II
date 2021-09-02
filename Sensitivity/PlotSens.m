%% Plots

eta1 = 1e-1; 
eta2 = 1e-3; 

%Ranked sensitivities
hfig1 = figure(1);
clf
set(gcf,'units','normalized','outerposition',[0 0 .75 .75]);
set(gcf,'renderer','Painters')
set(gca,'FontSize',25)
h=bar([1:length(Rsens)],Rsens./max(Rsens),'b','facealpha',.5);
hold on 
xlim([0 length(Isens)+1])
grid on
ylabel('Ranked LSA')
xlabel('Parameters')
%title('Ranked Relative Sensitivities')
Xtick = 1:length(Isens);
set(gca,'xtick',Xtick)
set(gca,'TickLabelInterpreter','latex')
Xlabel = params(Isens); 
set(gca,'XTickLabels',Xlabel)
set(gca,'YScale','log')
set(gca,'XTickLabels',Xlabel)
ylim([1e-4 1])
ytick = [1e-4 1e-3 1e-2 1e-1 1]; 
set(gca,'Ytick',ytick)
hold on
set(gca,'FontSize',25)
plot([0 length(Rsens)+1],eta1*ones(2,1),'k--',[0 length(Rsens)+1],eta2*ones(2,1),'k--')
txt = '$\eta_1$'; 
text(24,8e-2,txt,'interpreter','latex','FontSize',40)
txt = '$\eta_2$'; 
text(24,8e-4,txt,'interpreter','latex','FontSize',40)

print(hfig1,'-depsc2','LSA.eps')
print(hfig1,'-dpng','LSA.png') 
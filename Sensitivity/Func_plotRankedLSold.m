function plotRankedLSold(pt)
pt = [20 22 27 28 32 33 34 41 45];
Snormv1 = zeros(22,10);
Snormv2 = zeros(22,10);
for k = 1:9
    load(strcat('Sens/Old/sens',num2str(pt(k)),'.mat'));
    sens_norm1 = sens_norm;
    load(strcat('Sens/Old/sens',num2str(pt(k)),'_2.mat'));
    sens_norm2 = sens_norm;
    Snormv1(:,k) = sens_norm1'/max(sens_norm1);
    Snormv2(:,k) = sens_norm2'/max(sens_norm1);
end

for i = 1:22
    avgsv1(i) = mean(Snormv1(i,:));
    avgsv2(i) = mean(Snormv2(i,:));
    errv1(i) = std(Snormv1(i,:))/sqrt(length(pt));
    errv2(i) = std(Snormv2(i,:))/sqrt(length(pt));
end

[~,paramsens] = sort(avgsv1,'descend');
avgsv1 = avgsv1(paramsens);
avgsv2 = avgsv2(paramsens);

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
end

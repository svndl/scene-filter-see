function [] = plot_tuning_curves(model)


for n = 1:size(model.r_br,1)
    
    subplot(2,1,1); hold on;
    plot(model.rng,model.r_br(n,:),'r-','linewidth',1)
    
    subplot(2,1,2); hold on;
    plot(model.rng,model.r_dk(n,:),'b-','linewidth',1)

end

% box off;
% set(gca,'Ycolor',[1 1 1])
% set(gca,'Xcolor',[1 1 1])
% ylabel('neuronal responses','color',[0 0 0]);
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% 
% ylim([-0.25 0.75]);
% xlim([min(disps) max(disps)]);



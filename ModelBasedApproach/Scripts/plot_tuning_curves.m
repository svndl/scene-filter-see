function [] = plot_tuning_curves(model)


for n = 1:size(model.response,1)
    
    subplot(3,2,3); hold on;
    plot(model.env.rng,model.gain.bright(n).*model.response(n,:),'r-','linewidth',1)
    xlabel('Binocular Disparity (arcmin)');
    ylabel('ON response');
    xlim([min(model.env.rng) max(model.env.rng)]);
    
    subplot(3,2,5); hold on;
    plot(model.env.rng, model.gain.dark(n).*model.response(n,:),'b-','linewidth',1)
    xlabel('Binocular Disparity (arcmin)');
    ylabel('OFF response');
    xlim([min(model.env.rng) max(model.env.rng)]);

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



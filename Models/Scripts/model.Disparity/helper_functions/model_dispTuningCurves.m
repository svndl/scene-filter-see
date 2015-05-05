function [] = model_dispTuningCurves(model,col)


for n = 1:size(model.response,1)
    
    subplot(3,2,2+col); hold on;
    plot(model.env.rng,model.gain.bright(n).*model.response(n,:),'r-','linewidth',1)
    %xlabel('Binocular Disparity (arcmin)');
    ylabel('Bright response');
    xlim([min(model.env.rng) max(model.env.rng)]);
    ylim([0 30]);
    
    subplot(3,2,4+col); hold on;
    plot(model.env.rng, model.gain.dark(n).*model.response(n,:),'b-','linewidth',1)
    xlabel('Binocular Disparity (arcmin)');
    ylabel('Dark response');
    xlim([min(model.env.rng) max(model.env.rng)]);
    ylim([0 30]);

end



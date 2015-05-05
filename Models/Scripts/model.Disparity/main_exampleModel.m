function brain = main_exampleModel
%
% This function runs an image and depth map through the brain-based model
% of perceived depth

    model = main_getModel;

    
    % noise image and depth map
    try
        pixels = mkFract(50, 1.2);
    catch
        disp('Unable to crete a test image');
        return;
    end
    pixels    = (pixels - min(pixels(:)))./range(pixels(:));
    depth = zeros(size(pixels));
    im = model_RGCResponse(pixels, depth, 'simple');

    brain = calc_applyModel(model, im);
    trueplot = 1;
    if(trueplot)
        figure;  hold on;
        model_plotTuningCurves(model, 1);
    
        subplot(3,2,1); hold on; title('Environmental Probabilities');
        plot(model.env.rng, model.env.bright,'r');
        plot(model.env.rng, model.env.dark,'b');
        xlabel('Binocular Disparity (arcmin)');
        ylabel('Probability ON/OFF');
        xlim([min(model.env.rng) max(model.env.rng)]);
    
        subplot(3,2,4); hold on; xlabel('Image');
        imagesc(brain.image.rgc);
        axis image; colorbar; colormap gray;
        caxis([-1 1]);
    
        subplot(3,2,6); hold on; xlabel('Disparity Map (arcmin)');
        imagesc(brain.disparity);
        axis image; colorbar
    end
end





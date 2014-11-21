function [brain] = predict_model_response(image_name, testing, picture, trueplot)
%
% This function runs an image and depth map through the brain-based model
% of perceived depth

% load in natural scene statistics
env.feature      = 'disp';
%% Visual feature properties in the environment
% environmental probabilities for brights and darks
% env is a structure with the folloving fields:
% env.bright
% env.dark
% env.all
% env.rng

env.numsamples = 1001;
env = get_environ_stats(0, env);

% set up brain model to use

model.N           = 120;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

model = build_model_cell_population(env, model);

% load in image and disparity map

if(testing)
    
    % noise image and depth map
    image.pixels    = mkFract(124,1.2);
    image.pixels    = (image.pixels - min(image.pixels(:)))./range(image.pixels(:));
    image.depth     = mkFract(124,1);
    image.depth    = (image.depth - min(image.depth(:)))./range(image.depth(:));
    image.depth     = 5*(image.depth - 0.5) + 5;
    
    % since we're initially interested in model results for pictures, set the testing
    % depth map to zeros
    if(picture)
        image.depth = zeros(size(image.depth));
    end
else
    
    % load in an image from the perceptual study
    % it would be okay to downsample the images for initial testing
    
    % XXXXXX
    
    % since we're initially interested in model results for pictures, set the testing
    % depth map to zeros
    if(picture)
        image.depth = zeros(size(image.depth));
    end
end

image = convert_image_to_rgc_response(image);
image = convert_depth_to_disparity(image);

brain = apply_model_to_image(model,image);

if(trueplot)
    figure;  hold on;
    plot_tuning_curves(model)
    
    subplot(3,2,1); hold on; title('Environmental Probabilities');
    plot(env.rng,env.bright,'r');
    plot(env.rng,env.dark,'b');
    xlabel('Binocular Disparity (arcmin)');
    ylabel('Probability ON/OFF');
    xlim([min(model.env.rng) max(model.env.rng)]);
    
    subplot(3,2,4); hold on; xlabel('Image');
    imagesc(image.rgc);
    axis image; colorbar; colormap gray;
    caxis([-1 1]);
    
    subplot(3,2,6); hold on; xlabel('Disparity Map (arcmin)');
    imagesc(brain.disparity);
    axis image; colorbar
end





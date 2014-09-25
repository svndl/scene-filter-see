function [model,pred] = model_brain(image,paths,picturetrue)
%
% analyze the predictiveness of model brain analysis for
% perceptual responses


% load in natural scene statistics as model of the brain's visual experience
env.feature = 'disp';
env         = get_environ_stats(paths,env.feature); % env has the following fields: bright, dark, all, rng


% set up brain model properties
model.N           = 120;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

model = build_model_cell_population(env, model);

sz = [50 50]; % this should be enough to prevent cropping from the two filtering stages

% apply brain model to images
for x = 1:length(image)
    
    display(['Applying brain model to image ' num2str(x)]);
    
    % convert images to gamma-removed grayscale
    image(x).orig.V = rgb2gray(image(x).orig.RGB.^(2.2));
    image(x).enh.V = rgb2gray(image(x).enh.RGB.^(2.2));
    image(x).deg.V = rgb2gray(image(x).deg.RGB.^(2.2));
    
    % downsize images for quicker analysis
    orig = imresize(image(x).orig.V,sz);
    enh = imresize(image(x).enh.V,sz);
    deg = imresize(image(x).deg.V,sz);
    
    if picturetrue
        depth = zeros(sz);  % without depth map
    else
        depth = imresize(image(x).depth,sz); % with depth map
    end
    
    % pad images before filtering
    orig = padarray(orig,[50 50]);
    enh = padarray(enh,[50 50]);
    deg = padarray(deg,[50 50]);
    depth = padarray(depth,[50 50]);
    
    % run images through brain model
    brain(x).orig  = apply_model_to_image(model,orig,depth);
    brain(x).enh  = apply_model_to_image(model,enh,depth);
    brain(x).deg  = apply_model_to_image(model,deg,depth);

    % get overall scene volume from brain
    resp_orig(x) = brain(x).orig.volume;
    resp_enh(x) = brain(x).enh.volume;
    resp_deg(x) = brain(x).deg.volume;

end

% convert brain responses to differences
pred.enh_deg    = resp_enh - resp_deg;
pred.enh_orig   = resp_enh - resp_orig;
pred.orig_deg   = resp_orig - resp_deg;

if picturetrue
    save([paths.results '/brain_model_all_picture.mat'],'brain')
    save([paths.results '/brain_model_results_picture.mat'],'model','pred')
else
    save([paths.results '/brain_model_all_world.mat'],'brain')
    save([paths.results '/brain_model_results_world.mat'],'model','pred')
end

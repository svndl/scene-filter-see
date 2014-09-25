function brain = apply_model_to_image(model, im, depth)
%
% apply features of brain model to the image input to predict brain
% response

image.pixels    = im;
image.depth     = depth;

if numel(im) > 2                                % test images are fed as two pixels, so don't do conversions
    
    image = convert_image_to_rgc_response(image);   % simulate retinal processing
    image = convert_depth_to_disparity(image);      % simulate visual processing of depth
    
else
    
    image.rgc       = image.pixels;
    image.max       = 1;
    image.disparity = image.depth;
    
end

brain.disparity = NaN*ones(size(image.disparity)); %initialize brain disparity response

for p = 1:numel(image.rgc)
    
    % grab luminance and disparity
    lum = image.rgc(p);
    disp = image.disparity(p);
    
    % clamp luminance to max value
    lum = sign(lum).*min([abs(lum) image.max]);
    
    % set cell population response bias based on relative luminance (bright
    % or dark) and luminance magnitude (weak to strong)
    
    % gain for each cell is a weighted combination of the biased
    % environmental gains and an unbiased set of gains
    if lum > 0
        
        % concat biased and unbiased responses
        resp_cat = [model.gain.bright ; repmat(mean(model.gain.bright),size(model.gain.bright))];
        
        % concat luminance magnitude based weights
        l = lum/image.max;
        weight_cat = [repmat(l, size(model.gain.bright)); repmat(1 - l, size(model.gain.bright))];
        gain = wmean(resp_cat, weight_cat);
        
    elseif lum < 0
        
        % concat biased and unbiased responses
        resp_cat = [model.gain.dark ; repmat(mean(model.gain.dark),size(model.gain.dark))];
        
        % concat luminance magnitude based weights
        l = abs(lum)/image.max;
        weight_cat = [repmat(l, size(model.gain.dark)); repmat(1 - l, size(model.gain.dark))];
        gain = wmean(resp_cat, weight_cat);
        
    elseif lum == 0
        
        gain = zeros(size(model.response));
        
    end
    
    % get response magnitude for each cell
    for n = 1:model.N
        
        cell_resp   = gain(n).*model.response(n,:);
        resp        = interp1(model.env.rng, cell_resp, disp);
        popresp(n)  = resp;
    end
    
    val = interp1(model.preferences, popresp, model.env.rng);
    
    brain.disparity(p) = wmean(model.env.rng(~isnan(val)),val(~isnan(val)));
    
end

brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
brain.image = image;

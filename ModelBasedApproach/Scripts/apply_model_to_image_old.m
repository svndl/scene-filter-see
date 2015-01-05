function [brain, image] = apply_model_to_image_old(model, im, depth)
%
% apply features of brain model to the image input to predict brain
% response

image.pixels    = single(im);
image.depth     = single(depth);

if numel(im) > 2                                % test images are fed as two pixels, so don't do conversions
    
    image = convert_image_to_rgc_response_old(image);   % simulate retinal processing
    image = convert_depth_to_disparity_old(image);      % simulate visual processing of depth
    %image.max = max(max(image.rgc));
else
    
    image.rgc       = image.pixels;
    image.max       = 1;
    image.disparity = image.depth;
    
end

    image.rgc = single(image.rgc);
    image.disparity = single(image.disparity);
    image.max = single(image.max);
        

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
        pixlum(p) = l;
    elseif lum < 0
        
        % concat biased and unbiased responses
        resp_cat = [model.gain.dark ; repmat(mean(model.gain.dark),size(model.gain.dark))];
        
        % concat luminance magnitude based weights
        l = abs(lum)/image.max;
        pixlum(p) = l;
        weight_cat = [repmat(l, size(model.gain.dark)); repmat(1 - l, size(model.gain.dark))];
        gain = wmean(resp_cat, weight_cat);
        
    elseif lum == 0
        
        gain = zeros(size(model.response));
        
    end
    g(p, :) = gain;
    % get response magnitude for each cell
    for n = 1:model.N
        
        cell_resp   = gain(n).*model.response(n,:);
        resp        = interp1(model.env.rng, cell_resp, disp);
        popresp(n)  = resp;

    end
    pr(p, :) = popresp;
    val = interp1(model.preferences, popresp, model.env.rng, 'cubic', 'extrap');
    
    brain.disparity(p) = wmean(model.env.rng(~isnan(val)),val(~isnan(val)));
    if (p == 50)
        load('live_+lum_gain_new.mat');
    end
end

brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
brain.image = image;


% function brain = apply_model_to_image_old(model, im, depth)
% 
% 
%     if numel(im) > 2                                % test images are fed as two pixels, so don't do conversions
%     
%         image.rgc = single(convert_image_to_rgc_response_old(im));   % simulate retinal processing
%         image.disparity = single(convert_depth_to_disparity(depth));      % simulate visual processing of depth
%         image.max = max(max(image.rgc));
%     else
%     
%         image.rgc       = im;
%         image.max       = 1;
%         image.disparity = depth;
%     
%     end
%     image.pixels = im;
%     brain_disparity = NaN*ones(size(image.disparity, 1)*size(image.disparity, 2), 1, 'single'); %initialize brain disparity response
%     
%     model.env.rng = single(model.env.rng);
%     model.gain.bright = single(model.gain.bright);
%     modelgain.dark = single(model.gain.dark);
%     model.response = single(model.response);
%     model.preferences = single(model.preferences);
%     
% for p = 1:numel(image.rgc)
%     
%     % grab luminance and disparity
%     %lum = image.rgc(p);
%     lum1 = image.rgc(p);
%     
%     disp = image.disparity(p);
%     
%     % clamp luminance to max value
%     lum = sign(lum1).*min([abs(lum1)/image.max 1]);
%     
%     % set cell population response bias based on relative luminance (bright
%     % or dark) and luminance magnitude (weak to strong)
%     
%     % gain for each cell is a weighted combination of the biased
%     % environmental gains and an unbiased set of gains
%     if lum > 0
%         
%         % concat biased and unbiased responses
%         %b = model.resp_bright;
%         
%         resp_cat = [model.gain.bright ; repmat(mean(model.gain.bright),size(model.gain.bright))];
% 
%         %resp_cat = [b ; repmat(mean(b), [size(b, 1), 1])];
%         % concat luminance magnitude based weights
%         l = lum;
%         weight_cat = [repmat(l, size(model.gain.bright)); repmat(1 - l, size(model.gain.bright))];
%         gain = wmean(resp_cat, weight_cat);
%     elseif lum < 0
%         
%         %d = model.resp_dark;
%         
%         resp_cat = [model.gain.dark ; repmat(mean(model.gain.dark),size(model.gain.dark))];
%         
%         % concat biased and unbiased responses
%         %resp_cat = [ d; repmat(mean(d), [size(d, 1), 1])];
%         % concat luminance magnitude based weights
%         l = abs(lum);
%         weight_cat = [repmat(l, size(model.gain.dark)); repmat(1 - l, size(model.gain.dark))];
%         gain = wmean(resp_cat, weight_cat);
%         
%     elseif lum == 0
%         gain = zeros(1, length(model.gain.bright));
%     end
%     
%     % get response magnitude for each cell
%     for n = 1:model.N
%         
%         cell_resp   = gain(n).*model.response(n,:);
%         resp        = interp1(model.env.rng, cell_resp, disp);
%         popresp(n)  = resp;
%     end
% 
%     val = interp1(model.preferences, popresp, model.env.rng);
%     try
%         brain_disparity(p) = wmean(model.env.rng(~isnan(val)),val(~isnan(val)));
%     catch err
%         %NaN??
%     end
% end
% brain.disparity = reshape(brain_disparity, size(image.disparity));
% brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
% brain.image = image;

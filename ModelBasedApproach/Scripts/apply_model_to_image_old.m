function brain = apply_model_to_image(model, im)


%initialize brain disparity response
brain.disparity = NaN*ones(size(im.disparity));

% what is the maximum luminance response in this image?
% used to scale other responses
max_lum = sum(abs(im.filter(:)));

for p = 1:numel(im.rgc)
    
    % grab luminance and disparity
    lum = im.rgc(p);
    disp = im.disparity(p);
    
    % clamp luminance to max value
    lum = sign(lum).*min([abs(lum) max_lum]);
    
    % set cell population response bias based on relative luminance (bright
    % or dark) and luminance magnitude (weak to strong)
    
    % gain for each cell is a weighted combination of the biased
    % environmental gains and an unbiased set of gains
    if lum > 0
        
        % concat biased and unbiased responses
        %b = model.resp_bright;
        
        resp_cat = [model.gain.bright ; repmat(mean(model.gain.bright),size(model.gain.bright))];

        %resp_cat = [b ; repmat(mean(b), [size(b, 1), 1])];
        % concat luminance magnitude based weights
        l = lum/max_lum;
        weight_cat = [repmat(l, size(model.gain.bright)); repmat(1 - l, size(model.gain.bright))];
        gain = wmean(resp_cat, weight_cat);
        
    elseif lum < 0
        
        %d = model.resp_dark;
        
        resp_cat = [model.gain.dark ; repmat(mean(model.gain.dark),size(model.gain.dark))];
        
        % concat biased and unbiased responses
        %resp_cat = [ d; repmat(mean(d), [size(d, 1), 1])];
        % concat luminance magnitude based weights
        l = abs(lum)/max_lum;
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

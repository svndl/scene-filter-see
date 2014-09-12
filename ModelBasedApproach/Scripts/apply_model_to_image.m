function brain = apply_model_to_image(m,im)


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
    if lum > 0;
        
        % concat biased and unbiased responses
        resp_cat = [m.g_br ; repmat(mean(m.g_br),size(m.g_br))];
        % concat luminance magnitude based weights
        weight_cat = [repmat(lum/max_lum,size(m.g_br)) ; repmat(1 - (lum/max_lum),size(m.g_br))];
        
        gain = wmean(resp_cat,weight_cat);
        
    elseif lum < 0;
        
        % concat biased and unbiased responses
        resp_cat = [m.g_dk ; repmat(mean(m.g_dk),size(m.g_dk))];
        % concat luminance magnitude based weights
        weight_cat = [repmat(abs(lum)/max_lum,size(m.g_dk)) ; repmat(1 - (abs(lum)/max_lum),size(m.g_dk))];
        
        gain = wmean(resp_cat,weight_cat);
        
    elseif lum == 0;
        
        gain = zeros(size(m.response));
        
    end
    
    % get response magnitude for each cell
    for n = 1:m.N
        
        cell_resp   = gain(n).*m.response(n,:);
        resp        = interp1(m.rng,cell_resp,disp);
        popresp(n)  = resp;
    end

    val = interp1(m.prefs_new,popresp,m.rng);

    brain.disparity(p) = wmean(m.rng(~isnan(val)),val(~isnan(val)));

end

brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));

function brain = calcModel(model, img, dmap, calctype)
    image.pixels = single(img);
    image.depth = single(dmap);    
    switch calctype
        case 'newRGC'
            image.rgc = convert_image_to_rgc_response(image.pixels);
            % simulate visual processing of depth
            image.disparity = convert_depth_to_disparity(image.depth);      
            image.max = single(max(max(image.rgc))); 
        case 'oldRGC'
            pad = [50 50];
            image.pixels = padarray(image.pixels, pad);
            image.depth = padarray(image.depth, pad);
            
            image = convert_image_to_rgc_response_old(image);   % simulate retinal processing
            image = convert_depth_to_disparity_old(image);      % simulate visual processing of depth
        otherwise
            %do nothing
    end
    
 
    %% allocate memory
    brain.disparity = NaN*ones(size(image.disparity));
    
    image.rgc = single(image.rgc);
    image.disparity = single(image.disparity);
    image.max = single(image.max);
        
    %% break image.rgc into small chunks
    
    luminance = image.rgc;
    clamped = abs(luminance)>image.max;
    max_l = sign(luminance)*image.max;
    luminance(clamped)= max_l(clamped);
    nlum = luminance/image.max;
    disp = image.disparity;
    %% num of blocks
    blockSize = 50;
    [nx, ny] = size(nlum);
    
    % small images don't need chunking 
    if (nx <= blockSize && ny <= blockSize)
        brain.disparity = calc_chunk(model, nlum, disp);
    else
        qRows = floor(nx / blockSize);
        rRows = rem(nx, blockSize);
    
        blockR = [blockSize * ones(1, qRows), rRows];
        qCols = floor(ny / blockSize);
        rCols = rem(ny, blockSize);
        blockC = [blockSize * ones(1, qCols), rCols];
        validR = blockR(blockR > 0);
        validC = blockC(blockC > 0);
        cellLum = mat2cell(nlum, validR, validC);
        cellDisp = mat2cell(disp, validR, validC);
    
        bdisp = cell(size(cellLum));
        %% apply model to each sub-segment of image.rgc
    
        for i = 1:length(validR)
            for j = 1:length(validC)
                bdisp{i, j} = calc_chunk(model, cellLum{i, j}, cellDisp{i, j});
            end
        end
        
        %% concat the results back together
        brain.disparity = cell2mat(bdisp);               
    end
    valid = ~isnan(brain.disparity);
    %brain volume = the difference berween 95% percentile and 5% percentile percieved disparity
    brain.volume = abs(quantile((brain.disparity(valid)),0.95) - quantile(brain.disparity(valid),0.05));
    brain.image = image;
end
%% apply model to image
function [brain_disparity] = calc_chunk2d(model, img, disp)
    
    %% pre-allocate memory, STORE AS SINGLE
    brain_disparity = NaN*ones(size(disp), 'single'); %initialize brain disparity response
    
    [nx, ny] = size(img);
    ng = length(model.gain.bright);
    nr = length(model.env.rng);

    gain_bright = zeros(nx*ny, ng, 'single');
    gain_dark = zeros(nx, ng, 'single');
    gain_tot = zeros(nx*ny, ng, 'single');
    gain_3d = zeros(nr, ng, nx*ny, 'single');
    cell_resp3d = zeros(nr, ng, nx*ny, 'single');
    pop_resp3d = zeros(nx, ng, nx*ny, 'single');
    pop_resp2d = zeros(nx*ny, ng, 'single');
    val2d = zeros(nr, nx, 'single');    
    g = [];
    % iterate through columns
    for j = 1:ny
        
        nlum = img(1:nx, j);
        disparity = disp(1:nx, j);
        bright  = nlum.*(nlum >0);
        dark = nlum.*(nlum<0);
    
        mgain_b = single(mean(model.gain.bright));
        mgain_d = single(mean(model.gain.dark));
    
        gain_bright = bright*model.gain.bright + repmat((nlum >0).*(1 - bright)*mgain_b, [1 ng]);
        gain_dark = abs(dark)*model.gain.dark + repmat((nlum < 0).*(1 - abs(dark))*mgain_d, [1 ng]);

        gain_tot = gain_bright + gain_dark;
        g = [g; gain_tot];
        gain_3d = repmat(reshape(gain_tot', [1 ng nx]),  [nr 1 1]);
        resp_3d = repmat(reshape(model.response', [nr ng 1]), [1 1 nx]);
        cell_resp3d = gain_3d.*resp_3d;
    
        if(sum(abs(disparity)>60) > 1)
            disp('disparity is over 60');
        end
        pop_resp3d = interp1(model.env.rng, cell_resp3d, disparity);
     
        [mi, mj, ~] = size(pop_resp3d);
        midx = cumsum([1:mi:mi*mj; 1 + mi*mj*ones(mi - 1, mj)]);
        
        pop_resp2d = pop_resp3d(midx);       
        try
            val2d = interp1(model.preferences, pop_resp2d', model.env.rng);
            % we'll replace NaNs with zeros for the following reason:
            % in case of p[ixel-by pixel version,  they're not contributing to 
            % wmean value, because we use ~isnan. If all elements in single
            % col are NaNs, result will be zero.
            cleaned = val2d; 
            cleaned(isnan(cleaned)) = 0;
            new_val = reshape(cleaned, size(val2d));
            bd = wmean(repmat(model.env.rng', [1 nx]), new_val);
            brain_disparity(:, j) = reshape(bd, [1, nx]);       
        catch err
            disp('Error interpolating');
        end
    end
    %clear gain_3d;
    %clear cell_resp3d;
    %clear pop_resp3d;
end
function [brain_disparity] = calc_chunk(model, img, disp)
    bd = NaN*ones(numel(img), 1);
    imc = img(:);
    dc = disp(:);
    mean_b = single(mean(model.gain.bright));
    mb = repmat(mean_b, [1 model.N]);
    mean_d = single(mean(model.gain.dark));
    md = repmat(mean_d, [1 model.N]);
    resp_bright = [model.gain.bright ; mb];
    resp_dark = [model.gain.dark; md];
    for p = 1:numel(imc)
    
        % grab luminance and disparity
        lum = imc(p);
        d = dc(p);
      
        % set cell population response bias based on relative luminance (bright
        % or dark) and luminance magnitude (weak to strong)
    
        % gain for each cell is a weighted combination of the biased
        % environmental gains and an unbiased set of gains
        
        % default gain size
        gain = zeros(1, model.N);
        resp_cat = (lum > 0)*resp_bright + (lum < 0)*resp_dark;

        % concat luminance magnitude based weights
        weight_cat = [repmat(abs(lum), [1 model.N]); repmat(1 - abs(lum), [1 model.N])];
        gain = wmean(resp_cat, weight_cat);

        cell_resp   = repmat(gain', [1 length(model.env.rng)]).*model.response;
      
        popresp     = interp1(model.env.rng, cell_resp', d);
        try
            val = interp1(model.preferences, popresp, model.env.rng);
            bd(p) = wmean(model.env.rng(~isnan(val)),val(~isnan(val)));
        catch err
            %do nothing
        end    
    end
    brain_disparity = reshape(bd, [size(img, 1) size(img, 2)]);
end

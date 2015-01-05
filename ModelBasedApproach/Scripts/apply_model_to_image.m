function brain = apply_model_to_image(model, img, dmap)
%function calculates model of visual depth perception
  

    image.pixels = single(img);
    image.depth = single(dmap);
    if numel(img) > 2                                
        % simulate retinal processing
        image.rgc = convert_image_to_rgc_response(image.pixels);
        % simulate visual processing of depth
        image.disparity = convert_depth_to_disparity(image.depth);      
        image.max = single(max(max(image.rgc)));
    else
        % test images are fed as two pixels, so don't do conversions                
        image.rgc       = single(img);
        image.max       = 1;
        image.disparity = single(dmap);
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
    
    brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
    brain.image = image;
end

function brain_disparity = calc_chunk(model, img, disp)
    
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
    val2d = zeros(nr, nx*ny, 'single');
    
    model.env.rng = single(model.env.rng);
    model.gain.bright = single(model.gain.bright);
    modelgain.dark = single(model.gain.dark);
    model.response = single(model.response);
    model.preferences = single(model.preferences);
    
    % iterate through columns
    for j = 1:ny
        
        nlum = img(:, j);
        disparity = disp(:, j);
        bright  = nlum.*(nlum >0);
        dark = nlum.*(nlum<0);
    
        mgain_b = mean(model.gain.bright);
        mgain_d = mean(model.gain.dark);
    
        gain_bright = bright(:)*model.gain.bright + repmat((nlum >0).*(1 - bright)*mgain_b, [1 ng]);
        gain_dark = abs(dark(:))*model.gain.dark + repmat((nlum < 0).*(1 - abs(dark))*mgain_d, [1 ng]);

        gain_tot = gain_bright + gain_dark;
        gain_3d = repmat(reshape(gain_tot', [1 ng nx]),  [nr 1 1]);
        resp_3d = repmat(reshape(model.response', [nr ng 1]), [1 1 nx]);
        cell_resp3d = gain_3d.*resp_3d;
    
        pop_resp3d = interp1(model.env.rng, cell_resp3d, disparity);
    
    
        [mi, mj, ~] = size(pop_resp3d);
        midx = cumsum([1:mi:mi*mj; mi*mj*ones(mi - 1, mj)]);
        pop_resp2d = pop_resp3d(midx);
    
    
        val2d = interp1(model.preferences, pop_resp2d', model.env.rng);    
        val2d(isnan(val2d)) = 0;
        bd = wmean(repmat(model.env.rng', [1 nx]), val2d);
        brain_disparity(:, j) = reshape(bd, [1, nx]);
    end
    clear gain_3d;
    clear cell_resp3d;
    clear pop_resp3d;
end

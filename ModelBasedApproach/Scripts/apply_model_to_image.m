function brain = apply_model_to_image(model, image)


    if numel(image) > 2                                % test images are fed as two pixels, so don't do conversions
    
        im.rgc = convert_image_to_rgc_response(image.pixels);   % simulate retinal processing
        im.depth = convert_depth_to_disparity(image.depth);      % simulate visual processing of depth
        im.max = max(max(image.pixels));
    else
    
        im.rgc       = image.pixels;
        im.max       = 1;
        im.disparity = image.depth;
    
    end


    brain.disparity = NaN*ones(size(image.disparity)); %initialize brain disparity response

    [nx, ny] = size(im.rgc);
    ng = length(model.gain.bright);
    nr = length(model.env.rng);
    
    
    luminance = im.rgc(:);
    disparity = im.disparity(:);
    clamped = abs(luminance)>image.max;
    max_l = sign(luminance)*image.max;
    luminance(clamped)= max_l(clamped);
    nlum = luminance/im.max;
    bright  = nlum.*(nlum >0);
    dark = nlum.*(nlum<0);
    
    mgain_b = mean(model.gain.bright);
    mgain_d = mean(model.gain.dark);
    
    gain_bright = bright(:)*model.gain.bright + repmat((nlum >0).*(1 - bright)*mgain_b, [1 ng]);
    gain_dark = abs(dark(:))*model.gain.bright + repmat((nlum<0).*(1 - abs(dark))*mgain_d, [1 ng]);

    gain_tot = gain_bright + gain_dark;
    gain_3d = repmat(reshape(gain_tot', [1 ng nx*ny]),  [nr 1 1]);
    resp_3d = repmat(reshape(model.response', [nr ng 1]), [1 1 nx*ny]);
    cell_resp3d = gain_3d.*resp_3d;
    
    pop_resp3d = interp1(model.env.rng, cell_resp3d, disparity);
    
    [mi, mj, ~] = size(pop_resp3d);
    midx = cumsum([1:mi:mi*mj; mi*mj*ones(mi - 1, mj)]);
    pop_resp2d = pop_resp3d(midx);
    
    val2d = interp1(model.preferences, pop_resp2d', model.env.rng);    
    val2d(isnan(val2d)) = 0;
    bd = wmean(repmat(model.env.rng', [1 nx*ny]), val2d);
    brain.disparity = reshape(bd, [nx, ny]);
    
    brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
    brain.image = image;
    
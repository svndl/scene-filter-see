function im_rgc = convert_image_to_rgc_response(im)

% set up simulated RGC receptive fields


    %convert SIGMA in to arcminutes, using study viewing distance, screen etc
    %Cooper et al paper

    arcmin_px = 1.4;
    sigma_on = 1.4/arcmin_px;
    sigma_off = 1.1/arcmin_px;
    
    rgc_on = calc_rgc(im, sigma_on);
    rgc_off = calc_rgc(im, sigma_off);
    im_rgc = rgc_on.*(rgc_on > 0) + rgc_off.*(rgc_off < 0);
end

function im = calc_rgc(img, sigma)

    SUR_SCALE = 6;        
    ADA_SCALE = 6;
    
    % make 2-D RGC filters
    fwid = 140;                                                   
    frange = -fwid:fwid;                                          
    
    padded = padarray(img, [fwid fwid]);

    cen = make_gaussian_rf(frange, sigma);                   % central gaussian
    sur = make_gaussian_rf(frange, SUR_SCALE*sigma);         % surround gaussian
    ada = make_gaussian_rf(frange, ADA_SCALE*sigma);         % adaptation gaussian, equal to surround


    %% convolve image with filters
    imcen = conv2(padded, cen, 'same');                        
    imsur = conv2(padded, sur, 'same');                         
    imad = conv2(padded, ada, 'same');                         

    %% keep the pix distribution shape/mean, stretch it to [-1, 1];
    rgc = (imcen - imsur)./imad;                                  
    rgc(rgc<-1) = -1;
    rgc(rgc>1) = 1;
    
    %% crop edges by 1/2 filter width
    im = rgc(fwid + 1:end - fwid, fwid + 1:end - fwid);                  
end

%% TODO perform freq analysis, cut out below 5%/above 95%
function cropped = crop_by_freq(im)
    f_im = fft2(im);
    mag = abs(f_im);
end


function im = convert_image_to_rgc_response(im)

% set up simulated RGC receptive fields
% NOTE: Should add step to convert SIGMA in to arcminutes, using study
% viewing distance, screen etc


    % stddev of central 2D Gaussian in pixels
    % from Cooper et al paper
    arcmin_px = 1.4;
    sigma_on = 1.4/arcmin_px;
    sigma_off = 1.1/arcmin_px;
    
    rgc_on = calc_rgc(im, sigma_on);
    rgc_off = calc_rgc(im, sigma_off);
    im = rgc_on.rgc.*(rgc_on.rgc > 0) - rgc_off.rgc.*(rgc_off.rgc < 0);
    
end

function im = calc_rgc(img, sigma)

    SUR_SCALE = 6;        
    ADA_SCALE = 6;

    %%% make 2-D RGC filters
    fwid = 20;                                                   % 1/2 width of filter matrix
    frange = -fwid:fwid;                                           % filter range in pixels

    cen = make_gaussian_rf(frange, sigma);                   % central gaussian
    sur = make_gaussian_rf(frange, SUR_SCALE*sigma);         % surround gaussian
    ada = make_gaussian_rf(frange, ADA_SCALE*sigma);         % adaptation gaussian, equal to surround


    %%% convolve image with filters
    imcen = conv2(img, cen, 'same');                         % center filtered
    imsur = conv2(img, sur, 'same');                         % surround filtered
    imad = conv2(img, ada, 'same');                         % adaptation filter for divisive normalization, same as surround

    rgc = (imcen - imsur)./imad;                                  
    cropped = rgc(fwid + 1:end - fwid, fwid + 1:end - fwid);              % crop edges by 1/2 filter width
    im.rgc  = (2*(cropped - min(cropped(:)))/range(cropped(:))) - 1;

    im.pixels = im.rgc(fwid + 1:end - fwid,fwid + 1:end - fwid);              % crop edges by 1/2 filter width
%     im.depth  = im.depth(fwid + 1:end - fwid,fwid + 1:end - fwid);              % crop edges by 1/2 filter width
% 
% 
%     im.filter   = cen - sur;
%     im.max      = sum(abs(im.filter(:))); % maximum luminance response in this image, used to scale other responses
end

%% perform freq analysis, cut out below 5%/above 95%
function cropped = crop_by_freq(im)
    f_im = fft2(im);
    mag = abs(f_im);

end


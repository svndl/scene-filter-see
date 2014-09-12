function im = convert_image_to_rgc_response(im)

% set up simulated RGC receptive fields
% NOTE: Should add step to convert SIGMA in to arcminutes, using study
% viewing distance, screen etc

SIGMA       = 2;        % stddev of central 2D Gaussian in pixels
SUR_SCALE   = 2;        % scale factor for surround 2D Gaussian
ADA_SCALE   = 2;

%%% make 2-D RGC filters
fwid    = 20;                                                   % 1/2 width of filter matrix
frange  = -fwid:fwid;                                           % filter range in pixels

cen     = make_gaussian_rf(frange,SIGMA);                   % central gaussian
sur     = make_gaussian_rf(frange,SUR_SCALE*SIGMA);         % surround gaussian
ada     = make_gaussian_rf(frange,ADA_SCALE*SIGMA);         % adaptation gaussian, equal to surround


%%% convolve image with filters
imcen   = conv2( im.pixels, cen, 'same' );                         % center filtered
imsur   = conv2( im.pixels, sur, 'same' );                         % surround filtered
imad    = conv2( im.pixels, ada, 'same' );                         % adaptation filter for divisive normalization, same as surround

im.rgc      = (imcen - imsur)./imad;                            % combine center - surround, and divisive normalization      
im.rgc      = im.rgc(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
im.rgc      = (2*(im.rgc - min(im.rgc(:)))/range(im.rgc(:))) - 1;
im.pixels      = im.pixels(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
im.depth       = im.depth(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width


im.filter = cen - sur;

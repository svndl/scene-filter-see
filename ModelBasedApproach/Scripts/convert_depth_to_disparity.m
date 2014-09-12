function im = convert_depth_to_disparity(im)


%%% make 2-D mean depth filter
fwid    = 30;                                                   % 1/2 width of filter matrix
frange  = -fwid:fwid;                                           % filter range in pixels
im.depthfilter     = make_gaussian_rf(frange,10);

if sum(im.depth) > 0
    
    % add Nancov for data with Nans
    im.fixations = conv2( im.depth, im.depthfilter, 'same' );
    
    im.fixations = im.fixations(fwid:end-fwid-1,fwid:end-fwid-1);
    im.depth = im.depth(fwid:end-fwid-1,fwid:end-fwid-1);
    
    im.disparity = 60.* (180/pi).* 0.064.* ( (1./im.fixations) - (1./im.depth) );
    
    im.rgc      = im.rgc(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
    im.pixels      = im.pixels(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
    im.depth       = im.depth(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
    
else
    
    zeromat = zeros(size(im.rgc));
    
    im.rgc      = im.rgc(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
    im.pixels      = im.pixels(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width
    im.depth       = im.depth(fwid:end-fwid-1,fwid:end-fwid-1);              % crop edges by 1/2 filter width

    im.fixations = zeromat(fwid:end-fwid-1,fwid:end-fwid-1);    
    im.disparity = zeromat(fwid:end-fwid-1,fwid:end-fwid-1);  
    
end

function d = cleanDepthMap(dmap, blurOption)
% clean the depthmap : remove values outside the 1%-99% range
% and remove NaNs. Blur Option is for UT images only, used
% to get rid of pixels after correction 

    if(nargin < 2)
        blurOption = 0; 
    end
    
    dmap_copy = dmap;
    dmap_valid = inpaint_nans(dmap_copy, 2);
    
    q99 = quantile(dmap_valid(:), 0.99);
    q01 = quantile(dmap_valid(:), 0.01);

    dmap_valid(dmap_valid > q99) = q99;
    dmap_valid(dmap_valid < q01) = q01;
    
    d = dmap_valid;
    if (blurOption)
        gauss = fspecial('gauss', 100, 5);
        d = conv2(d, gauss, 'same');
    end
end
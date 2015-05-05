function image = model_RGCResponse(varargin)

    img = varargin{1};
    dmap = varargin{2};
    appix = varargin{3};    
    rgctype = varargin{4};
    
    image.pixels = single(img);
    image.depth = single(dmap);
    
    % simulate retinal processing
    switch rgctype
        case 'complex'
        %complexRGC
            image.rgc = model_calcComplexRGC(image.pixels, appix);
        case 'simple'
            image.rgc = model_calcRGC(image.pixels, appix);
        otherwise
            image.rgc = model_calcRGC(image.pixels, appix);
    end
    
    % simulate visual processing of depth
    image.disparity = model_calcDisparity(image.depth);      
    image.max = single(max(max(image.rgc)));
end
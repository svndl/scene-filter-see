function image = edit_manipulateScene(loadpath, flag)
    
    % FLAGS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % tp = negative luminance/depth correlation
    % ap = positive luminance/depth correlation
    % Functions works 
    

    try
        image = load_readScene(loadpath);
    catch
        err_string = ['Error loading ' loadpath];
        disp(err_string);
        return;
    end
  
    bslash_idx = strfind(loadpath, filesep); 
    image.name = loadpath(bslash_idx(end) + 1:end);
    image.flag = flag;
    
    imRGB = image.imRGB;
    imZ = image.imZ;
    
    %reverse the depth map for degradation
    if strcmp(flag, 'ap')
        imZ = max(imZ(:)) - imZ;
    end

    imHSV = rgb2hsv(imRGB);

    %get value channel
    imV = imHSV(:,:,3);
    
    %% manipulation magic
    
    medianZ = quantile(imZ(:), 0.5);
    maxZ = max(imZ(:));
    
    
    imZdiff = imZ - medianZ;
    far = ones(size(imZdiff)).*(sign(imZdiff) == 1);    
    %near = ones(size(imZdiff)).*(sign(imZdiff) == -1);
    
    far_norm = imZdiff.*far/(maxZ - medianZ);    
    imS =  ones(size(imZdiff)) - 0.75*far_norm;
    imVnew = imS.*imV;
    
    
    imVnew(imVnew > 1) = 1;
    imVnew(imVnew < 0) = 0;
    
    %%reconstruct image

    %recon color image
    imHSVnew = imHSV;
    imHSVnew(:, :, 3) = imVnew;
    image.imRGBnew = hsv2rgb(imHSVnew);
end
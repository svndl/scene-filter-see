function cleaned = manipulateLuminance(loadpath, flag)

    % This function takes an image directory and algorithm flag as input, and
    % applies the depth enhancement algorithm to the image contained in that
    % directory. The directory must contain both the image and depth maps in a
    % format handled by loadImages. The directory also must contain a stereo
    % partner for the image, which will be loaded and saved to ensure that both
    % images in the stereopair are in matching formats, unless this step has
    % already been completed with a previous function call. Note that the second 
    % image for the LiveColor+3D database is identical to the main image. A 
    % second image with disparity will be created manually in Photoshop.
    % Currently the function can handle images from the 
    % Middlebury Stereo 
    % (http://vision.middlebury.edu/stereo/data/) and 
    % LiveColor+3D
    % (http://live.ece.utexas.edu/research/3dnss/live_color_plus_3d.html)
    % databases.
    %
    % example call:
    %       manipulateLuminance('mb_aloe','tp')
    %
    %
    % Emily Cooper, Stanford University 2014
    %
    % FLAGS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % tp = negative luminance/depth correlation
    % ap = positive luminance/depth correlation


    % SET UP OUTPUT DIRECTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    found = strfind(loadpath, '/');
    dir_up = loadpath(1:found(end - 1) - 1); %/moving up two folders to the Images level 
    dir_name = loadpath(found(end) + 1:end);

    switch flag
        case 'tp'
            savepath = [dir_up '/TowardsThePrior/' dir_name '/'];
        case 'ap'
            savepath = [dir_up '/AgainstThePrior/' dir_name '/'];
        otherwise
            error('unknown manipulation flag');
    end
        
    if ~exist(savepath, 'dir')
        mkdir(savepath);
    end
    
    
    % SETUP STEPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %add path to helpful functions
    %addpath('../../../HelperFunctions/');

    %show images and summaries in matlab figures
    showResults = 0;
    
    % imRGB is the image to be enhanced, imLeftRGB is the other image in the
    % stereo pair, which is really just carried through the function and not
    % enhanced (because it has no associated depth map). imZ and dispmap are
    % the depth map and disparity maps. median_pixel_disparity is
    % the average disparity from the dispmap, which is used to decide how to
    % crop the image
    
    image = struct('name', dir_name, 'loadpath', loadpath, 'savepath', savepath,...
        'imRGB', 0, 'imRGBLeft', 0, 'imZ', 0, 'imZOrig', 0, 'dispmap', 0,...
        'median_pixel_disparity', 0, 'imRGBnew', 0, 'imV', 0,...
        'imVnew', 0, 'imS', 0, 'flag', flag);
    
    
    %[imRGB, imLeftRGB, imZ, dispmap] = loadImages(path);
    loaded = loadImages(loadpath, image);
    % crop images and depth maps to be square
    %[imRGB, imLeftRGB, imZOrig, dispmap] = cropImages(imRGB, imLeftRGB,imZ,dispmap,median_pixel_disparity);
    
    cropped = cropImages(loaded);
    %linearize to undo PNG gamma encoding of 1/2.2 on image to be manipulated
    %(will be restored at the end of function)
    cropped.imRGB = cropped.imRGB.^(2.2);

    % set dmap and disparity map ranges to .01 and .99 quantiles to get rid of outliers
    % then inpaint NaN values
    cleaned = cleanDepth(cropped);

    %invert depth map if your created an "Against the Prior" image
    if strcmp(cleaned.flag, 'ap')
        cleaned.imZ = max(cleaned.imZ(:)) - cleaned.imZ;
    end

    %depth map anchor values for normalization
    medianZ = median(cleaned.imZ(:));
    maxZ = max(cleaned.imZ(:));

    % convet RGB to HSV
    imHSV = rgb2hsv(cleaned.imRGB);

    %get value channel
    cleaned.imV = imHSV(:,:,3);

    %initialize matrices for enhancement calculations
    [xdim, ydim, ~] = size(cleaned.imRGB);
    %imM = zeros(xdim, ydim);
    cleaned.imS = zeros(xdim ,ydim);
    cleaned.imVnew = zeros(xdim, ydim);


    % VALUE MANIPULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for each pixel
    for x = 1:xdim
        for y = 1:ydim
            cleaned.imS(x, y) = determineSlope(cleaned.imZ(x,y), medianZ, maxZ);
            %REMAP INTENSITY
            cleaned.imVnew(x, y) = cleaned.imS(x, y)*cleaned.imV(x, y);
        end
    end

    % IMAGE RECONSTRUCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if sum(cleaned.imVnew(:) > 1) > 0 || sum(cleaned.imVnew(:) < 0) > 0
        cleaned.imVnew(cleaned.imVnew > 1) = 1;
        cleaned.imVnew(cleaned.imVnew < 0) = 0;
        warning('pixel values were clipped');
    end

    %recon color image
    imHSVnew = imHSV;
    imHSVnew(:, :, 3) = cleaned.imVnew;
    cleaned.imRGBnew = hsv2rgb(imHSVnew);

    %reapply PNG gamma encoding
    cleaned.imRGB = cleaned.imRGB.^(1/2.2);
    cleaned.imRGBnew = cleaned.imRGBnew.^(1/2.2);

    %show results
    if(showResults)
        figure; imagesc(imZ);
        figure; imshow(imV);
        figure; imshow(imVnew);
        figure; imshow(imRGB);
        figure; imshow(imRGBnew);
    end

    %restore depth map if it was inverted
    if strcmp(cleaned.flag, 'ap')
        cleaned.imZ = maxZ - cleaned.imZ;
    end
end










%load images
function image = loadImages(path, image)

    % Note that Middlebury depth is in disparity units, so we load disparity
    % and convert to depth. LiveColor+3D is in meters, so we load depth and
    % convert to disparity. Disparity maps are not used for enhancement, but
    % might be interesting for later. The disparity map is also used to
    % synthesize stereo for the Live3D images, which don't come with a stereo
    % pair. So we load in a dummy left eye image for these, which is actually
    % just identical to the right eye image.
    
    %dirname is a full path, we'll need to extract the filename
    found = strfind(path, '/');
    dir_name = path(found(end) + 1:end);
    db_type = strtok(dir_name, '_');
    
    
    try
        switch db_type
            case 'mb'
                
                filename = strcat(path, '/', dir_name);
                %load files
                image.imRGB = double(imread(strcat(filename, 'right.png')))/255;
                image.imRGBLeft = double(imread(strcat(filename, 'left.png')))/255;
    
                %note that middlebury depth is in disparity units, so we have to convert it
                dispmap     = double(imread(strcat(filename, 'right_depth.png'))); 
                %This will be used to set zero disparity point in stereogram
                %presentation:
                %average disparity in pixels, divide by two to get shift for each image,
                %divide by 4 because l/r images are 1/4 the distance appart as disparity maps
                image.median_pixel_disparity = round(median((dispmap(~isnan(dispmap)))/2)/4);
 
                %deal invalid values
                dispmap(dispmap == 0) = NaN;
    
                %convert disparity to depth
                mb_fl_pix       = 3740; %from middlebury documentation
                mb_baseline_mm  = 160;
                
                %this offset value is provided to correct disparities
                fileID = fopen(strcat(path, '/dmin.txt'));
                dmin =  fscanf(fileID, '%f');
                fclose(fileID);
                dmap = (mb_fl_pix*mb_baseline_mm)./(dispmap + dmin);
                image.imZ = dmap./1000; % convert to meters
                image.imZOrig = image.imZ;
    
                %divide disparity by 4 because l/r images are 1/4 the distance appart as disparity maps 
                image.dispmap = dispmap./4;
    
            case 'live'
                
                %expected full filename and path
                filename = strcat(path, '/', dir_name);
                
                image.imRGB = double(imread(strcat(filename, 'right.png')))/255;
                image.imRGBLeft = image.imRGB;
        
                %Assuming that depth map var could be namned anything ...
                
                s = load(strcat(filename, 'right_range.mat'));
                sf = fieldnames(s);
                image.imZ = s.(sf{1});

                %deal with invalid values
                image.imZ(image.imZ == 0)     = NaN;
    
                %convert depth to diopters, which are proportionate to disparity
                image.dispmap = 1./image.imZ;
                image.imZOrig = image.imZ;
    
                %this will be set later automatically in photoshop
                image.median_pixel_disparity = 0;
                
            case 'ut'
                
                findnumber = strfind(dir_name, '_');
                filenumber = dir_name(findnumber(end) + 1:end);
                
                image.imRGB = double(imread([path '/' 'rImage' filenumber 'V.png']))/255;
                image.imRGBLeft = double(imread([path '/' 'lImage' filenumber 'V.png']))/255;
    
                depth_info = load([path '/' 'rRange' filenumber '.mat']);
                image.imZ = double(depth_info.range);
       
                %convert depth to diopters, which are proportionate to disparity
                image.dispmap = 1./image.imZ;
                image.imZOrig = image.imZ;
                image.median_pixel_disparity = 0;
            otherwise
        end
    catch err
        disp(strcat('LoadImages:Error loading ', path));
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
    
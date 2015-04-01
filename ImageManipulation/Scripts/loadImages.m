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
    found = strfind(path, filesep);
    dir_name = path(found(end) + 1:end);
    db_type = strtok(dir_name, '_');
    
    
    try
        switch db_type
            case 'mb'
                
                filename = fullfile(path, dir_name);
                %load files
                %% MB files #1
                
                left{1} = [filename, 'left.png'];
                right{1} = [filename, 'right.png'];
                depth1 = [filename, 'right_depth.png'];
                dmin1 = fullfile(path, 'dmin.txt');
                
                %% MB files new
                left{2} = fullfile(path, 'im0.png');
                right{2} = fullfile(path, 'im1.png');
                depth2 = fullfile(path, 'disp1.pfm');
                dmin2 = fullfile(path, 'calib.txt'); 
                
                %%figure out what set of MB to load
                l_idx = 2*(~exist(left{1}, 'file')) + (~exist(left{2}, 'file'));
                r_idx = 2*(~exist(right{1}, 'file')) + (~exist(right{2}, 'file')); 
                
                image.imRGB = double(imread(right{r_idx}))/(2^8 - 1);
                image.imRGBLeft = double(imread(left{l_idx}))/(2^8 - 1);
    
                %note that middlebury depth is in disparity units, so we have to convert it
                %%read depth 
                if (exist(depth1, 'file'))                
                    dispmap = double(imread(depth1));
                    
                    mb_fl_pix       = 3740; %from middlebury documentation
                    mb_baseline_mm  = 160;
                
                    fp = fopen(dmin1);
                    dmin =  fscanf(fp, '%f');
                    fclose(fp);
                %% read new mb's depth map and calibration info    
                elseif (exist(depth2, 'file'))
                    dispmap = double(pfmread(depth2));
                    fp = fopen(dmin2);
                    ncam = 2;
                    camx = 3;
                    camy = 3;
                    cam = zeros(ncam, camx*camy);
                    tline = fgets(fp);
                    while (ischar(tline))
                        datatype = strtok(tline, '=');
                        switch (datatype)
                            case 'vmin'
                                dmin = sscanf(tline, 'vmin= %f');
                            case 'vmax'
                                dmax = sscanf(tline, 'vmax= %f');
                            case 'baseline'
                                mb_baseline_mm = sscanf(tline, 'baseline= %f');
                            case {'cam0', 'cam1'}
                                [text, strvalue] = strtok(tline, '[');
                                num = str2double(text(end - 1)) + 1;
                                cam(num, :) = cell2mat(textscan((strvalue(2:end-2)), ...
                                    '%f %f %f; %f %f %f; %f %f %f'));
                            otherwise
                        end
                        tline = fgets(fp);
                    end
                    fclose(fp);
                    %This will be used to set zero disparity point in stereogram
                    %presentation:
                    %average disparity in pixels, divide by two to get shift for each image,
                    %divide by 4 because l/r images are 1/4 the distance appart as disparity maps
                    image.median_pixel_disparity = round(median((dispmap(~isinf(dispmap)))/2)/4);
                    dispmap(isinf(dispmap)) = NaN;
                    mb_fl_pix = sum(cam(:, 1))/2;
                    
                else
                    fprintf('No depth map, skipping the file');
                    return;
                end
                
                %deal invalid values
                dispmap(dispmap == 0) = NaN;                                    

    
                %convert disparity to depth
                dmap = (mb_fl_pix*mb_baseline_mm)./(dispmap + dmin);
                image.imZ = dmap./1000; % convert to meters
                image.imZOrig = image.imZ;
    
                %divide disparity by 4 because l/r images are 1/4 the distance appart as disparity maps 
                image.dispmap = dispmap./4;
                %pixel per degree
                p = 0.5; 
                %arcmin per pixel
                theta = 2*atan2(p, mb_fl_pix)*(180/pi);
                
                %pixel per degree
                image.pix_per_deg = theta;
            case 'live'
                
                %expected full filename and path
                filename = fullfile(path, dir_name);
                
                image.imRGB = double(imread([filename 'right.png']))/255;
                image.imRGBLeft = image.imRGB;
        
                %Assuming that depth map var could be namned anything ...
                
                s = load([filename 'right_range.mat']);
                sf = fieldnames(s);
                image.imZ = s.(sf{1});

                %deal with invalid values
                image.imZ(image.imZ == 0)     = NaN;
    
                %convert depth to diopters, which are proportionate to disparity
                image.dispmap = 1./image.imZ;
                image.imZOrig = image.imZ;
    
                %this will be set later automatically in photoshop
                image.median_pixel_disparity = 0;
                
                %camera details
                d700_sensor = [36 23.9];
                               
                f = 20; %mm
                %pix/mm
                %camera was rotated and pictures were downsampled
                downsampled_size = [2128, 1416];
                pmm = d700_sensor(2)/downsampled_size(2);
                
                %arcmin per pix
                theta = 2*atan2(pmm/2, f)*(180/pi);
                %pix per degree
                image.pix_per_deg = 60/theta;
               
            case 'ut'
                
                findnumber = strfind(dir_name, '_');
                filenumber = dir_name(findnumber(end) + 1:end);
                
                image.imRGB = double(imread(fullfile(path, ['rImage' filenumber 'V.png'])))/(2^8 - 1);
                image.imRGBLeft = double(imread(fullfile(path, ['lImage' filenumber 'V.png'])))/(2^8 - 1);
    
                depth_info = load(fullfile(path, ['rRange' filenumber '.mat']));
                image.imZ = double(depth_info.range);
       
                %convert depth to diopters, which are proportionate to disparity
                image.dispmap = 1./image.imZ;
                image.imZOrig = image.imZ;
                image.median_pixel_disparity = 0;
                 %camera details
                d700_sensor = [36 23.9];
                
                f = 20; %mm
                %pix/mm
                pmm = d700_sensor(1)/size(image.imRGB, 1);
                %arcmin per pix
                theta = 2*atan2(pmm/2, f)*(180/pi);
                %pix per degree
                image.pix_per_deg = theta;
               
            otherwise
        end
    catch err
        disp('LoadImages:Error');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
    

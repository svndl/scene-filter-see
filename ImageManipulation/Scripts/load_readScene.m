function image = load_readScene(path)
    
    found = strfind(path, filesep);
    dir_name = path(found(end) + 1:end);
    db_type = strtok(dir_name, '_');
    
    try
        switch db_type
            case 'mb'
                image = loadMB(path);
                image.imZ = edit_cleanDepth(image.zleft); 
                image.imRGB = image.left;
            case 'live'
               image = loadLive(path);
               image.imZ = edit_cleanDepth(image.zright);
               image.imRGB = image.right;
              
            case {'ut','utc'}
               image = loadUT(path);
               image.imZ = edit_cleanDepth(image.zleft, 1); 
               image.imRGB = image.left;
            otherwise
        end
    catch err
        disp('LoadImages:Error');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
end
%% LOAD MB
function image = loadMB(path)
    % first -- left, second -- right
    filenames_new = {'im0.png', 'im1.png'};
    filenames_old = {'view1.png', 'view5.png'};
    disp_new = {'disp0.pfm', 'disp1.pfm'};    
    disp_old = {'disp1.png', 'disp5.png'};
    
    if (exist([path filesep disp_new{1}], 'file'))
        db_type = 'new';
    else
        db_type = 'old';
    end
    
    switch db_type
        case 'old'
            left_im = fullfile(path, filesep, filenames_old{1});
            left_disp = fullfile(path, disp_old{1});
            right_im = fullfile(path, filenames_old{2});
            right_disp = fullfile(path, disp_old{2});
            
            dmap_left = double(imread(left_disp));
            dmap_right = double(imread(right_disp));
            
            mb_fl_pix       = 3740; %from middlebury documentation
            mb_baseline_mm  = 160;
                
            fp = fopen(fullfile(path, 'dmin.txt'));
            dmin =  fscanf(fp, '%f');
            fclose(fp);            
        case 'new'
            left_im = fullfile(path, filenames_new{1});
            left_disp = fullfile(path, disp_new{1});
            right_im = fullfile(path, filenames_new{2});
            right_disp = fullfile(path, disp_new{2});
            
            
            dmap_left = double(pfmread(left_disp));
            dmap_right = double(pfmread(right_disp));
            
            fp = fopen(fullfile(path, 'calib.txt'));
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
            mb_fl_pix = sum(cam(:, 1))/2;
            
        otherwise
    end
    
    %% MB images are gamma-corrected, stored as 8 bit PNG!
    image.right = (double(imread(right_im))/(2^8 - 1)).^2.2;
    image.left = (double(imread(left_im))/(2^8 - 1)).^2.2;
    
    %% Convert disparity to depth
    mpdL = round(median((dmap_left(~isinf(dmap_left)))/2)/4);
    mpdR = round(median((dmap_right(~isinf(dmap_right)))/2)/4);
    
    image.mpd = mpdL;
    
    dmap_left(isinf(dmap_left)) = NaN;
    dmap_right(isinf(dmap_right)) = NaN;

    dmap_left(dmap_left == 0) = NaN;                                    
    dmap_right(dmap_right == 0) = NaN;                                    

    %convert disparity to depth -> convert to meters
    dmap_left = (mb_fl_pix*mb_baseline_mm)./(dmap_left + dmin);
    dmap_right = (mb_fl_pix*mb_baseline_mm)./(dmap_right + dmin);
    
    image.zleft = dmap_left./1000;
    image.zright = dmap_right./1000;
    
    %pixel per degree
    p = 0.5; 
    %arcmin per pixel
    theta = 2*atan2(p, mb_fl_pix)*(180/pi);                
    %pixel per degree
    image.pix_per_deg = theta;
end
%% Load LIVE
function image  = loadLive(path)
    %expected full filename and path
    [~, name] = fileparts(path);
    new_path = fullfile(path, name);
    
    %% LIVE images are gamma-corrected, stored as 8 bit PNG! 
    image.right = (double(imread([new_path 'right.png']))/(2^8 - 1)).^2.2;
    
    image.left = image.right;
    s = load([new_path 'right_range.mat']);
    sf = fieldnames(s);
    dmap = s.(sf{1});
    
    %deal with invalid values
    dmap(dmap == 0) = NaN;
    
    %convert depth to diopters, which are proportionate to disparity
    image.zleft = dmap;
    image.zright = dmap;
      
    %this will be set later automatically in photoshop
    image.mpd = 0;
    
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
end
%% LOAD UT
function image = loadUT(path)

    found = strfind(path, filesep);
    dir_name = path(found(end) + 1:end);

    findnumber = strfind(dir_name, '_');
    filenumber = dir_name((findnumber(end) + 1):end);
    
    % UT images are LINEAR 16-bit PNG files 
                
    image.right = double(imread([path filesep 'rImage' filenumber '.png']))/(2^16 - 1);
    image.left = double(imread([path filesep 'lImage' filenumber '.png']))/(2^16 - 1);
    
    depth_info_left = load([path filesep 'lRange' filenumber '.mat']);
    image.zleft = double(depth_info_left.range);
     
    depth_info_right = load([path filesep 'rRange' filenumber '.mat']);
    image.zright = double(depth_info_right.range);
   
    
    image.mpd = 0;
    %camera details
    d700_sensor = [36 23.9];
                
    f = 20; %mm
    %pix/mm
    pmm = d700_sensor(1)/size(image.right, 1);
    %arcmin per pix
    theta = 2*atan2(pmm/2, f)*(180/pi);
    %pix per degree
    image.pix_per_deg = theta;
end


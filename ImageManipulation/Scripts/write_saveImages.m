function write_saveImages(image)

    %% Result of manipulation is saved as PNG for demonstration
    %create directory for image
    full_savepath = fullfile(image.savepath, image.name);
    
    if (~exist(full_savepath, 'dir'))
        mkdir(full_savepath);
    end
    
    %
    name_str = fullfile(full_savepath, image.name);
    %% IMPORTANT -- re-apply gamma-correction for display purposes
    
    imwrite((image.imRGB).^(1/2.2), [name_str '_original.png']);
    imwrite((image.imRGBnew).^(1/2.2), [name_str '_manipulated_' image.flag '_jbl.png']);
    imwrite(imadjust((image.imZ - min(image.imZ(:)))./range(image.imZ(:))),[name_str '_depthImage_jbl.png']);
        
    %% IMPORTANT -- save everything as a mat-file
    
    % fields: 
    % name, left(rgb, depth), right(rgb, depth), modfication(original,
    % modification);    
    save([image.metadata filesep image.name '.mat'], '-struct', 'image', 'zleft', 'zright', 'left', 'right', 'imRGB', 'imRGBnew', 'imZ', 'name');


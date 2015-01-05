function mkScaleAnalysis
    abs_path = '~/Documents/MATLAB/scene-filter-see_dev/ImageManipulation/Images/Originals';
    abs_path_res = '~/Documents/MATLAB/scene-filter-see_dev/ImageAnalysis/Result/';

    rel_path = '../Images/Originals';
    rel_path_res = '../../ImageAnalysis/Result/';
    
    %figure out path locations
    if(exist(rel_path, 'dir'))
        path = rel_path;
        result_path = rel_path_res;
    else
        path = abs_path;
        result_path = abs_path_res;
    end
        
    
    listing = dir(path);
    
    % store pyramid correlations
    pyramids = {'Laplacian', 'Wavelet', 'Steerable'};
    max_levels = 5;
    %nPyrs = numel(pyramids);
    %read from Images/Originals folder
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
        
        nScenes = length(listing) - k + 1; 
        pyr_tp = cell(nScenes, 1);
        pyr_orig = cell(nScenes, 1);
        pyr_ap = cell(nScenes, 1);
        scene_list = cell(nScenes, 1);

        for l = k:length(listing)
            idx = l - k + 1;
            image_path = strcat(path, '/', listing(l).name);
                        

            %% run current version of image manipulation                
            images_tp = manipulateLuminance(image_path, 'tp');
            images_ap = manipulateLuminance(image_path, 'ap');
                
            %make a structure for original image
            orig.imRGB = images_tp.imRGB;
            orig.imZOrig = images_tp.imZOrig;
            tp.imRGB = images_tp.imRGBnew;
            tp.imZOrig = images_tp.imZOrig;
            ap.imRGB = images_ap.imRGBnew;
            ap.imZOrig = images_ap.imZOrig;
                
            pyr_orig{idx} = new_pyrAnalysis(orig, max_levels, pyramids);
            pyr_tp{idx} = new_pyrAnalysis(tp, max_levels, pyramids);
            pyr_ap{idx} = new_pyrAnalysis(ap, max_levels, pyramids);
            scene_list{idx} = listing(l).name; 
        end
        save(strcat(result_path, 'new_pyrScaleAllImgs.mat'), 'pyr_orig', 'pyr_tp', 'pyr_ap', 'scene_list');
        
    catch err
        disp('mkScaleAnalysis:Error loading ');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
 end 



    %absolute path should always work
    %check if relative location also works
    
    abs_path = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';
    abs_path_res = '~/Documents/MATLAB/scene-filter-see/ImageAnalysis/Result/';

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
    nPyrs = numel(pyramids);
    %read from Images/Originals folder
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
        
        nScenes = length(listing) - k; 
        pyr_tp = zeros(nPyrs, max_levels, nScenes);
        pyr_orig = zeros(nPyrs, max_levels, nScenes);
        pyr_ap = zeros(nPyrs, max_levels, nScenes);

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
                
            pyr_orig = pyrAnalysis(orig, max_levels, pyramids);
            pyr_tp = pyrAnalysis(tp, max_levels, pyramids);
            pyr_ap = pyrAnalysis(ap, max_levels, pyramids);
                
                
            validIdx = ~isnan(orig.imZOrig);  
            lum_orig = rgb2gray(orig.imRGB.^2.2);
            corr_orig = corr(lum_orig(validIdx), orig.imZOrig(validIdx));
            sf0 = 1/size(lum_orig, 2);

            %% display depth/luminance corr and mean luminance
            f = figure('Name', listing(l).name, 'visible', 'on');           
                
            markers = {'o', '*', '+'};
            %scatter(sf0, corr_orig, 'Marker', '^');
            for p = 1:nPyrs
                f1 = subplot(3, 2, 2*p - 1);
                title(f1, pyramids{p}); hold on
                xlabel(f1, 'spatial frequency, fine to coarse'); hold on;
                ylabel(f1, 'Luminance-depth value' ); hold on;
                
                validP = ~isnan(pyr_orig.ld_corr(p, :));
                options = {'Marker', markers{p}, 'Linewidth', 1};
                plot(pyr_orig.sf(p, validP), pyr_orig.ld_corr(p, validP), '-.g', options{:}); hold on; 
                plot(pyr_tp.sf(p, validP), pyr_tp.ld_corr(p, validP),'-.b', options{:}); hold on; 
                plot(pyr_ap.sf(p, validP), pyr_ap.ld_corr(p, validP), '-.r', options{:}); hold on;   
            end
            legend('Original','Enhanced', 'Degraded');
        
                       
            %scatter(sf0, mean(mean(normM(lum_orig))), 'Marker', '^');
            for p = 1:nPyrs
                f2 = subplot(3, 2, 2*p);
                title(f2, pyramids{p}); hold on;
                xlabel(f2, 'spatial frequency, fine to coarse'); hold on;
                ylabel(f2, 'Mean'); hold on;
                options = {'Marker', markers{p}, 'Linewidth', 1};
                validP = ~isnan(pyr_orig.ld_corr(p, :));
                plot(pyr_orig.sf(p, validP), pyr_orig.mean_lum(p, validP), '.-.g', options{:}); hold on;
                plot(pyr_tp.sf(p, validP), pyr_tp.mean_lum(p, validP), '.-.b', options{:}); hold on;    
                plot(pyr_ap.sf(p, validP), pyr_ap.mean_lum(p, validP), '.-.r', options{:}); hold on;    
            end
            legend('Original', 'Enhanced', 'Degraded');
            
            export_fig(f, strcat(result_path, listing(l).name,'.eps'), '-transparent');
            close(f);               
        end
        pyrX = cat(3, pyr_orig, pyr_tp, pyr_ap);
        save(strcat(result_path, 'pyrScaleAllImgs.mat'), 'pyrX');
        
    catch err
        disp('plotScenesScales:Error loading ');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
      
function pyrAnalysis
% Function builds three pyramids(laplacian, wavelet, steerable)
% for each image/depth map in path_src, calculates depth-luminance
% correlation and mean luminance at each level (from coarse to blur). 
% For each image we generate two scatter plots and save them in path_save.


    %% check if toolbox is loaded
    if ( ~exist('buildWpyr', 'file'))
        error('matlabPyrTools is not linked, please add toolbox to the path');
    end
    
    disp('WARNING: this function requires patched reconSpyr.m. Please unlink other versions of matlabPyrTools');
    
    %absolute/relative path
    abs_path_src = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';
    abs_path_res = '~/Documents/MATLAB/scene-filter-see/ImageAnalysis/Result/';
    
    rel_path_src = '../../ImageManipulation/Images/Originals';
    rel_path_res = '../../ImageAnalysis/Result/';

    %figure out path locations
    if(exist(rel_path_src, 'dir'))
        path_src = rel_path_src;
        path_save = rel_path_res;
    else
        path_src = abs_path_src;
        path_save = abs_path_res;
    end
    
    if ~exist(path_save, 'dir')
        mkdir(savepath);
    end


    listing = dir(path_src);
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
              
        
        for l = k:length(listing)
            
            %idx = l - k + 1;
            disp(strcat('Processing ', listing(l).name));
            image_path = strcat(path_src, '/', listing(l).name);
            image = loadImages(image_path);
            im = rgb2gray(image.imRGB);
            
            %use only valid (~NaN) values for conv            
            validIdx = ~isnan(image.imZOrig);
            depth = image.imZOrig(validIdx);
            imSubSample = 0;
            
            %laplacian, wavelet, steerable pyramids
            [lpyrIm, lpindIm] = buildLpyr(im, 5 - imSubSample);            
            [wpyrIm, wpindIm] = buildWpyr(im, 5 - imSubSample);
            [spyrIm, spindIm] = buildSpyr(im, 5 - imSubSample);
            
            %heigts (each pyramid might have a different height) 
            heightL = floor(lpyrHt(lpindIm));
            heightW = floor(wpyrHt(wpindIm));
            heightS = floor(spyrHt(spindIm));
            
            %arrays for storing correlation values
            ld_corr_L = zeros(heightW, 1);
            mean_lum_L = zeros(heightW, 1);
            sf_L = zeros(heightW, 1);
            
            ld_corr_W = zeros(heightL, 1);
            mean_lum_W = zeros(heightL, 1);
            sf_W = zeros(heightL, 1);
            
            ld_corr_S = zeros(heightS, 1);
            mean_lum_S = zeros(heightS, 1);
            sf_S = zeros(heightS, 1);
                       
            %% Original             
            sf_orig = 1/size(im, 2);            
            ld_corr_orig = corr(im(validIdx), depth);           
            mean_lum_orig = mean(mean(normM(im)));

            %% Laplacian
            for levL = 1:heightL
                    lum = (reconLpyr(lpyrIm, lpindIm, levL));
                    
                    ld_corr_L(levL) = corr(lum(validIdx), depth);
                    mean_lum_L(levL) = mean(mean(normM(levL)));
                    sf_L(levL) = 1/lpindIm(levL, 2);
            end
            %% Wavelet
            for levW = 1:heightW
                    lum = reconWpyr(wpyrIm, wpindIm, 'qmf9', 'reflect1', levW, 'all');

                    ld_corr_W(levW) = corr(lum(validIdx), depth);                    
                    mean_lum_W(levW) = mean(mean(normM(lum)));
                    sf_W(levW) = 1/size(wpyrBand(wpyrIm, wpindIm, levW), 2);
            end
            %% Steerable
            for levS = 1:heightS
                    lum = reconSpyr(spyrIm, spindIm, 'sp1Filters', 'reflect1', levS, 'all');
                    
                    ld_corr_S(levS) = corr(lum(validIdx), depth);                    
                    mean_lum_S(levS) = mean(mean(normM(lum)));
                    sf_S(levS) = 1/size(spyrBand(spyrIm, spindIm, levS), 2);
            end
            
            %% display depth/luminance corr and mean luminance
            f = figure('Name', listing(l).name, 'visible', 'off');
                       
            f1 = subplot(2, 1, 1);
            title(f1, 'Luminance-depth correlation across different bands');
            xlabel(f1, 'spatial frequency');
            ylabel(f1, 'Correlation value');
            
            validL = ~isnan(ld_corr_L);
            validW = ~isnan(ld_corr_W);
            validS = ~isnan(ld_corr_S);
            scatter(sf_orig, ld_corr_orig, 'Marker', '^'); hold on;
            scatter(sf_L(validL), ld_corr_L(validL), 'Marker', '*'); hold on;
            scatter(sf_W(validW), ld_corr_W(validW), 'Marker', 'o'); hold on;
            scatter(sf_S(validS), ld_corr_S(validS), 'Marker', '+'); hold on;
            legend('Origional', 'Laplacian', 'Wavelet', 'Steerable');
        
                       
            f2 = subplot(2, 1, 2);
            title(f2, 'Mean luminance across different bands');
            xlabel(f2, 'spatial frequency');
            ylabel(f2, 'Mean');

            scatter(sf_orig, mean_lum_orig, 'Marker', '^'); hold on;
            scatter(sf_L, mean_lum_L, 'Marker', '*'); hold on;
            scatter(sf_W, mean_lum_W, 'Marker', 'o'); hold on;
            scatter(sf_S, mean_lum_S, 'Marker', '+'); hold on;
            legend('Original', 'Laplacian', 'Wavelet', 'Steerable');
            saveas(f, strcat(path_save, listing(l).name), 'jpeg');
            close(f);               
        end
    catch err
        disp(strcat('pyrAnalysis:Error loading ', path));
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
    disp('done');    
 end
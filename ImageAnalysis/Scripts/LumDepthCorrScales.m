function LumDepthCorrScales

% This function will load original images and decompose them into different
% scales, fine to coarse. At each scale each scene's luminance-depth correlation
% will be calculated. The results will be displayed together and
% splitted by luminance-depth dynamics across all scales.



%% read the directory
    
    path = '~/Documents/MATLAB/scene-filter-see_dev/ImageManipulation/Images/Originals';
    res_path = '~/Documents/MATLAB/scene-filter-see_dev/ImageAnalysis/Result/';

    listing = dir(path);
    
    pyramids = {'l'};
    max_levels = 5;
    f1 = figure('visible', 'on');           
    title('Luminance-depth correlation at different scales'); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
        nScenes = length(listing) - k + 1;
        laplacian = zeros(nScenes, max_levels);
        scenes = cell(nScenes, 1);
        corr_orig = zeros(nScenes, 1);
        for l = k:length(listing)
            
            fprintf('processing %s \n', listing(l).name);
            idx = l - k + 1;
            img_path = strcat(path, '/', listing(l).name);
            
            img = loadImages(img_path);
            orig = rgb2gray(img.imRGB.^2.2);
            depth = img.imZOrig;
            
            pyr_orig = pyrAnalysis(orig, depth, max_levels, pyramids);
            laplacian(idx, :) = pyr_orig.ld_corr(1, :);
            %wavelet(idx, :) = pyr_orig.ld_corr(2, :);
            %steerable(idx, :) = pyr_orig.ld_corr(3, :);

            validIdx = ~isnan(depth);
                
            corr_orig(idx) = corr(orig(validIdx), depth(validIdx));
            scenes{idx} = strcat(listing(l).name, '\t', num2str(laplacian(idx, 1:4)));

            %% display depth/luminance corr and mean luminance
                
%             markers = {'o'};
%             nPyrs = length(pyramids);
%             for p = 1:nPyrs
%                 validP = ~isnan(pyr_orig.ld_corr(p, :));
%                 subplot(1, 3, p);
%                 title(pyramids{p}); hold on;
%                 scatter(1:sum(validP), pyr_orig.ld_corr(p, validP), 'Marker', markers{p}); hold on;
%                 axis([0 6 -0.27 0.27]);
%              end
%             legend(pyramids{:});            
        end
    saveas(f1, [res_path 'scatter'], 'pdf');
    close(f1);
    %% plotting the lines
    
    f2 = figure('visible', 'on');
    subplot(1, 4, 1);
    title('All together'); hold on;
    markers = {'o'};
    %scatter(sf0, corr_orig, 'd'); hold on;
    xlabel('scales, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(laplacian', 'Marker', markers{1}); hold on;
    axis([0 6 -0.27 0.27]); hold on;

    
    %% split and plot
    [l_pos, l_neg] = split_data(laplacian(:, 1:4));
    
    l_rise = laplacian(l_pos, :);
    l_fall = laplacian(l_neg, :);
    l_inc = laplacian(~(l_pos + l_neg), :);

    axis([0 6 -0.27 0.27]); hold on;
    
    subplot(1, 4, 2);
    title('Rising'); hold on;
    axis([0 6 -0.27 0.27]); hold on;
    xlabel('scales, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(l_rise', 'Marker', markers{1}); hold on;
   
    subplot(1, 4, 3);
    title('Falling'); hold on;
    axis([0 6 -0.27 0.27]); hold on;
    xlabel('scales, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;    
    plot(l_fall', 'Marker', markers{1}); hold on;

    subplot(1, 4, 4);
    title('Mixed'); hold on;
    axis([0 6 -0.27 0.27]); hold on;
    xlabel('scales, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(l_inc', 'Marker', markers{1}); hold on;
    saveas(f2, [res_path 'lapl_rfi'], 'pdf');
    close(f2);
    catch err
        disp('analyseImgScales:Error loading ');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end

end

function [pos_idx, neg_idx] = split_data(pyramid)
    p_diff = diff(pyramid, 1, 2);
    %rise
    pos_idx = sum((p_diff > 0), 2) == size(p_diff, 2);
    %fall
    neg_idx = sum((p_diff < 0), 2) == size(p_diff, 2);
    %inconsistent
end
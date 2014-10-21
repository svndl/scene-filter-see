function DepthLumCorrScales

%% read the directory
    mpath = userpath;
    %path = strcat(mpath(1:end - 1),'/scene-filter-see/ImageManipulation/Images/Originals');
    
    path = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';

    listing = dir(path);
    
    pyramids = {'Laplacian', 'Wavelet', 'Steerable'};
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
        wavelet = zeros(nScenes, max_levels);
        steerable = zeros(nScenes, max_levels);
        scenes = cell(nScenes, 1);
        corr_orig = zeros(nScenes, 1);
        for l = k:length(listing)
            fprintf('processing %s \n', listing(l).name);
            idx = l - k + 1;
            img_path = strcat(path, '/', listing(l).name);
            
            img = loadImages(img_path);
            pyr_orig = pyrAnalysis(img, max_levels, pyramids);
            laplacian(idx, :) = pyr_orig.ld_corr(1, :);
            wavelet(idx, :) = pyr_orig.ld_corr(2, :);
            steerable(idx, :) = pyr_orig.ld_corr(3, :);
            orig = rgb2gray(img.imRGB.^2.2);
            depth = img.imZOrig;

            validIdx = ~isnan(depth);
                
            corr_orig(idx) = corr(orig(validIdx), depth(validIdx));
            scenes{idx} = strcat(listing(l).name, '=', num2str(corr_orig(idx)));
            %sf0 = 1/size(orig, 2);

            %% display depth/luminance corr and mean luminance
                
            markers = {'o', '*', '+'};
            nPyrs = length(pyramids);
            for p = 1:nPyrs
                validP = ~isnan(pyr_orig.ld_corr(p, :));
                subplot(1, 3, p);
                title(pyramids{p}); hold on;
                %scatter(sf0, corr_orig, 'd'); hold on;
                scatter(1:sum(validP), pyr_orig.ld_corr(p, validP), 'Marker', markers{p}); hold on;
                axis([0 6 -0.25 0.25]);
             end
            %legend('Original','Laplacian', 'Wavelet', 'Steerable');            
        end
    saveas(f1, [path 'scatter'], 'pdf');
    close(f1);
    %%plotting the lines
    
    f2 = figure('visible', 'on');
    subplot(1, 3, 1);
    title(pyramids{1}); hold on;
    
    %scatter(sf0, corr_orig, 'd'); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(laplacian', 'Marker', markers{1}); hold on;
    axis([0 6 -0.25 0.25]); hold on;

    subplot(1, 3, 2);
    title(pyramids{2}); hold on;
    axis([0 6 -0.25 0.25]); hold on;
    %scatter(sf0, corr_orig, 'd'); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;

    plot(wavelet', 'Marker', markers{2}); hold on;
    
    subplot(1, 3, 3);
    title(pyramids{3}); hold on;
    axis([0 6 -0.25 0.25]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    
    plot(steerable', 'Marker', markers{3}); hold on;
    saveas(f2, [path 'lineplot'], 'pdf');
    close(f2);
    
    %% split and plot
    [l_pos, l_neg] = split_data(laplacian(:, 1:4));
    [w_pos, w_neg] = split_data(wavelet);
    
    l_rise = laplacian(l_pos, :);
    l_fall = laplacian(l_neg, :);
    l_inc = laplacian(~(l_pos + l_neg), :);

    w_rise = wavelet(w_pos, :);
    w_fall = wavelet(w_neg, :);
    w_inc = wavelet(~(w_pos + w_neg), :);
    
    %% laplacian
    f3 = figure;
    axis([0 6 -0.25 0.25]); hold on;
    
    subplot(1, 3, 1);
    title('Rising'); hold on;
    axis([0 6 -0.25 0.25]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(l_rise', 'Marker', markers{1}); hold on;
    lp = legend(scenes{l_pos}); hold on;
    set(lp, 'Interpreter', 'none');
    
    subplot(1, 3, 2);
    title('Falling'); hold on;
    axis([0 6 -0.25 0.25]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;    
    plot(l_fall', 'Marker', markers{1}); hold on;
    ln = legend(scenes{l_neg}); hold on;
    set(ln, 'Interpreter', 'none');

    subplot(1, 3, 3);
    title('Mixed'); hold on;
    axis([0 6 -0.25 0.25]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(l_inc', 'Marker', markers{1}); hold on;
    li = legend(scenes{~(l_pos+l_neg)}); hold on;
    set(li, 'Interpreter', 'none');
    saveas(f3, [path 'l_rfi'], 'pdf');
    close(f3);
    %% wavelet
    
    f4 = figure;
    axis([0 6 -0.1 0.1]); hold on;
    
    subplot(1, 3, 1);
    title('Rising'); hold on;
    axis([0 6 -0.1 0.1]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(w_rise', 'Marker', markers{2}); hold on;
    wp = legend(scenes{w_pos}); hold on;
    set(wp, 'Interpreter', 'none');
    
    subplot(1, 3, 2);
    title('Falling'); hold on;
    axis([0 6 -0.1 0.1]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
    plot(w_fall', 'Marker', markers{2}); hold on;
    wn = legend(scenes{w_neg}); hold on;
    set(wn, 'Interpreter', 'none');
    
    subplot(1, 3, 3);
    title('Mixed'); hold on;
    axis([0 6 -0.1 0.1]); hold on;
    xlabel('spatial frequency, fine to coarse'); hold on;
    ylabel('Luminance-depth correlation'); hold on;    
    plot(w_inc', 'Marker', markers{2}); hold on;
    wi = legend(scenes{~(w_pos + w_neg)}); hold on;
    set(wi, 'Interpreter', 'none');
    
    saveas(f4, [path 'w_rfi'], 'pdf');
    close(f4);
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
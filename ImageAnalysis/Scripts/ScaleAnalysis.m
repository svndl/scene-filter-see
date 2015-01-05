function ScaleAnalysis
    
    %% determine where to save the pics
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
    %% pre-load/compute pyrAnalysis for all scenes
    
%     if (~exist('new_pyrScaleAllImgs.mat', 'file'))
%         %run analysis
%         mkScaleAnalysis;
%     end
%     load('new_pyrScaleAllImgs.mat');
    mkScaleAnalysis;    
    nScenes = length(scene_list);
    
    xLabel = 'Blur level';
    yLabel = 'Luminance-depth correlation';    
    % plot lum-depth correlation (scene)
    % plot max corr/scale (all scvenes)
    % plot difference enchance/degraded - original (scene) 
    f = figure('Name','Max distribution', 'visible', 'on');           

    for i = 1:nScenes
        % scene dynamics
        sceneScaleDynamics(scene_list{i}, result_path, pyr_orig{i}.ld_corr, ...
            pyr_tp{i}.ld_corr, pyr_ap{i}.ld_corr, xLabel, yLabel);
        
        f = sceneScaleMax(f, pyr_orig{i}.ld_corr, ...
            pyr_tp{i}.ld_corr, pyr_ap{i}.ld_corr);
        sceneScaleDiff(scene_list{i}, result_path, pyr_orig{i}.ld_corr, ...
            pyr_tp{i}.ld_corr, pyr_ap{i}.ld_corr, xLabel, yLabel);
        
        %max correlation
        %sceneScaleMax
    end
   saveas(f, strcat(result_path, 'Max distribution_new', 'pdf'));
   close(f);
    
end %endof ScaleAnalysis

%% plotting stuff
%% The effect of enhancemend/degradation by sccale for each scene

function sceneScaleDynamics(name, res_path, yData1, yData2, yData3, xLabel, yLabel)    
    f = figure('Name',name, 'visible', 'on');           
    %pyramids = {'Laplacian','Wavelet', 'Steerable'};
    pyramids = {'Laplacian','Wavelet'};
    
    nPyrs = length(pyramids);
    markers = {'o', '*', '+'};
    tickL = {'1x','', '2x','', '3x','', '4x'};
    tickW = {tickL{:}, '', '5x'};
    ticks = {tickL, tickW};
   
    %color_opts = {'-.g', '-.b', '-.r'};
    for p = 1:nPyrs
        f1 = subplot(2, 1, p);
        box on;
        title(f1, pyramids{p}, 'interpreter', 'none', 'FontSize', 18); hold on
        xlabel(f1, xLabel, 'FontSize', 15); hold on;
        ylabel(f1, yLabel, 'FontSize', 15); hold on;
        options = {'Marker', markers{p}, 'Linewidth', 1};
        validIdx = ~isnan(yData1(p, :));        
        plot(yData1(validIdx), '-.b', options{:}); hold on;
        plot(yData2(validIdx), '-.g', options{:}); hold on;
        plot(yData3(validIdx), '-.r', options{:}); hold on;
        set(f1,'XTickLabel',ticks{p});
    end
    legend('Original', 'Enhanced', 'Degraded');
    saveas(f, strcat(res_path, name, '_LowScaleAnalysis.pdf'));
    close(f);                   
end
function f = sceneScaleMax(f, yData1, yData2, yData3)
    [idx1, val1] = max(abs(yData1), [], 2);
    [idx2, val2] = max(abs(yData2), [], 2);
    [idx3, val3] = max(abs(yData3), [], 2);
    %pyramids = {'Laplacian','Wavelet', 'Steerable'};
    pyramids = {'Laplacian','Wavelet'};
    
    nPyrs = length(pyramids);
    markers = {'o', '*', '+'};
    
    for p = 1:nPyrs
        f1 = subplot(2, 1, p);
        title(f1, pyramids{p}); hold on
        xlabel(f1, 'Blur level', 'FontSize', 16); hold on;
        ylabel(f1, 'Lum-depth correlation', 'FontSize', 16); hold on;
        
        options = {'Marker', markers{p}, 'Linewidth', 1};
        scatter(val1, idx1, 'b', options{:}); hold on;
        scatter(val2, idx2, 'g', options{:}); hold on;
        scatter(val3, idx3, 'r', options{:}); hold on;
        xlim([0 5]);
    end
    box on;
    legend('Original', 'Enhanced', 'Degraded');
end
function sceneScaleDiff(name, res_path, yData1, yData2, yData3, xLabel, yLabel)    
    f = figure('Name',name, 'visible', 'on');           
%     pyramids = {'Laplacian','Wavelet', 'Steerable'};
    pyramids = {'Laplacian','Wavelet'};
    
    nPyrs = length(pyramids);
    markers = {'o', '*', '+'};
    %color_opts = {'-.g', '-.b', '-.r'};
    for p = 1:nPyrs
        f1 = subplot(2, 1, p);
        title(f1, pyramids{p}); hold on
        xlabel(f1, xLabel); hold on;
        ylabel(f1, yLabel); hold on;
        options = {'Marker', markers{p}, 'Linewidth', 1};
        validIdx = ~isnan(yData1(p, :));        
        plot(yData1(validIdx), '-.b', options{:}); hold on;
        %tp - orig
        plot(yData2(validIdx) - yData1(validIdx), '-g', options{:}); hold on;
        %orig - ap
        plot(yData1(validIdx) - yData3(validIdx), '-r', options{:}); hold on;
    end
    legend('Original', 'Enhanced', 'Degraded');
    box on;
    saveas(f, strcat(res_path, name, '_diff_new.pdf'));
    close(f);                   
end




    
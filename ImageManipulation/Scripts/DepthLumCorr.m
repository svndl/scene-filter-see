% determine the lum-depth correlation of all images (right ones)
% get a list of image directories
% load images (ap, orig, tp) and depth maps
% calculate the difference between lum-depth correlation between orig - ap,
% tp - ap, tp - orig.
% calculate the %of "more 3d" from perceptual data in the same order  
% result: 2 vector: scene differences/preceptual diferences
% scatter plot, correlation

function DepthLumCorr

 
%     path = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';
%     experiment_path = '~/Documents/MATLAB/scene-filter-see/PerceptualExperiment/Data';

    path = '../Images/Originals';
    experiment_path = '../../PerceptualExperiment/Data';
    
    
    listing = dir(path);
    
    % mat-file w. perceptual experiment data
    main = load([experiment_path '/mainExperimentData.mat']);
    
    % shortcut for trials 
    dat = main.data;
    trl = dat.trials;
    
    nScenes = length(dat.scenesListSorted);
    % trial data
    trial_tp_ap = zeros(nScenes, 2);
    trial_tp_orig = zeros(nScenes, 2);
    trial_orig_ap = zeros(nScenes, 2);
    list_trial_scenes = cell(nScenes, 1);
    
    % calculated data
    % process only the scenes w.perceprual data 
    calc_tp_ap = zeros(nScenes, 2);
    calc_tp_orig = zeros(nScenes, 2);
    calc_orig_ap = zeros(nScenes, 2);
    
    %read from Images/Originals folder
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end        
        for l = k:length(listing)
            idx = l - k + 1;
            image_path = strcat(path, '/', listing(l).name);
                        
            % lookup the scene in perceptual data
            % if found, calculate current correlation values
            sn = find(ismember(dat.scenesListSorted, listing(l).name));
            if (sn)
                %% run current version of image manipulation                
                images_tp = manipulateLuminance(image_path, 'tp');
                images_ap = manipulateLuminance(image_path, 'ap');
                
                orig = rgb2gray(images_tp.imRGB.^(2.2));
                tp = rgb2gray(images_tp.imRGBnew.^(2.2));
                ap = rgb2gray(images_ap.imRGBnew.^(2.2));
            
                %imZOrig is the same for images_tp and images_ap
                validIdx = ~isnan(images_tp.imZOrig);
                depth_orig = images_tp.imZOrig(validIdx);
                depth_tp = images_tp.imZOrig(validIdx);
                depth_ap = images_ap.imZOrig(validIdx);
                
                %%  calculate current correlations         
                corr_orig = corr(depth_orig, orig(validIdx));
                corr_tp = corr(depth_tp, tp(validIdx));
                corr_ap = corr(depth_ap, ap(validIdx));
                            
                calc_tp_ap(idx, 1) = corr_tp - corr_ap;                
                calc_tp_orig(idx, 1) = corr_tp - corr_orig;
                calc_orig_ap(idx, 1) = corr_orig - corr_ap;

                %% grab the relevant trials
                list_trial_scenes{idx} = dat.scenesListSorted{sn};
                tp_apInds = dat.trials.scene_number == sn & ...
                trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
                trl.condB == find(ismember(dat.conditionTypes, 'ap'));
    
                tp_origInds = dat.trials.scene_number == sn & ...
                trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
                trl.condB == find(ismember(dat.conditionTypes, 'orig'));
    
                orig_apInds = dat.trials.scene_number == sn & ...
                trl.condA == find(ismember(dat.conditionTypes, 'orig')) & ...
                trl.condB == find(ismember(dat.conditionTypes, 'ap'));
    
                %percent more 3D
                trial3d_tp_ap = sum(trl.resp_Amore3DthanB(tp_apInds))/length(trl.resp_Amore3DthanB(tp_apInds));
                trial3d_tp_orig = sum(trl.resp_Amore3DthanB(tp_origInds))/length(trl.resp_Amore3DthanB(tp_origInds));
                trial3d_orig_ap = sum(trl.resp_Amore3DthanB(orig_apInds))/length(trl.resp_Amore3DthanB(orig_apInds));
        
                %lum depth correlation
                trial_corr_tp_ap = unique(trl.AcorrMinusBcorr(tp_apInds));
                trial_corr_tp_orig = unique(trl.AcorrMinusBcorr(tp_origInds));                
                trial_corr_orig_ap = unique(trl.AcorrMinusBcorr(orig_apInds));
                                                                                         
                trial_tp_ap(idx, 1) = trial_corr_tp_ap;
                trial_tp_ap(idx, 2) = trial3d_tp_ap;
                trial_tp_orig(idx, 1) = trial_corr_tp_orig;
                trial_tp_orig(idx, 2) = trial3d_tp_orig;
                trial_orig_ap(idx, 1) = trial_corr_orig_ap;
                trial_orig_ap(idx, 2) = trial3d_orig_ap;
%                 disp(strcat(list_trial_scenes{idx}, ...
%                     '     ', num2str(trial_corr_tp_ap), ...
%                     '     ', num2str(trial_corr_tp_orig), ...
%                     '     ', num2str(trial_orig_ap), ...
%                     '     ', num2str(calc_tp_ap), ...
%                     '     ', num2str(calc_tp_orig), ...
%                     '     ', num2str(calc_orig_ap)));
            end
        end
    catch err
        disp(strcat('DepthLumCorr:Error loading ', path));
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
    
    %do scatter-plot
    figure(1);
    
    subplot(2, 1, 1);

    scatter(trial_tp_ap(:, 1),trial_tp_ap(:, 2), 'Marker', '*'); hold on;
    scatter(trial_tp_orig(:, 1), trial_tp_orig(:, 2), 'Marker', 'o'); hold on;
    scatter(trial_orig_ap(:, 1), trial_orig_ap(:, 2), 'Marker', '+'); hold on;
    legend('tp-ap', 'tp-orig', 'orig-ap');
    title('Experiment data');
    xlabel('Luminance-depth correlation');
    ylabel('Percent judged more 3D');
        
    subplot(2, 1, 2);

    scatter(trial_tp_ap(:, 1),calc_tp_ap(:, 1), 'Marker', '*'); hold on;
    scatter(trial_tp_orig(:, 1), calc_tp_orig(:, 1), 'Marker', 'o'); hold on;
    scatter(trial_orig_ap(:, 1), calc_orig_ap(:, 1), 'Marker', '+'); hold on;
    title('Difference between experiment and current');
    xlabel('calculated luminance-depth correlation');
    ylabel('trial luminance-depth correlation');
    legend('tp-ap', 'tp-orig', 'orig-ap');
    axis equal;
    
    %do a print-out difference
end %eof
    

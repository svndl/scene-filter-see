% determine the lum-depth correlation of all images (right ones)
% get a list of image directories
% load images (ap, orig, tp) and depth maps
% calculate the difference between lum-depth correlation between orig - ap,
% tp - ap, tp - orig.
% calculate the %of "more 3d" from perceptual data in the same order  
% result: 2 vector: scene differences/preceptual diferences
% scatter plot, correlation

function DepthLumCorr

    % Generate new set of modified images
    path = '~/Documents/MATLAB/SONY/ImageManipulation/Images/Originals';
    experiment_path = '~/Documents/MATLAB/SONY/PerceptualExperiment/Data';
    
    listing = dir(path);
    %main experiment
    main = load([experiment_path '/mainExperimentData.mat']);
    
    %shortcut for trials 
    data = main.data;
    trials = data.trials;
    
    nScenes = length(data.scenesListSorted);
    %trial data
    trial_tp_ap = zeros(nScenes, 2);
    trial_tp_orig = zeros(nScenes, 2);
    trial_orig_ap = zeros(nScenes, 2);
    list_trial_scenes = cell(nScenes, 1);
    %read from mat folder
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
        nImages = length(listing) - k + 1;
        images = cell(nImages, 1);
        
        %calculated lum-depth correlation
        calc_tp_ap = zeros(nImages, 2);
        calc_tp_orig = zeros(nImages, 2);
        calc_orig_ap = zeros(nImages, 2);
        list_calc_scenes = cell(nImages, 1);

        for l = k:length(listing)
            idx = l - k + 1;
            image_path = strcat(path, '/', listing(l).name);
            list_calc_scenes{idx} = listing(l).name;
            
            images_tp = manipulateLuminance(image_path, 'tp');
            images_ap = manipulateLuminance(image_path, 'ap');
            %we'll only need original image,
            %original dispmap, and two modified versoins
            images{idx}.name = images_tp.name;

            orig = rgb2gray(images_tp.imRGB.^(2.2));
            tp = rgb2gray(images_tp.imRGBnew.^(2.2));
            ap = rgb2gray(images_ap.imRGBnew.^(2.2));
            
            %imZOrig is the same for images_tp and images_ap
            validIdx = ~isnan(images_tp.imZOrig);
            depth_orig = images_tp.imZOrig(validIdx);
            depth_tp = images_tp.imZOrig(validIdx);
            depth_ap = images_ap.imZOrig(validIdx);
                        
            images{idx}.corr_orig = corr(depth_orig, orig(validIdx));
            images{idx}.corr_tp = corr(depth_tp, tp(validIdx));
            images{idx}.corr_ap = corr(depth_ap, ap(validIdx));
            
            %current difference in lum-depth correlation 
            calc_tp_ap(idx, 1) = images{idx}.corr_tp - images{idx}.corr_ap;
            calc_tp_orig(idx, 1) = images{idx}.corr_tp - images{idx}.corr_orig;
            calc_orig_ap(idx, 1) = images{idx}.corr_orig - images{idx}.corr_ap;

            %perceptual data
            sn = find(ismember(data.scenesListSorted, listing(l).name));
            if (sn)
            %grab the relevant trials
                list_trial_scenes{idx} = data.scenesListSorted{sn};
                tp_apInds = data.trials.scene_number == sn & ...
                trials.condA == find(ismember(data.conditionTypes, 'tp')) & ...
                trials.condB == find(ismember(data.conditionTypes, 'ap'));
    
                tp_origInds = data.trials.scene_number == sn & ...
                trials.condA == find(ismember(data.conditionTypes, 'tp')) & ...
                trials.condB == find(ismember(data.conditionTypes, 'orig'));
    
                orig_apInds = data.trials.scene_number == sn & ...
                trials.condA == find(ismember(data.conditionTypes, 'orig')) & ...
                trials.condB == find(ismember(data.conditionTypes, 'ap'));
    
    
                %percent more 3D
                trial3d_tp_ap = sum(trials.resp_Amore3DthanB(tp_apInds))/length(trials.resp_Amore3DthanB(tp_apInds));
                trial3d_tp_orig = sum(trials.resp_Amore3DthanB(tp_origInds))/length(trials.resp_Amore3DthanB(tp_origInds));
                trial3d_orig_ap = sum(trials.resp_Amore3DthanB(orig_apInds))/length(trials.resp_Amore3DthanB(orig_apInds));
        

                %lum depth correlation
                trial_corr_tp_ap = unique(trials.AcorrMinusBcorr(tp_apInds));
                trial_corr_tp_orig = unique(trials.AcorrMinusBcorr(tp_origInds));
                trial_corr_orig_ap = unique(trials.AcorrMinusBcorr(orig_apInds));
                                       
                
%                 %save loaded data within our structure
%                 images{idx}.trial.tp_ap = trial3d_tp_ap;
%                 images{idx}.trial.tp_orig = trial3d_tp_orig;
%                 images{idx}.trial.orig_ap = trial3d_orig_ap;
%         
% 
%                 images{idx}.trial.corr_tp_ap = trial_corr_tp_ap;
%                 images{idx}.trial.corr_tp_orig = trial_corr_tp_orig;
%                 images{idx}.trial.corr_orig_ap = trial_corr_orig_ap;
                
                
                trial_tp_ap(idx, 1) = trial_corr_tp_ap;
                trial_tp_ap(idx, 2) = trial3d_tp_ap;
                trial_tp_orig(idx, 1) = trial_corr_tp_orig;
                trial_tp_orig(idx, 2) = trial3d_tp_orig;
                trial_orig_ap(idx, 1) = trial_corr_orig_ap;
                trial_orig_ap(idx, 2) = trial3d_orig_ap;
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
    figure(1) 
    xlabel('Luminance-depth correlation');
    ylabel('Percent judged more 3D');

    scatter(trial_tp_ap(:, 1),trial_tp_ap(:, 2), 'Marker', '*'); hold on;
    scatter(trial_tp_orig(:, 1), trial_tp_orig(:, 2), 'Marker', 'o'); hold on;
    scatter(trial_orig_ap(:, 1), trial_orig_ap(:, 2), 'Marker', '+'); hold on;
    
    scatter(calc_tp_ap(:, 1), calc_tp_ap(:, 2), 'Marker', '*'); hold on;
    scatter(calc_tp_orig(:, 1), calc_tp_ap(:, 2), 'Marker', 'o'); hold on;
    scatter(calc_orig_ap(:, 1), calc_tp_ap(:, 2), 'Marker', '+'); hold on;
    
    legend('tp-ap', 'tp-orig', 'orig-ap');

    %save('images_analysis.mat', 'images');
end %eof
    

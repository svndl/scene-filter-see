function analyseImgScales
    %absolute path should always work
    %check if relative location also works
    
    mpath = strtok(userpath, pathsep);
    path = fullfile(mpath, 'scene-filter-see', 'ImageManipulation', 'Images', 'Originals');
    experiment_path = fullfile(mpath, 'scene-filter-see', 'PerceptualExperiment', 'Data');        
    
    path_res = fullfile(mpath, 'scene-filter-see', 'ImageAnalysis', 'Result');
        
    
    listing = dir(path);
    
    % mat-file w. perceptual experiment data
    main = load(fullfile(experiment_path, 'mainExperimentData.mat'));
    
    % shortcut for trials 
    dat = main.data;
    trl = dat.trials;
    
    nScenes = length(dat.scenesListSorted);
    % trial data
    trial_tp_ap = zeros(nScenes, 2);
    trial_tp_orig = zeros(nScenes, 2);
    trial_orig_ap = zeros(nScenes, 2);
    
    % store pyramid correlations
    pyramids = {'Laplacian'};
    max_levels = 5;
    nPyrs = numel(pyramids);
    pyr_tp_ap = zeros(nPyrs, max_levels, nScenes);
    pyr_tp_orig = zeros(nPyrs, max_levels, nScenes);
    pyr_orig_ap = zeros(nPyrs, max_levels, nScenes);
    
    
    list_trial_scenes = cell(nScenes, 1);
    
    %read from Images/Originals folder
    if (~exist(fullfile(path_res, 'pyrImgs.mat'), 'file'))
        
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
                    %% load preceptual data
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
                    trial_tp_ap(idx, 2) = sum(trl.resp_Amore3DthanB(tp_apInds))/length(trl.resp_Amore3DthanB(tp_apInds));
                    trial_tp_orig(idx, 2) = sum(trl.resp_Amore3DthanB(tp_origInds))/length(trl.resp_Amore3DthanB(tp_origInds));
                    trial_orig_ap(idx, 2) = sum(trl.resp_Amore3DthanB(orig_apInds))/length(trl.resp_Amore3DthanB(orig_apInds));
        
                    %lum depth correlation
                    trial_tp_ap(idx, 1) = unique(trl.AcorrMinusBcorr(tp_apInds));
                    trial_tp_orig(idx, 1) = unique(trl.AcorrMinusBcorr(tp_origInds));                
                    trial_orig_ap(idx, 1) = unique(trl.AcorrMinusBcorr(orig_apInds));
                
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
                
                    pyr_tp_ap(:, :, idx) = pyr_tp.ld_corr - pyr_ap.ld_corr;
                    pyr_tp_orig(:, :, idx) = pyr_tp.ld_corr - pyr_orig.ld_corr;
                    pyr_orig_ap(:, :, idx) = pyr_orig.ld_corr - pyr_ap.ld_corr;
                
                    validIdx = ~isnan(orig.imZOrig);
                
                    lum_orig = rgb2gray(orig.imRGB.^2.2);
                    corr_orig = corr(lum_orig(validIdx), orig.imZOrig(validIdx));
                    sf0 = 1/size(lum_orig, 2);

                    %% display depth/luminance corr and mean luminance
                    f = figure('Name', listing(l).name, 'visible', 'off');           
                    f1 = subplot(2, 1, 1);
                    title(f1, 'Luminance-depth correlation at different scales'); hold on;
                    xlabel(f1, 'spatial frequency, fine to coarse'); hold on;
                    ylabel(f1, 'Luminance-depth correlation'); hold on;
                
                    markers = {'o', '*', '+'};
                    scatter(sf0, corr_orig, 'Marker', '^');
                    for p = 1:nPyrs
                        validP = ~isnan(pyr_orig.ld_corr(p, :));
                        scatter(pyr_orig.sf(p, validP), pyr_orig.ld_corr(p, validP), 'Marker', markers{p}); hold on;    
                    end
                    legend('Original','Laplacian');
        
                       
                    f2 = subplot(2, 1, 2);
                    title(f2, 'Mean luminance at different scales'); hold on;
                    xlabel(f2, 'spatial frequency, fine to coarse'); hold on;
                    ylabel(f2, 'Mean'); hold on;
                    scatter(sf0, mean(mean(normM(lum_orig))), 'Marker', '^');
                    for p = 1:nPyrs
                        scatter(pyr_orig.sf(p, :), pyr_orig.mean_lum(p, :), 'Marker', markers{p}); hold on;    
                    end
                    legend('Original', 'Laplacian');
            
                    saveas(f, fullfile(path_res, [listing(l).name '.pdf']));
                    close(f);               
                end
            end
        catch err
            disp('analyseImgScales:Error loading ');
            disp(err.message);
            disp(err.cause);
            disp(err.stack(1));
            disp(err.stack(2));
        end
        pyrX = cat(3, pyr_tp_ap, pyr_tp_orig, pyr_orig_ap);
        data = vertcat(trial_tp_ap, trial_tp_orig, trial_orig_ap);
        X0 = data(:, 1);
        Y0 = data(:, 2);
        % save data
        pyrImgs.X = pyrX;
        pyrImgs.X0 = X0;
        pyrImgs.Y0 = Y0;
        
        save(fullfile(path_res, 'pyrImgs.mat'), 'pyrImgs');
        
    else
        load(fullfile(path_res, 'pyrImgs.mat'));
        pyrX = pyrImgs.X;
        X0 = pyrImgs.X0;
        Y0 = pyrImgs.Y0;        
    end
        
        
   for p =1:nPyrs
       pyr = squeeze(pyrX(p, :, :));
       f = plot_pyramid(pyr, X0, Y0, pyramids{p});
        %saveas(f, strcat(abs_path_res, pyrNames{p}), 'eps');
       saveas(f, fullfile(path_res, [pyramids{p} '.pdf']));
       close(f);
   end
end

      
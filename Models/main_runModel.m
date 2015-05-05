function main_runModel(varargin)
    %setup path
    
    path = main_setPath_Model; 
    %load    
    if ( nargin == 0 )     
        exp_type = 'ssvep';
        rgc_type = 'simple';
    else
        exp_type = varargin{1};
        rgc_type = varargin{2};
    end
    if (nargin > 2)
        downsample_rate = varargin{3};
    else
        downsample_rate = 580; %width, pix;
    end;
    
    [img, ratings] = main_getRatedScenes(exp_type);
    experiment_params = main_getExperimentParams(exp_type, downsample_rate);
    
    %for neat call, get experiment params together
    calcParams.arcmin_ppx = experiment_params.arcmin_per_pixel;
    calcParams.rgcType = rgc_type;
    calcParams.downsample = downsample_rate;
    calcParams.usedepth = 0;
    
    %important -- conditions to compare!
    calcParams.AvsB = 'EO';
    
    % save to experiment-specific folder
    savepath = fullfile(path.results, exp_type);
    
    if ~(exist(savepath, 'dir'))
        mkdir(savepath);
        addpath(savepath);
    end
    
    response = calcModelResponse(savepath, img, calcParams);
    
    fig_title = 'Enhanced > Original';
    f = main_plotModel(fig_title, response, ratings.enh_orig, img.names);
    
    saveStr = fullfile(path.results, [exp_type '_' fig_title '_' rgc_type '_' num2str(downsample_rate)]);
    
    try
        export_fig([saveStr '.pdf'], f, '-transparent');
    catch
        saveas(f, saveStr, 'pdf');
    end
    
end

function response = calcModelResponse(path, sceneList, calcParams)
    
    nScenes = numel(sceneList.names);
    
    respA = zeros(nScenes, 1);
    respB = zeros(nScenes, 1);
    
    switch calcParams.AvsB
        
        case {'EO', 'eo'}
            imgA = sceneList.enh;
            imgB = sceneList.orig;
        case {'ED', 'ed'}
            imgA = sceneList.enh;
            imgB = sceneList.deg;            
        case{'OD', 'od'}
            imgA = sceneList.orig;
            imgB = sceneList.deg;
        otherwise
            %do nothing for now
    end
     
    for s = 1:nScenes
        try
            sceneStructA.im = imgA{s};
            sceneStructA.depth = sceneList.depthmap{s};
            sceneStructA.name = sceneList.names{s};
            
            sceneStructB.im = imgB{s};
            sceneStructB.depth = sceneList.depthmap{s};
            sceneStructB.name = sceneList.names{s};
            
            modelRespA = get_ModelScene(path, sceneStructA, calcParams, calcParams.AvsB(1));
            modelRespB = get_ModelScene(path, sceneStructB, calcParams, calcParams.AvsB(2));
            respA(s) = modelRespA.volume;
            respB(s) = modelRespB.volume;
        catch err
            disp(strcat('Error, skipping ', num2str(s)));
            disp(err.identifier);
            disp(num2str(err.stack(1).file));
            disp(num2str(err.stack(1).line));
        end;
    end
    response = respA - respB;
end


% function calc_model(path, img, percept, versions, arcmin_per_pixel)
%     
%     nsizes = length(sizes);
%     %predicted = cell(nsizes, 1);
%     
%     m = main_getModel;
%     for i = 1:nsizes
%         for v = 1:numel(versions)
%             fname = strcat('predicted', num2str(sizes(i)), '_', versions{v});
%             figTitle = strcat('Model-Based Brain Picture Responses', num2str(sizes(i)), '_', versions{v});
%             [predicted, responses] = model_response(m, img, sizes(i), versions{v});
%             save([ path.models filesep 'Data' strcat(fname, '.mat')], 'predicted', 'responses');
%             main_plot(predicted, percept, path.results, figTitle, 0);
%         end
%     end
%     
% end

% function load_model_results(path, img, sizes, versions, percept)
%     nsizes = length(sizes);
%     for i = 1:nsizes
%         for v = 1:numel(versions)
%             fname = strcat('predicted', num2str(sizes(i)), '_', versions{v});
%             load(strcat(fname, '.mat'));
%             pred(i) = predicted;
%             %br{i} = responses;
%             
%             figTitle = strcat('Model-Based Brain Picture Responses', num2str(sizes(i)), ' ', versions{v});
%             main_plot(predicted, percept, paths, figTitle, [-0.0001 0.0001], 0);
%         end
%     end
%     
%     nScenes = length(img);
%     
%     % for each scene plot correlation distribution for sizes
%     scene_ed = zeros(1, length(sizes));
%     scene_eo = zeros(1, length(sizes));
%     scene_od = zeros(1, length(sizes));
%     for i = 1:nScenes
%         for n = 1:length(sizes)
%              scene_ed(n) = pred(n).enh_deg(i);
%              scene_eo(n) = pred(n).enh_orig(i);
%              scene_od(n) = pred(n).orig_deg(i);
%         end
%         f = figure('visible', 'on');
%         title(strcat(img{i}.name, 'model response vs scene size'));
%         plot(sizes, scene_ed,'-o','MarkerFaceColor', 'r', 'Color', 'r'); hold on;
%         plot(sizes, scene_eo,'-o','MarkerFaceColor', 'b', 'Color', 'b'); hold on;
%         plot(sizes, scene_od,'-o','MarkerFaceColor', 'y', 'Color', 'y'); hold on;
%         set(gca, 'XTick', sizes);
%         legend('Enh->Orig','Enh->Deg', 'Orig->Deg');
%         xlabel('Scene size');
%         ylabel('Predictor magnitude');
%         
%         export_fig([path.result filesep img{i}.name '.pdf']);
%         close(f);
%     end
% end
% 
% function plot_corel_vs_imsize(sizes, versions, percept)
%     ttl = 'Predictor''s output, correlated with perceptual data vs input size';
%     f = setupfig(18, 6, 18); hold on; 
%     h = suptitle(ttl);
%     set(h, 'interpreter', 'none');
% 
%     nsizes = length(sizes);
%     for i = 1:nsizes
%         for v = 1:1%numel(versions)
%             fname = strcat('predicted', num2str(sizes(i)), '_', versions{v});
%             load(strcat(fname, '.mat'));
%        
%             plotCorVals(sizes(i), predicted.enh_orig', percept.enh_orig', 1, 'r', 'Enhanced > Original');
%             set(gca, 'XTick', sizes);
%             plotCorVals(sizes(i), predicted.enh_deg', percept.enh_deg', 2, 'b', 'Enhanced > Degraded');
%             set(gca, 'XTick', sizes);
%             plotCorVals(sizes(i), predicted.orig_deg', percept.orig_deg', 3, 'y', 'Original > Degraded');
%             set(gca, 'XTick', sizes);
%         end
%         
%     end
%     try
%         export_fig([paths.results filesep ttl '.png']);
%     catch 
%         saveas(f, strcat(paths.results, filesep, ttl, '.pdf'), 'pdf');
%     end
% end
% function plotCorVals(s, v1, v2, num, c, tl)
%    [rA, ~] = corr(v1,v2);
%    subplot(1, 3, num); hold on;
% %    plot([0 400],[0.5 0.5],'k:');
%    title(tl, 'FontSize', 18);
%    axis square; box on;
%    stem(s, rA,'-ko','MarkerFaceColor', c, 'Color', c);   
%    xlabel('Size of scaled input, pixels', 'FontSize', 18);
%    ylabel('Correlation value', 'FontSize', 18);
%    
% end
function modelResp = get_ModelScene(path, sceneStruct, calcParams, version)


    display(['Applying brain model to scene ' sceneStruct.name ' _' version]);
    
    %look up if calculations for this types of parameters have already been made        
    fileStr = [sceneStruct.name '_' calcParams.rgcType '_' num2str(calcParams.downsample) '_' version '.mat'];
    if (exist(fullfile(path, sceneStruct.name, fileStr), 'file'))
        load(fullfile(path, sceneStruct.name, fileStr));
    else
        v = rgb2gray(sceneStruct.im);
        % downsize images for quicker analysis
        downsized = imresize(v, [calcParams.downsample, NaN]);
        
        
        if (calcParams.usedepth)
            interp = inpaint_nans(sceneStruct.depth, 3);
            depth = imresize(interp, [calcParams.downsample, NaN]);             
        else
            depth = zeros(size(downsized));  % without depth map
        end
   
        % run images through brain model
        modelResp = calcModel(downsized, depth, calcParams);
        sceneFolderStr = fullfile(path, sceneStruct.name);
        
        if (~exist(sceneFolderStr, 'dir'))
            mkdir(sceneFolderStr);
            addpath(sceneFolderStr);
        end
        save(fullfile(sceneFolderStr, fileStr), 'modelResp');
    end
end
function output = calcModel(image, depth, calcParams)
    rgcResponse = model_RGCResponse(image, depth, calcParams.arcmin_ppx, calcParams.rgcType);
    m = main_getModel;
    output = calcModelResponse(m, rgcResponse);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcAndStoreCorrelations(image)

% for now we exclude ut images
if isempty(strfind(image.name,'ut_'))
    
    %store the original and manipulated luminance/depth correlations
    imY = rgb2gray(image.imRGB.^2.2);
    imYnew = rgb2gray(image.imRGBnew.^2.2);
    
    corrOrig = corr(image.imZOrig(~isnan(image.imZOrig)), imY(~isnan(image.imZOrig)));
    corrNew = corr(image.imZOrig(~isnan(image.imZOrig)), imYnew(~isnan(image.imZOrig)));
    
    if exist('luminanceDepthCorrelations.mat', 'file')
        load('luminanceDepthCorrelations.mat');
        ind = find(ismember(corrDat.scene, image.loadpath));
        if isempty(ind)
            ind = length(corrDat.scene) + 1;
        end
    else
        ind = 1;
    end
    
    corrDat.scene{ind} = image.loadpath;
    corrDat.corrOrig(ind) = corrOrig;
    switch image.flag
        case'tp'
            corrDat.corrTP(ind) = corrNew;
        case 'ap'
            corrDat.corrAP(ind) = corrNew;
        otherwise
            %do nothing yet
    end
    
    save('luminanceDepthCorrelations.mat', 'corrDat')
    
    %store the original and manipulated imag variances
    if exist('luminanceDepthVariances.mat', 'file')
        load('luminanceDepthVariances.mat');
        ind = find(ismember(varDat.scene, image.loadpath));
        if isempty(ind)
            ind = length(varDat.scene) + 1;
        end
    else
        ind = 1;
    end
    
    varDat.scene{ind} = image.loadpath;
    varDat.varOrig(ind) = var(imY(:));
    switch image.flag
        case 'tp'
            varDat.varTP(ind) = var(imYnew(:));
        case'ap'
            varDat.varAP(ind) = var(imYnew(:));
        otherwise
            % do nothing yet
    end
    
    save('luminanceDepthVariances.mat', 'varDat');
end

end

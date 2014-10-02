function pred = image_pyramid(image,paths)
%
% analyze the predictiveness of coarse to fine luminance/depth correlation for
% perceptual responses

%pyramids = {'Laplacian', 'Wavelet', 'Steerable'};       % different methods for coarse-to-fine scale
pyramids = {'Laplacian'};
max_levels = 5;                                         % number of coarse-to-fine levels

for x = 1:length(image)
    

    pyr_orig    = pyrAnalysis(image(x).orig, image(x).depth, max_levels, pyramids);
    pyr_enh    = pyrAnalysis(image(x).enh, image(x).depth, max_levels, pyramids);
    pyr_deg    = pyrAnalysis(image(x).deg, image(x).depth, max_levels, pyramids);

    pred.enh_deg(:, x) = -(pyr_enh.ld_corr - pyr_deg.ld_corr);
    pred.enh_orig(:, x) = -(pyr_enh.ld_corr - pyr_orig.ld_corr);
    pred.orig_deg(:, x) = -(pyr_orig.ld_corr - pyr_deg.ld_corr);
 
end

save([paths.results '/image_pyramid_results_picture.mat'],'pred')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function pyr = pyrAnalysis(image, depth, max_levels, pyramids)
% Function builds three pyramids(laplacian, wavelet, steerable)
% for image.imRGB, then reconstructs at each level and correlates with the depth map
% returns structure pyr.ld_corr(nPyramids, nLevels), pyr.mean_lum, pyr.sf


    %% check if toolbox is loaded
    if ( ~exist('buildWpyr', 'file'))
        error('matlabPyrTools is not linked, please add toolbox to the path');
    end
    
    %disp('WARNING: this function requires patched reconSpyr.m. Please unlink other versions of matlabPyrTools');
    
    try
        nPyrs = numel(pyramids);
        
        %arrays for storing correlation values
        pyr.ld_corr = NaN(nPyrs, max_levels); 
        pyr.mean_lum = zeros(nPyrs, max_levels);        
        pyr.sf = zeros(nPyrs, max_levels);            
        
        im = rgb2gray(image.RGB.^(2.2));                    % convert image to gamma-removed grayscale
        %use only valid (~NaN) values for conv            
        validIdx = ~isnan(depth);
        depth = depth(validIdx);
          
        %% build/reconstruct in laplacian, wavelet, steerable pyramids
        for p = 1:nPyrs
            type = pyramids{p};
            [pIm, pInd] = buildPyr(type, im, max_levels);
            height = pyrHeight(type, pInd);
            for level = 1:height
                lum = reconPyr(type, pIm, pInd, level);
                pyr.ld_corr(p, level) = corr(depth, lum(validIdx));
                pyr.mean_lum(p, level) = mean(mean(normM(lum)));
                pyr.sf(p, level) = getSFreq(type, pIm, pInd, level);
            end
         end
            
    catch err
        disp('pyrAnalysis:Error');
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end

% nested local functions
function [pyrIM, pyrInd] =  buildPyr(ptype, im, height)
    switch ptype
        case 'Laplacian'
            [pyrIM, pyrInd] = buildLpyr(im, height);
        case 'Wavelet'
            [pyrIM, pyrInd] = buildWpyr(im, height);
        case 'Steerable'
            [pyrIM, pyrInd] = buildSpyr(im, height);
        otherwise
            pyrIM = 0; 
            pyrInd = 0;
    end

function img = reconPyr(ptype, pyrIm, pyrInd, level)
    switch ptype
        case 'Laplacian'
            img = reconLpyr(pyrIm, pyrInd, level);
        case 'Wavelet'
            img = reconWpyr(pyrIm, pyrInd, 'qmf9', 'reflect1', level, 'all');
        case 'Steerable'
            img = reconSpyr(pyrIm, pyrInd, 'sp1Filters', 'reflect1', level, 'all');
        otherwise
            img = 0;
    end     

function height = pyrHeight(ptype, pyrInd)
    switch ptype
        case 'Laplacian'
            height = floor(lpyrHt(pyrInd));
        case 'Wavelet'
            height = floor(wpyrHt(pyrInd));
        case 'Steerable'
            height = floor(spyrHt(pyrInd));
        otherwise
            height = 0;
    end

function sf = getSFreq(ptype, pyrIm, pyrInd, level)
    switch ptype
        case 'Laplacian'
            sf = 1/pyrInd(level, 2);
        case 'Wavelet'
            sf = 1/size(wpyrBand(pyrIm, pyrInd, level), 2);
        case 'Steerable'
            sf = 1/size(spyrBand(pyrIm, pyrInd, level), 2);
        otherwise
            sf = 0;
    end




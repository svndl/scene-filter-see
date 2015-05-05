function pyr = pyrAnalysis(im, d, max_levels, pyramids)
% Function builds three pyramids(laplacian, wavelet, steerable)
% for image.imRGB, then reconstructs at each level and correlates with the depth map
% returns structure pyr.ld_corr(nPyramids, nLevels), pyr.mean_lum, pyr.sf


    %% check if toolbox is loaded
    if ( ~exist('buildWpyr', 'file'))
        error('matlabPyrTools is not linked, please add toolbox to the path');
    end
    
    disp('WARNING: this function requires patched reconSpyr.m. Please unlink other versions of matlabPyrTools');
    
    try
        nPyrs = numel(pyramids);
        
        %arrays for storing correlation values
        pyr.ld_corr = NaN(nPyrs, max_levels); 
        pyr.mean_lum = zeros(nPyrs, max_levels);        
        pyr.sf = zeros(nPyrs, max_levels);            
        
        %use only valid (~NaN) values for conv            
        validIdx = ~isnan(d);
        depth = d(validIdx);
          
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
    disp('done');    
end

% nested local functions
function [pyrIM, pyrInd] =  buildPyr(ptype, im, height)
    switch ptype
        case {'l', 'L', 'Laplacian'}
            [pyrIM, pyrInd] = buildLpyr(im, height);
        case {'w', 'W', 'Wavelet'}
            [pyrIM, pyrInd] = buildWpyr(im, height);
        case {'s', 'S', 'Steerable'}
            [pyrIM, pyrInd] = buildSpyr(im, height);
        otherwise
            pyrIM = 0; 
            pyrInd = 0;
    end
end
function img = reconPyr(ptype, pyrIm, pyrInd, level)
    switch ptype
        case {'l', 'L', 'Laplacian'}
            img = reconLpyr(pyrIm, pyrInd, level);
        case {'w', 'W', 'Wavelet'}
            img = reconWpyr(pyrIm, pyrInd, 'qmf9', 'reflect1', level, 'all');
        case {'s', 'S', 'Steerable'}
            img = reconSpyr(pyrIm, pyrInd, 'sp1Filters', 'reflect1', level, 'all');
        otherwise
            img = 0;
    end     
end
function height = pyrHeight(ptype, pyrInd)
    switch ptype
        case {'l', 'L', 'Laplacian'}
            height = 1 + floor(lpyrHt(pyrInd));
        case {'w', 'W', 'Wavelet'}
            height = floor(wpyrHt(pyrInd));
        case {'s', 'S', 'Steerable'}
            height = floor(spyrHt(pyrInd));
        otherwise
            height = 0;
    end
end
function sf = getSFreq(ptype, pyrIm, pyrInd, level)
    switch ptype
        case {'l', 'L', 'Laplacian'}
            sf = 1/pyrInd(level, 2);
        case {'w', 'W', 'Wavelet'}
            sf = 1/size(wpyrBand(pyrIm, pyrInd, level), 2);
        case {'s', 'S', 'Steerable'}
            sf = 1/size(spyrBand(pyrIm, pyrInd, level), 2);
        otherwise
            sf = 0;
    end
end
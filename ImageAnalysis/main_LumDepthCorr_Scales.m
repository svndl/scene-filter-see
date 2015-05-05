function main_LumDepthCorr_Scales(varargin)

    close all;
    %main experiment
    if (nargin == 0 )
        path = main_setPath_Analysis;
    else
        path = varargin{1};
    end
    % by default, load all scenes 
    if (nargin == 2)
        [img, ~] = main_getRatedScenes;        
    else
        img = main_getAllScenes;
    end
    pyr.type = {'Laplacian'};
    pyr.height = 5;
    
    pyrs = mkScaleDecomposition(img, pyr, path.results);
    plot_allScaleDecomp(pyrs, path.results);
end
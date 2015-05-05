function main_LumDepthCorr_Percept(varargin)

    close all;
    %main experiment
    if (nargin == 0 )
        %results will be saved in Analysis/results folder 
        path = main_setPath_Analysis;
    else
        path = varargin{1};
    end
    
    if (nargin > 1)
        exp_type = varargin{2};
    else
        exp_type = 'vep';
    end
    
    [img, percept] = main_getRatedScenes(exp_type);
    
    f = figure;
    switch exp_type
        case 'ssvep'
            main_plot(f, img.lum_enh_deg, percept.enh_deg, 'Enhanced>Degraded', 'Lum-depth correlation', 'Rating, % more 3D', 'r', 1, 3);
            main_plot(f, img.lum_enh_orig, percept.enh_orig, 'Enhanced>Original', 'Lum-depth correlation', 'Rating, % more 3D', 'b', 2, 3);            
            main_plot(f, img.lum_orig_deg, percept.orig_deg, 'Original>Degraded', 'Lum-depth correlation', 'Rating, % more 3D', 'y', 3, 3);
        case 'vep'
            main_plot(f, img.lum_enh_orig, percept.enh_orig, 'Enhanced>Original', 'Lum-depth correlation', 'Rating, % more 3D', 'r');            
        otherwise
    end
    
    filename = ['Luminance-depth correlation ' exp_type ' perceptual results.pdf'];
    try
        export_fig(fullfile(path.results, filesep, filename));
    catch
        saveas(f, fullfile(path.results, filesep, filename));
    end
end
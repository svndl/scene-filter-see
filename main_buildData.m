function main_buildData(varargin)
%function will calculate supplemental data matrices 

    if (nargin == 0)
        data_type = 'all';
    else
        data_type = varargin{1};
    end
    
    path = main_setPath;
    
    switch data_type
        case 'ratings'
            main_getRatedScenes('vep')
            main_getRatedScenes('ssvep');
        case 'mat-scenes'
            main_manipulateLuminance_dir(path.images);            
        case 'experiment'
            main_generateStimSet;
        case 'all'
            main_buildData('mat-scenes');            
            main_buildData('ratings');
            %main_buildData('experiment');            
        otherwise
    end
end
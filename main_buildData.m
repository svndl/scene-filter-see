function main_buildData(varargin)
%function will calculate supplemental data matrices 

    data_type = 'all';
    if (nargin > 0)
        data_type = varargin{1};
    end
    path = main_setPath;
    
    switch data_type
        case 'ratings'
            main_getRatedScenes('ssvep', 'anything')
            main_getRatedScenes('vep', 'Middlebury');
            main_getRatedScenes('vep', 'Live3D');            
        case 'mat-scenes'
            main_manipulateLuminance_dir(path.manipulation);  
        case 'experiment'
            %main_generateStimSet('mb');
            main_generateStimSet('ut');
        case 'all'
            main_buildData('mat-scenes');            
            main_buildData('ratings');
            main_buildData('experiment');            
        otherwise
    end
end
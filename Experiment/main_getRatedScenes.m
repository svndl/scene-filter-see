function [img, ratings] = main_getRatedScenes(type, database)
   
    path = main_setPath_Experiment;
  
    switch type
        case {'experiment1', 'ssvep'}
            [img, ratings] = load_PerceptualData_SSEP(path);
        case {'experiment2', 'vep'}
            [img, ratings] = load_PerceptualData_VEP(path, database);
        otherwise
    end
end
            

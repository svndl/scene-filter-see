function [img, ratings] = main_getRatedScenes(type)
   
    path = main_setPath_Experiment;
  
    switch type
        case 'ssvep'
            [img, ratings] = load_PerceptualData_SSEP(path);
        case 'vep'
            [img, ratings] = load_PerceptualData_VEP(path);
        otherwise
    end
end
            

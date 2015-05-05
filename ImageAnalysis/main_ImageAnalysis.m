function main_ImageAnalysis(varargin)
    
    if (nargin == 0)
        type = 'ssvep';
    end
    type = varargin{1};
    
    path = main_setPath_Experiment; 
    [img, percept] = main_getRatedScenes(type);
    
    
end
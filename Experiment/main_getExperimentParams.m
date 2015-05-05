function p = main_getExperimentParams(varargin)
    if (nargin == 0)
        exp_type = 'ssvep';
        
    else
        exp_type = varargin{1}; 
    end
        
    p.type = exp_type;
    
    p.display_res = [1920, 1080];
    p.display_param = [543.4, 305.6]; %mm
    switch exp_type
        case 'ssvep'
            p.vd = 700; % viewing distance, mm
            p.imW = 580; % image width, pix
            
        case 'vep'
            p.vd = 1190; % viewing distance, mm
            p.imW = 1920; %image width, pix;
        otherwise
            %do nothing
    end;
    
    % if second argument is provided, use it as image size    
    if (nargin > 1)
        p.imW = varargin{2};
    end;
    
    ex = p.display_param.*p.imW./p.display_res;
    p.arcmin_per_pixel = 2*pi*atan2(ex(1), p.vd);            
end





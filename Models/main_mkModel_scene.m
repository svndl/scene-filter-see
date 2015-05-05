function main_mkModel_scene(varargin)

% Function will create a disparity model for given varargin. Results will
% be saved as matlab structures (mat-files) in /Results.

% Examples
% 1) main_mkModel_scene(filename)
% Function will first try to load '/ImageManipulation/Data/filename.mat'
% If file is not found, will attempt to look for filename in /SrcData/filename
% and use /ImageManipulation routines for loading

% Models will be created for filename.imRGB and filename.imRGBNew.
% results will be saved in /Results/filename_disparity.mat

% 2) main_mkModel_scene(image_matrix)
% results will be saved in Results /

% 3) main_mkModel_scene(path_to_)
    path = main_setPath_Model;
        
    keywords = {'mb', 'live', 'ut'};
    if (nargin == 0)
       [filename, pathname] =  uigetfile(filesep, 'Select the input to disparity model');
       input_arg = [pathname filename];
    else
        if (ischar(varargin{1}))
            
            %see if the inout arg is a keyword(stereo scene)
            [~, id_arg, ~] = fileparts(strtok(varargin{1}, '_'));
            
            %request to load image from 3D database
            if sum(strcmp(id_arg, keywords))
                input_arg = [varargin{1} '.mat'];
            end
            
        elseif()
        else
            disp('File not recognized, exiting');
            return;
        end
    end
    
    
    data_matrix = parce_input_arg(input_arg, path);
    brain = calc_Model(data_matrix);
    saveModel(brain);
end

function data_matrix = parce_input_arg(input_arg, path)
% function will parce input argument
% and perform nessesary calculations on provided data
% output is a data matrix
    [~, ~, file_ext] = fileparts(input_arg);
    switch (file_ext)
        case {'.mat'}
            try
                input_data = load(input_arg);
            catch err
                input_data = main_manipulateLuminance_scene(input_arg);
            end
        case {'.jpeg', '.jpg', '.png'}
            input_matrix = imread(input_arg);
        otherwise
    end
end

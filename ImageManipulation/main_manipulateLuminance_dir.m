function main_manipulateLuminance_dir(varargin)

% This function runs the manipulatLuminance function on all scenes

% main_runEnhancement(), example of standalone call (no arguments provided), 
% function will ask to select a directory with source images
% result will be stored on the same level as the script in the /Results
% directory. Additional data will be calculated and stored in /Data folder 
% 

% main_runEnhancement(src_dir, dest_dir), example of externall call, 
% src_dir -- absolute path to stereo images folder
% dest_dir -- absolute path to external results folder.
% 
% Emily Cooper, Alexandra Yakovleva, Stanford University 2014
    
    %% I. Arguments to run the actual enhancement
    
    
    path = main_setPath_Manipulation;
    manipulationFlags = {'tp'};
    
    if (nargin ==0)
        %standalone call
        user_source = uigetdir('/');
        
        %check if user input is valid
        if (exist(user_source, 'dir'))
            path.source = user_source;
        end
        
        %default flag
        manipulationFlags = {'tp'};
    else
%         path.source = varargin{1};
%         path.results = varargin{2};
        try
            if (~exist(path.results, 'dir'))
                mkdir(path.results);
            end
        catch
            err_string = ['Error running image manipulation, unable to access directory: ' varargin{1}]; 
            disp(err_string);
        end
    end
 
    try
        listing = dir(path.source);
    catch
        err_string = ['Error creating a list for ' path.source];
        disp(err_string);
    end
    
    
    for m = 1:length(manipulationFlags)
    
        for l = 1:length(listing)
        
            if ~strcmp(listing(l).name(1),'.') && (listing(l).isdir) %only directories
                path_to_scene = [path.source '/' listing(l).name];
                main_manipulateLuminance_scene(path_to_scene, manipulationFlags{m});
            end
        end
    end


function [] = manipulateLuminanceAllImages()

% This function runs the manipulatLuminance function on all scenes
% contained in the Images/Originals directory

% Emily Cooper, Stanford University 2014
    path = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';
    
    %store luminance/depth correlation of original and manipulation in a mat file
    calcAndStoreCorrelations = 0;
    manipulationFlags = {'tp', 'ap'};
    listing = dir(path);

    for m = 1:length(manipulationFlags)
    
        for l = 1:length(listing)
        
            if ~strcmp(listing(l).name(1),'.') %only red directories
                display([listing(l).name ' manipulating ' manipulationFlags{m}]);
                res = manipulateLuminance(strcat(path, '/', listing(l).name), manipulationFlags{m});
                saveImages(res, calcAndStoreCorrelations);        
            end
        end
    end


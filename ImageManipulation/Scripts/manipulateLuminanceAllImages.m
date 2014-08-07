function [] = manipulateLuminanceAllImages()

% This function runs the manipulatLuminance function on all scenes
% contained in the Images/Originals directory

% Emily Cooper, Stanford University 2014


manipulationFlags = {'tp','ap'};

listing = dir('../Images/Originals/');

for m = 1:length(manipulationFlags)
    
    for l = 1:length(listing)
        
        if ~strcmp(listing(l).name(1),'.') %only red directories
            display([listing(l).name ' manipulating ' manipulationFlags{m}]);
            manipulateLuminance(listing(l).name,manipulationFlags{m})
        end
    end
end


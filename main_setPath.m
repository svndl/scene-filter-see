function path = main_setPath
    %
    % add all scene-filter-see subfolders to your path
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    path.home = curr_path;
    addpath(path.home);

    

    path.images   = fullfile(path.home, 'SrcData');
    path.manipulation = fullfile(path.home, 'ImageManipulation');
    path.analysis = fullfile(path.home, 'ImageAnalysis');
    path.models = fullfile(path.home, 'Models');    
    path.results = fullfile(path.home, 'Results');
    path.experiment =  fullfile(path.home, 'Experiment');
end
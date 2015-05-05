function path = main_setPath_Model
    %
    % add contents of curent folder to MATLAB path
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    path.home = curr_path;
    addpath(path.home);
    slash_idx = strfind(curr_path, filesep);
    up_dir = curr_path(1:slash_idx(end));
    
    %default source location
    path.source   = [up_dir 'SrcData'];
    
    %location for matfiles
    path.metadata   = fullfile(path.home, 'Data');
    %location for results  
    path.results = fullfile(path.home, 'Results');
    
    if (~exist(path.metadata, 'dir'))
        mkdir(path.metadata);
    end
    if (~exist(path.results, 'dir'))
        mkdir(path.results);
    end
end
function path =  main_setPath_Manipulation

    %
    % add all scene-filter-see subfolders to your path
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    path.home = curr_path;
    addpath(path.home);
    slash_idx = strfind(curr_path, '/');
    up_dir = curr_path(1:slash_idx(end));
    
    %default source location
    path.source   = [up_dir 'SrcData'];
    
    %location for matfiles
    path.metadata   = [path.home '/Data'];
    %location for results  
    path.results = [path.home '/Results'];
    
    if (~exist(path.metadata, 'dir'))
        mkdir(path.metadata);
    end
    if (~exist(path.results, 'dir'))
        mkdir(path.results);
    end
end




function path =  main_setPath_Experiment
    %
    % add all scene-filter-see subfolders to your path
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    path.home = curr_path;
    addpath(path.home);
    filesep_idx = strfind(curr_path, filesep);
    up_dir = curr_path(1:filesep_idx(end));
    
    %default source location
    path.images   = [up_dir 'SrcData'];
    
    %location for matfiles
    path.metadata   = [path.home filesep 'Data'];
    path.metadata_eeg = [path.metadata filesep 'EEG'];
    path.metadata_gui_scenes = [path.metadata filesep 'guiMatScenes'];
    path.metadata_exp1 = [path.metadata filesep 'PerceptualExperiment_I'];
    path.metadata_exp2 = [path.metadata filesep 'PerceptualExperiment_II'];
    
    
    %location for results  
    path.results = [path.home filesep 'Results'];
    path.results_scenes = [path.results filesep 'XDivaStimsets'];

    if (~exist(path.metadata, 'dir'))
        mkdir(path.metadata);
    end
    if (~exist(path.results, 'dir'))
        mkdir(path.results);
    end
end
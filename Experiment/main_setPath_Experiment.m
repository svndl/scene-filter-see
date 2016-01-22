function ePath =  main_setPath_Experiment
    %
    % add all scene-filter-see subfolders to your path
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    ePath.home = curr_path;
    filesep_idx = strfind(curr_path, filesep);
    up_dir = curr_path(1:filesep_idx(end));
    
    %default source location
    ePath.images   = [up_dir 'SrcData'];
    
    %location for matfiles
    ePath.metadata   = [ePath.home filesep 'Data'];
    ePath.matimages = [up_dir 'ImageManipulation' filesep 'Data'];
    ePath.metadata_eeg = [ePath.metadata filesep 'EEG'];
    ePath.metadata_gui_scenes = [ePath.metadata filesep 'guiMatScenes'];
    ePath.metadata_exp1 = [ePath.metadata filesep 'PerceptualExperiment_I'];
    ePath.metadata_exp2 = [ePath.metadata filesep 'PerceptualExperiment_II'];
    
    
    %location for results  
    ePath.results = [ePath.home filesep 'Results'];
    ePath.results_scenes = [ePath.results filesep 'XDivaStimsets'];

    if (~exist(ePath.metadata, 'dir'))
        mkdir(ePath.metadata);
    end
    if (~exist(ePath.results, 'dir'))
        mkdir(ePath.results);
    end
end
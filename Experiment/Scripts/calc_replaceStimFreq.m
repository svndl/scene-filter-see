function calc_replaceStimFreq
    path = main_setPath_Experiment;
    
    dbtype = 'ut';
    xDivaStimList = dir([mpath.results_scenes filesep dbtype filesep '*.mat']);
    
    freq = 0.5;
    
    newTotalFrames = calc_XDivaMatlabParadigm(freq);
    framesPerImg = newTotalFrames/4;
    imageSequence = uint32(zeros(newTotalFrames, 1));
    imageSequence(1, 1) = 1;
    imageSequence(framesPerImg + 1, 1) = 2;
    imageSequence(2*framesPerImg + 1, 1) = 3;
    imageSequence(3*framesPerImg + 1, 1) = 4;    
    % waiting for the subject's response, make the last frame a black X
    imageSequence(newTotalFrames, 1) = 1;    

    
    for i = 1:numel(xDivaStimList)
        filepath = [path.results.scenes '/' xDivaStimList(i).name];
        replace_imSequence(imageSequence, filepath);
    end
end


function replace_imSequence(new_imSequence, path_to_file)

    disp(['replacing ' path_to_file])
    load(path_to_file);
    imageSequence = new_imSequence;
    save(path_to_file, 'images', 'imageSequence');
end


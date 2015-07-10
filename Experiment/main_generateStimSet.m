function main_generateStimSet(type)
     
    path = main_setPath_Experiment;
    path.results_scenes = [path.results_scenes filesep type];
    %by default, use SRC scenes!
    
    if (~exist(path.results_scenes, 'dir'))
        mkdir(path.results_scenes);
    end
    
    listOfScenes = dir([path.images filesep type '*']);
    rndScenes = randperm(numel(listOfScenes));
    generateAll(listOfScenes, rndScenes, path);

end

function generateAll(listOfScenes, rndScenes, path)
    nStereo = numel(listOfScenes);
    
    i = 1;
    roosterName = strcat(path.results_scenes, filesep, 'ScenesAllCND.txt');
    f = fopen(roosterName, 'w+');
    while i <= nStereo
                
        num = rndScenes(i);
        list_name = listOfScenes(num).name;        
        disp(['Generating ' list_name]);
        
        fprintf(f, 'Conditions SO:OS, SE:ES, EO:OE Trial %d Scene %s\n', i, list_name);
        
        grey = 0;
        
        [sceneS, sceneE, sceneO, blank] = make_GetAllVersions(list_name, path, grey);
              
        %% SO, OS trials
        write_XDivaStim(path.results_scenes, blank, sceneS, blank, sceneO, 'SO', i);
        write_XDivaStim(path.results_scenes, blank, sceneO, blank, sceneS, 'OS', i);
 
        %% SE, ES trials
        write_XDivaStim(path.results_scenes, blank, sceneS, blank, sceneE, 'SE', i);
        write_XDivaStim(path.results_scenes, blank, sceneE, blank, sceneS, 'ES', i);

        %% EO, OE trials
        write_XDivaStim(path.results_scenes, blank, sceneE, blank, sceneO, 'EO', i);
        write_XDivaStim(path.results_scenes, blank, sceneO, blank, sceneE, 'OE', i); 
        i = i + 1;
    end
    fprintf(f, 'Set generated on %s', datestr(clock));   
    fclose(f);
end
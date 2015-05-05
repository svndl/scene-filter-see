function main_generateStimSet
    
    if (~exist('xDIvaStim', 'dir'))
        mkdir('xDIvaStim')
    end
    
    path = main_setPath_experiment;
    listOfScenes = dir([path.metadata_gui_scenes filesep type '*']);

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
        disp(['Generating ' listOfScenes(num).name]);
        fprintf(f, 'Conditions SO:OS, SE:ES, EO:OE Trial %d Scene %s\n', i, listOfScenes(num).name);
        
        grey = 0.5; 
        [sceneS, sceneE, sceneO, blank] = make_GetAllVersions(listOfScenes(num).name, path, grey);
              
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
% function GenerateCondition(scenes, ConditionType, rndScenes)
%     
%     nStereo = numel(scenes);
%     
%     i = 1;
%     roosterName = ['XDivaStim/ScenesList' ConditionType '.txt'];
%     f = fopen(roosterName, 'w+');
%     while i <= nStereo
%                 
%         num = rndScenes(i);
%         
%         fprintf(f, 'Condition %s  Trial %n Scene %s\n', ConditionType, i, scenes{num}.name);
%         %% Work on sceneA
%         
%         [leftA, rightA] = prepScene(scenes{num}, ConditionType(1));
%         [leftB, rightB] = prepScene(scenes{num}, ConditionType(2));
%         [blankA, sceneA] = constructScene(leftA, rightA, ConditionType(1));
%         [blankB, sceneB] = constructScene(leftB, rightB, ConditionType(2));
%         createXDivaMatStim('XDivaStim', blankA, sceneA, blankB, sceneB, ConditionType, i);
%         
%           i = i + 1;
%     end
%     fprintf(f, 'Set generated on %s', datestr(clock));   
%     fclose(f);
% end





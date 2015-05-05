function scenes = load_SceneModel(exp_type, size)
    path = main_setPath_Model;
    subList = dir(fullfile(path.results,type));
    
    nS = length(subList);
    scenes = cell(nS, 1);
    
    for i = 1:nS
        try
            filename = strcat(xDivaMatPath, filesep, subList(i).name);
            scenes{i} = load(filename);
        catch
            % figure out filename (remove gui_ prefix and *.mat extension)
            [~, p2] = strtok(subList(i).name, '_');
            filename = p2(2:end - 4);
            image_path = strcat(path.images, filesep, filename);
            scenes{i} = main_manipulateLuminance_scene(image_path, 'tp');
        end
    end
end
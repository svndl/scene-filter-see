function scenes = load_XDivaScene(type)    
    path = main_setPath_Experiment;

    %% first, look for the gui scenes
    search_path = path.metadata_gui_scenes;
    subList = dir([search_path filesep 'gui_' type '*']);
    dataType = 'gui';
    
    %% no gui scenes, check mat scenes folder
    if (isempty(subList))
        search_path =  path.matimages;
        subList = dir([search_path filesep type '*']);
        dataType = 'mat';
    end
    
    %% no mat scenes, select/manipulate folders from src 
    if (isempty(subList))
        search_path =  path.images;
        subList = dir([search_path filesep type '*']);
        dataType = 'src';
    end
    if (~isempty(subList))
        s = loadListElements(search_path, subList, dataType);
    end
    scenes = s(~cellfun(@isempty, s));
 end

function s = loadListElements(path, list, dataType)
    nS = length(list);
    s = cell(nS, 1);
    
    for i = 1:nS
        try
            filename = strcat(path, filesep, list(i).name);                            
            switch dataType
                case {'gui', 'mat'}
                    s{i} = load(filename);          
                case 'src'
                    s{i} = main_manipulateLuminance_scene(filename, 'tp');
                otherwise
            end
        catch
            %do nothing, we'll remove empty cells afterwards
        end
    end
end

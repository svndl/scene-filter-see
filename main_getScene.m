function img = main_getScene(varargin)   
    
    
    path = main_setPath;
    scene_name = varargin{1};
    scene_type = varargin{2};
    
    loadpath = fullfile(path.images, scene_name);
    switch scene_type
        case 'orig'
            try
                scene = load([scene_name '.mat']);
            catch
                scene = load_readScene(loadpath);
            end
            img.RGB = scene.imRGB;
            img.imZ = scene.imZ;
            img.name = scene_name;
        case 'enh'
            try
                scene = load([scene_name '.mat']);
            catch
                scene = main_manipulateLuminance_scene(loadpath, 'tp');                
            end
            img.RGB = scene.imRGBnew;
            img.imZ = scene.imZ;
            img.name = scene_name;
        case 'deg'
            % DO NOT save the ap version  
            scene = edit_manipulateScene(loadpath, 'ap');
            img.RGB = scene.imRGBnew;
            img.imZ = scene.imZ;
            img.name = scene_name;
        otherwise
            main_getScene(scene_name, 'orig');
    end
end
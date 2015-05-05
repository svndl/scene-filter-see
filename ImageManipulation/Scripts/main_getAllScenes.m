function img = main_getAllScenes()
   
    path = main_setPath_Manipulation;
  
 
    if(~exist('AllScenes.mat', 'file'))
        % load mat-file w. perceptual experiment data
        %check what scenes we have in path.metadata
        scenes_list = mkDirList(fullfile(path.source));
        allImages = numel(scenes_list);
        img.names = cell(allImages, 1);
        img.enh = cell(allImages, 1);
        img.deg = cell(allImages, 1);
        img.orig = cell(allImages, 1);
        img.depthmap = cell(allImages, 1);
        for x = 1:allImages
            display(['Loading ' scenes_list(x).name '...']);
                
            % compute percent more 3D for each comparison

            % get image and depth map for analysis
            scene_name = scenes_list(x).name;
            scene_enh = main_getScene(scene_name, 'enh');
            scene_deg = main_getScene(scene_name, 'deg');
            scene_orig = main_getScene(scene_name, 'orig');
            %crop the scenes
                
            img.orig{x} = scene_orig;
            img.enh{x} = scene_enh;
            img.deg{x} = scene_deg;
            img.depthmap{x} = scene_orig.imZ;
            img.names{x} = scene_name;
        end
        save(fullfile(path.metadata, 'AllScenes.mat'), '-v7.3', 'img');
    else
        load(fullfile(path.metadata, 'AllScenes.mat'));
    end
end
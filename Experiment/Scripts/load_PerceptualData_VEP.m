function [img, ratings] = load_PerceptualData_VEP(path, database, varargin)
    
    processed_file = fullfile(path.metadata, database, 'RatedScenes_VEP.mat');
    if(~exist(processed_file, 'file'))
        
        %default parameters
        cnd = 'EO';
        
        % 'sceneList', 'respMatrix', 'sceneCount'
        if (~isempty(varargin))
            cnd = varargin{1};
        end
        
        
        try
            load([fullfile(path.results, database, cnd) '.mat']);
        catch
            main_processResponses(database)
            load([fullfile(path.results, database, cnd) '.mat']);            
        end
        
        ratedImages = length(sceneList);
        %set up structure to keep the rated scenes info
        img.enh = cell(ratedImages, 1);
        img.orig = cell(ratedImages, 1);

        img.depthmap = cell(ratedImages, 1);
        img.lum_enh_orig = zeros(ratedImages, 1);
        
        ratings.enh_orig = 100*respMatrix./sceneCount;
        
        for x = 1:ratedImages
            display(['Loading ' sceneList{x} '...']);
            
            % compute percent more 3D for each comparison
            % get image and depth map for analysis
            scene_enh = main_getScene(sceneList{x}, 'enh');
            scene_orig = main_getScene(sceneList{x}, 'orig');
            %crop the scenes

            img.orig{x} = scene_orig.RGB;
            img.enh{x} = scene_enh.RGB;
            
            img.depthmap{x} = scene_orig.imZ;
            img.names{x} = sceneList{x};
            img.lum_enh_orig(x) = ld_corr(scene_enh.RGB, scene_orig.imZ) - ld_corr(scene_orig.RGB, scene_orig.imZ);
        end
        if (~exist(fullfile(path.metadata, database), 'dir'))
            mkdir(fullfile(path.metadata, database));
        end
        save(fullfile(path.metadata, database, 'RatedScenes_VEP.mat'), '-v7.3', 'img', 'ratings');
    else
        load(fullfile(path.metadata, database, 'RatedScenes_VEP.mat'));
    end
end

function val = ld_corr(imRGB, depth)

    validIDx = ~isnan(depth);
    imV = rgb2gray(imRGB);
    val = corr(imV(validIDx), depth(validIDx));
end

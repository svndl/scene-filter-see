function [img, ratings] = load_PerceptualData_SSEP(path)

    if(~exist('RatedScenes_SSEP.mat', 'file'))

        exp  = load('mainExperimentData.mat');  % load mat-file w. all perceptual experiment data
        % shortcut for trials
        dat = exp.data;
        trl = dat.trials;
        % load mat-file w. perceptual experiment data
        ratedImages = length(dat.scenesListSorted);
        %set up structure to keep the rated scenes info
        img.enh = cell(ratedImages, 1);
        img.deg = cell(ratedImages, 1);
        img.orig = cell(ratedImages, 1);
        img.depthmap = cell(ratedImages, 1);
        img.lum_enh_deg = zeros(ratedImages, 1);
        img.lum_enh_orig = zeros(ratedImages, 1);
        img.lum_orig_deg = zeros(ratedImages, 1);
        
        ratings.enh_deg = zeros(ratedImages, 1);
        ratings.orig_deg = zeros(ratedImages, 1);
        ratings.enh_orig = zeros(ratedImages, 1);
        
        for x = 1:ratedImages
            display(['Loading ' dat.scenesListSorted{x} '...']);
                
            % compute percent more 3D for each comparison
            [percept, luminance] = calc_perceptScene(dat, trl, x);
            % get image and depth map for analysis
            scene_enh = main_getScene(dat.scenesListSorted{x}, 'enh');
            scene_deg = main_getScene(dat.scenesListSorted{x}, 'deg');
            scene_orig = main_getScene(dat.scenesListSorted{x}, 'orig');
            %crop the scenes
            cropped_orig = cropToSquare(scene_orig);
            cropped_enh = cropToSquare(scene_enh);
            cropped_deg = cropToSquare(scene_deg);

            img.orig{x} = cropped_orig.imRGB;
            img.enh{x} = cropped_enh.imRGB;
            img.deg{x} = cropped_deg.imRGB;
            img.depthmap{x} = cropped_orig.imZ;
            img.names{x} = dat.scenesListSorted{x};

            img.lum_enh_deg(x) = luminance.enh_deg;
            img.lum_enh_orig(x) = luminance.enh_orig;
            img.lum_orig_deg(x) = luminance.orig_deg;
        
            ratings.enh_deg(x) = percept.enh_deg;
            ratings.enh_orig(x) = percept.enh_orig;
            ratings.orig_deg(x) = percept.orig_deg;
        end
        save(fullfile(path.metadata, 'RatedScenes_SSEP.mat'), 'img', 'ratings');
    else
        load(fullfile(path.metadata, 'RatedScenes_SSEP.mat'));
    end
end

function im = cropToSquare(im_struct)

    [sx, sy , ~] = size(im_struct.RGB);
    minDim = floor(0.5*min(sx, sy));
    imcenter = floor(0.5*([sx, sy]));
    im.imRGB = im_struct.RGB(imcenter(1) - minDim + 1:imcenter(1) + minDim, imcenter(2) - minDim + 1:imcenter(2) + minDim, :);
    im.imZ = im_struct.imZ(imcenter(1) - minDim + 1:imcenter(1) + minDim - 1, imcenter(2) - minDim + 1:imcenter(2) + minDim - 1);
    im.name = im_struct.name;
end
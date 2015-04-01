function do_analysis
%
% Run either model-based of image-based approach analysis
%
% Current approach options are:
%
%   1 ->'image_correlation'     - runs image-based luminance/depth correlation analysis
%   2 ->'image_pyramid'         - runs image-based coarse-to-fine depth correlation analysis
%   3 ->'model_brain_picture' 	- runs brain response based analysis modeling picture viewing
%   4 ->'model_brain_world'     - runs brain response based analysis modeling world viewing
%   5 ->'run_manipulation'      - runs the image enhancement manipulation only, no analysis

close all;              % close any open figures
str_prompt = 'Enter Y to load the scenes from mat-file, N to read the scenes from disk. \n';

try
    load_str = input(str_prompt, 's');
catch err
    load_str = 'Y';
end

loadit = strcmp(load_str, 'y') || strcmp(load_str, 'Y');
paths  = setup_path;    % add all subfolders to your path
% look for precomputed data
checkit =  exist(fullfile(paths.results, 'analysis_results.mat'),'file');

%% I. Loading current/pre-computed data

% we want to use pre-computed data and it exists 
if(loadit && checkit)
    
    fprintf('Loading precomputed image data...\n');
    load(fullfile(paths.results, 'analysis_results.mat'));                      % basic image and perceptual data already processed

% we don't want to load the data/it doesn't exist    
elseif (~loadit || ~checkit)
    fprintf('Loading original, enhanced, and degraded image sets \n');

    % set up
    all_images  = list_folder(fullfile(paths.images, 'Originals'));             % list all of the images available to analyze
    [dat,trl]   = load_perceptual_data(paths);                          % load mat-file w. perceptual experiment data
    percept     = [];
    nImages = length(all_images);
    
    %img(nImages) = img0;
    %we use growing structure, not good
    
    % load in image and perceptual data
    n_percept = 1;
    for x = 1:nImages
        img_all(x)    = load_image_data(paths, all_images(x).name);  % get image and depth map for analysis
        sn = find(ismember(dat.scenesListSorted, all_images(x).name));  % get index in perceptual data
        if (sn)
            display(['Loading ' all_images(x).name '...']);
            img(n_percept) = img_all(x);             
            percept     = process_perceptual_data(percept, dat, trl, sn, n_percept); % compute percent more 3D for each comparison
            n_percept = n_percept + 1; 
        end
    end

    save(fullfile(paths.results, 'analysis_results.mat'), 'paths', 'percept', 'img', 'img_all');
end
%% II. Ask for user input
str_opt1 = 'Press 1 to run image-based luminance/depth correlation analysis \n';
str_opt2 = 'Press 2 to run image-based coarse-to-fine depth correlation analysis \n';
str_opt3 = 'Press 3 to run brain response based analysis modeling picture viewing \n';
%str_opt4 = 'Press 4 to run brain response based analysis modeling world viewing \n';
str_opt4 = 'Press 4 to run the image enhancement manipulation only, no analysis \n';
str_opt5 = 'Press 0 to quit\n';

fprintf([str_opt1, str_opt2, str_opt3, str_opt4, str_opt5]);

str_prompt = 'Your choise is: ';
usr_input = input(str_prompt);

% run specified approach style to generate and test predictors
switch usr_input
    case 0
        fprintf('Quitting... \n');
    case 1
        fprintf('Running whole image luminance/depth correlation analysis \n');
        pred = image_correlation(img);
        do_plot(pred, percept, paths,'Image-Based Overall Luminance-Depth Correlation',[-0.1 1.75],0);
    case 2
        
        str_prompt = 'Load precomputed multi-scaled images Y/N [Y]';
        try
            load_str = input(str_prompt, 's');
        catch err
            load_str = 'Y';
        end
        
        loadPyr = strcmp(load_str, 'y') || strcmp(load_str, 'Y');
        checkPyr = exist(fullfile(paths.results, 'image_pyramid_results_picture.mat'),'file');
        if (loadPyr && checkPyr)
            fprintf('Loading precomputed image pyramid analysis \n');
            load(fullfile(paths.results, 'image_pyramid_results_picture.mat'));
        else
            fprintf('Running coarse-to-fine luminance/depth correlation analysis \n');
            pred = image_pyramid(img, paths);
        end
        do_plot(pred, percept, paths, 'Image-Based Coarse-to-Fine Luminance-Depth Correlation',[-0.01 0.2],1);
        
        
    case 3
        str_prompt = 'Load precomputed brain model results? Y/N [Y]';
        
        try
            load_str = input(str_prompt, 's');
        catch err
            load_str = 'Y';
        end
        loadBrain = strcmp(load_str, 'y') || strcmp(load_str, 'Y');
        
        checkBrain1 = exist(fullfile(paths.results, 'brain_model_results_picture.mat'), 'file');
        checkBrain2 = exist(fullfile(paths.results, 'brain_model_all_picture.mat'), 'file');

        if (loadBrain && checkBrain1 && checkBrain2)
            fprintf('Loading precomputed brain model based analysis \n');
            load(fullfile(paths.results, 'brain_model_results_picture.mat'));
            load(fullfile(paths.results, 'brain_model_all_picture.mat'));
        else
            fprintf('Running brain model based picture analysis \n');
            [~, brain, pred] = model_brain(img, paths, 1);
        end
        
        do_plot(pred, percept, paths,'Model-Based Brain Picture Responses',[-0.0001 0.0001],0);
        
        % generate figure illustrating brain model
        do_plot_model(paths, brain, img);
%     case 4
%         str_prompt = 'Load precomputed brain model results? Y/N [Y]';
%         
%         try
%             load_str = input(str_prompt, 's');
%         catch err
%             load_str = 'Y';
%         end
%         loadBrain = strcmp(load_str, 'y') || strcmp(load_str, 'Y');
%         
%         checkBrain = exist([paths.results '/brain_model_results_world.mat'],'file');
%         if (loadBrain && checkBrain)
%             fprintf('Loading precomputed brain model based analysis \n');
%             load([paths.results '/brain_model_results_world.mat'])
%         else
%             fprintf('Running brain model based world analysis \n');
%             [model, brain, pred] = model_brain(img,paths,0);
%         end
%         do_plot(pred, percept, paths, 'Model-Based Brain World Responses', [-0.0001 0.0001],0);
    case 4
        fprintf('Performing luminance manipulation and no other analyses \n');
        manipulateLuminanceAllImages;
    otherwise
        fprintf('unknown approach, please try again \n');
        do_analysis;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paths = setup_path()
%
% add all scene-filter-see subfolders to your path

[current_path, current_folder, ~] = fileparts(pwd);

if(strcmp(current_folder,'DoAnalysis'))
    
    paths.home = current_path;
    addpath(genpath(current_path));
    
else
    warning('You are not in the scene-filter-see home directory, looking for the full path');
    m_userpath = strtok(userpath, ':');
    % get the ':' out of userpath
    
    paths.home = fullfile(m_userpath, 'scene-filter-see');
    
    if(exist(paths.home,'dir'))
        addpath(genpath(paths.home));
    end
    
end

paths.images    = fullfile(paths.home, 'ImageManipulation', 'Images');
paths.exp       = fullfile(paths.home, 'PerceptualExperiment', 'Data');
paths.results   = fullfile(paths.home, 'DoAnalysis', 'Results');
paths.env       = fullfile(paths.home, 'ModelBasedApproach', 'EnvironStats');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dat,trl] = load_perceptual_data(paths)
%
% load in perceptual data for images

exp  = load(fullfile(paths.exp, 'mainExperimentData.mat'));  % load mat-file w. all perceptual experiment data

% shortcut for trials
dat = exp.data;
trl = dat.trials;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function percept = process_perceptual_data(percept,dat,trl,sn,x)
%
% compute percent more 3D from perceptual trial data
%
% there are 3 comparisons:
% (1) enh_orig (enhanced v original)
% (2) orig_deg (original v degraded)
% (3) enh_deg  (enhanced v degraded)

percept.scene_name{x} = dat.scenesListSorted{sn};

% get indices for each type of trial
enh_degInds = dat.trials.scene_number == sn & ...
    trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
    trl.condB == find(ismember(dat.conditionTypes, 'ap'));

enh_origInds = dat.trials.scene_number == sn & ...
    trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
    trl.condB == find(ismember(dat.conditionTypes, 'orig'));

orig_degInds = dat.trials.scene_number == sn & ...
    trl.condA == find(ismember(dat.conditionTypes, 'orig')) & ...
    trl.condB == find(ismember(dat.conditionTypes, 'ap'));

%percent more 3D
percept.enh_deg(x)   = 100*sum(trl.resp_Amore3DthanB(enh_degInds))/length(trl.resp_Amore3DthanB(enh_degInds));
percept.enh_orig(x)  = 100*sum(trl.resp_Amore3DthanB(enh_origInds))/length(trl.resp_Amore3DthanB(enh_origInds));
percept.orig_deg(x)  = 100*sum(trl.resp_Amore3DthanB(orig_degInds))/length(trl.resp_Amore3DthanB(orig_degInds));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img = load_image_data(paths,image_name)
%
% load in :
%   original, enhanced, degraded images
%   depth map

img.name      = image_name;

img.orig.RGB  = imread_double(fullfile(paths.images, 'TowardsThePrior', img.name, 'right_original.png'), 8);     % 8-bit RGB image
img.orig.V    = imread_double(fullfile(paths.images, 'TowardsThePrior', img.name, 'right_Voriginal.png'), 8);    % Luminance image

img.enh.RGB   = imread_double(fullfile(paths.images, 'TowardsThePrior', img.name, 'right_tp.png'), 8);
img.enh.V     = imread_double(fullfile(paths.images, 'TowardsThePrior', img.name, 'right_Vtp.png'), 8);

img.deg.RGB   = imread_double(fullfile(paths.images, 'AgainstThePrior', img.name, 'right_ap.png'), 8);
img.deg.V     = imread_double(fullfile(paths.images, 'AgainstThePrior', img.name, 'right_Vap.png'), 8);

img.depth     = load(fullfile(paths.images, 'TowardsThePrior', img.name, 'OtherManipulationInfo', [img.name 'right_depthmapOriginal.mat']));
img.depth     = img.depth.imZOrig;



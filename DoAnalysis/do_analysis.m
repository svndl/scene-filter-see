function do_analysis(approach)
%
% Run either model-based of image-based approach analysis
%
% Current approach options are:
%
%   'image_correlation'     - runs image-based luminance/depth correlation analysis
%   'image_pyramid'         - runs image-based coarse-to-fine depth correlation analysis
%   'model_brain_picture' 	- runs brain response based analysis modeling picture viewing
%   'model_brain_world'     - runs brain response based analysis modeling world viewing
%   'run_manipulation'      - runs the image enhancement manipulation only, no analysis

close all;              % close any open figures
loadit = 1;             % load precomputed data
paths  = setup_path;    % add all subfolders to your path
checkit =  exist([paths.results '/analysis_results.mat'],'file'); % look for precomputed data

% just run manipulation and exit
if strcmp(approach,'run_manipulation')
    display('Performing luminance manipulation and no other analyses');
    manipulateLuminanceAllImages; return;
end

% run other analyses
if(loadit && checkit)
    
    display('Loading precomputed image data...');
    load([paths.results '/analysis_results.mat']);                      % basic image and perceptual data already processed
    
elseif ~checkit
    
    % set up
    all_images  = list_folder([paths.images '/Originals']);             % list all of the images available to analyze
    [dat,trl]   = load_perceptual_data(paths);                          % load mat-file w. perceptual experiment data
    percept     = [];
    
    
    % load in image and perceptual data
    for x = 1:length(all_images)                                        % for each image
        
        sn = find(ismember(dat.scenesListSorted, all_images(x).name));  % get index in perceptual data
        if (sn)
            
            display(['Loading ' all_images(x).name '...']);
            
            percept     = process_perceptual_data(percept,dat,trl,sn,x); % compute percent more 3D for each comparison
            image(x)    = load_image_data(paths,percept.scene_name{x});  % get image and depth map for analysis
            
        end
        
    end
    
    save([paths.results '/analysis_results.mat'],'paths','percept','image');
end


% run specified approach style to generate and test predictors
switch approach
    
    case 'image_correlation'
        
        display('Running whole image luminance/depth correlation analysis');
        pred = image_correlation(image);
        do_plot(pred,percept,paths,'Image-Based Overall Luminance-Depth Correlation',[-0.1 1.75],0);
        
        keyboard
    case 'image_pyramid'
        
        loadPyr = 1;
        if loadPyr
            display('Loading precomputed image pyramid analysis');
            load([paths.results '/image_pyramid_results_picture.mat']);
        else
            display('Running coarse-to-fine luminance/depth correlation analysis');
            pred = image_pyramid(image,paths);
        end
        do_plot(pred,percept,paths,'Image-Based Coarse-to-Fine Luminance-Depth Correlation',[-0.01 0.2],1);
        
        
    case 'model_brain_picture'
        
        loadBrain = 1;
        if loadBrain
            display('Loading precomputed brain model based analysis');
            load([paths.results '/brain_model_results_picture.mat'])
            load([paths.results '/brain_model_all_picture.mat'])
        else
            display('Running brain model based picture analysis');
            [model, pred] = model_brain(image,paths,1);
        end
        
        do_plot(pred,percept,paths,'Model-Based Brain Picture Responses',[-0.0001 0.0001],0);
        
        % generate figure illustrating brain model
        do_plot_model(paths,model,brain,image)
        
        
    case 'model_brain_world'
        
        loadBrain = 1;
        if loadBrain
            display('Loading precomputed brain model based analysis');
            load([paths.results '/brain_model_results_world.mat'])
        else
            display('Running brain model based world analysis');
            [model, pred] = model_brain(image,paths,0);
        end
        
        do_plot(pred,percept,paths,'Model-Based Brain World Responses',[-0.0001 0.0001],0);
        
        
    otherwise
        
        error('unknown approach');
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
    
    paths.home = ('~/Documents/MATLAB/scene-filter-see/');
    
    if(exist(paths.home,'dir'))
        addpath(genpath(paths.home));
    end
    
end

paths.images    = [paths.home '/ImageManipulation/Images'];
paths.exp       = [paths.home '/PerceptualExperiment/Data'];
paths.results   = [paths.home '/DoAnalysis/Results'];
paths.env       = [paths.home '/ModelBasedApproach/EnvironStats'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dat,trl] = load_perceptual_data(paths)
%
% load in perceptual data for images

exp  = load([paths.exp '/mainExperimentData.mat']);  % load mat-file w. all perceptual experiment data

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

function image = load_image_data(paths,image_name)
%
% load in :
%   original, enhanced, degraded images
%   depth map

image.name      = image_name;

image.orig.RGB  = imread_double([paths.images '/TowardsThePrior/' image.name '/right_original.png'],8);     % RGB image
image.orig.V    = imread_double([paths.images '/TowardsThePrior/' image.name '/right_Voriginal.png'],8);    % Luminance image

image.enh.RGB   = imread_double([paths.images '/TowardsThePrior/' image.name '/right_tp.png'],8);
image.enh.V     = imread_double([paths.images '/TowardsThePrior/' image.name '/right_Vtp.png'],8);

image.deg.RGB   = imread_double([paths.images '/AgainstThePrior/' image.name '/right_ap.png'],8);
image.deg.V     = imread_double([paths.images '/AgainstThePrior/' image.name '/right_Vap.png'],8);

image.depth     = load([paths.images '/TowardsThePrior/' image.name '/OtherManipulationInfo/' image.name 'right_depthmapOriginal.mat']);
image.depth     = image.depth.imZOrig;



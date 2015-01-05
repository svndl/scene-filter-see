function testModelBasedApproach


    %% load images, perceptial data
    paths  = setup_path;
    
    if(~exist('peImages.mat', 'file'))
        % set up
        all_images  = list_folder([paths.images '/Originals']);             % list all of the images available to analyze
        [dat,trl]   = load_perceptual_data(paths);                          % load mat-file w. perceptual experiment data
        percept     = [];
        nImages = length(all_images);
        ratedImages = length(dat.scenesListSorted);
        img = cell(ratedImages, 1);
        % load in image and perceptual data
        nRated = 1;
        for x = 1:nImages                                        % for each image    
            sn = find(ismember(dat.scenesListSorted, all_images(x).name));  % get index in perceptual data
            if (sn)
                display(['Loading ' all_images(x).name '...']);
                % compute percent more 3D for each comparison
                percept     = process_perceptual_data(percept, dat, trl, sn, nRated);
                % get image and depth map for analysis
                img{nRated}    = load_image_data(paths, percept.scene_name{nRated});
                nRated = nRated + 1;
            end
        end
        save('peImages.mat', 'img', 'percept');
    else
        load('peImages.mat')
    end        
%     %sizes = [400, 300, 200, 150, 100, 50, 25, 12, 6, 3];
    
    
    sizes = [3, 6, 12, 25, 50, 100, 150, 200, 300, 400];    
    %versions = {'oldRGC', 'newRGC'};
    
    versions = {'oldRGC'};
    %load_model_results(img, sizes);    
    calc_model(paths, img, percept, sizes(5:6), versions);    
    
end
 
function gabor = test_gabor(nX, nY)
    sigma = 10;
    trim = 0.005;
    theta = 15;
    phase = 0.25;
    lambda = 10;
    freq = nX/lambda;    
    X = 1:nX;
    Y = 1:nY;
    X0 = (X / nX) - 0.5;
    Y0 = (Y / nY) - 0.5;
    [Xm, Ym] = meshgrid(X0, Y0);
    thetaRad = (theta / 360) * 2*pi;
    Xt = Xm * cos(thetaRad);                
    Yt = Ym * sin(thetaRad);                
    XYt = Xt + Yt ;                      
    XYf = XYt * freq * 2*pi;
    phaseRad = (phase * 2* pi);    
    grating = sin( XYf + phaseRad);
    grating = (grating - min(min(grating)))/(max(max(grating)) - min(min(grating)));
    s = sigma / nX;    
    gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) );
    gauss(gauss < trim) = 0;                 
    gabor = grating .* gauss;               
end

function calc_model(paths, img, percept, sizes, versions)
    
    nsizes = length(sizes);
    %predicted = cell(nsizes, 1);
    
    m = create_model(paths);
    for i = 1:nsizes
        for v = 1:numel(versions)
            fname = strcat('predicted', num2str(sizes(i)), '_', versions{v});
            figTitle = strcat('Model-Based Brain Picture Responses', num2str(sizes(i)), '_', versions{v});
            [predicted, brain] = model_response(m, img, sizes(i), versions{v});
            save(strcat(fname, '.mat'), 'predicted', 'brain');
            do_plot(predicted, percept, paths, figTitle, [-0.0001 0.0001], 0);
        end
    end
    
end


function load_model_results(img, sizes, versions)
    nsizes = length(sizes);
    for i = 1:nsizes
        for v = 1:numel(versions)
            fname = strcat('predicted', num2str(sizes(i)), '_', versions{v});
            load(strcat(fname, '.mat'));
            pred(i) = predicted;
            br{i} = brain;
        end
    end
    nScenes = length(img);
    
    % for each scene plot correlation distribution for sizes
    scene_ed = zeros(1, length(sizes));
    scene_eo = zeros(1, length(sizes));
    scene_od = zeros(1, length(sizes));
    for i = 1:nScenes
        for n = 1:length(sizes)
             scene_ed(n) = pred(n).enh_deg(i);
             scene_eo(n) = pred(n).enh_orig(i);
             scene_od(n) = pred(n).orig_deg(i);
        end
        f = figure('visible', 'on');
        title(strcat(img{i}.name, 'model response vs scene size'));
        plot(sizes, scene_ed,'-.o','MarkerFaceColor', 'r', 'Color', 'r'); hold on;
        plot(sizes, scene_eo,'-.o','MarkerFaceColor', 'b', 'Color', 'b'); hold on;
        plot(sizes, scene_od,'-.o','MarkerFaceColor', 'y', 'Color', 'y'); hold on;
        set(gca, 'XTick', sizes);
        legend('Enh->Deg','Enh->Orig', 'Orig->Deg');
        xlabel('Scene size');
        ylabel('Brain preference');
        
        export_fig([paths.results '/' img{i}.name '.pdf']);
        close(f);
    end


end
%% sets up working directories
function paths = setup_path
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
    
        paths.home = strcat(m_userpath, '/scene-filter-see_dev/');
    
        if(exist(paths.home,'dir'))
            addpath(genpath(paths.home));
        end
    
    end

    paths.images    = [paths.home 'ImageManipulation/Images'];
    paths.exp       = [paths.home 'PerceptualExperiment/Data'];
    paths.results   = [paths.home 'DoAnalysis/Results'];
    paths.env       = [paths.home 'ModelBasedApproach/EnvironStats'];

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function [dat,trl] = load_perceptual_data(paths)
    %
    % load in perceptual data for images

    exp  = load([paths.exp '/mainExperimentData.mat']);  % load mat-file w. all perceptual experiment data

    % shortcut for trials
    dat = exp.data;
    trl = dat.trials;
 end


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

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img = load_image_data(paths,image_name)
%
% load in :
%   original, enhanced, degraded images
%   depth map

    img.name      = image_name;

    img.orig.RGB  = imread_double([paths.images '/TowardsThePrior/' img.name '/right_original.png'],8);     % RGB image
    img.orig.V    = imread_double([paths.images '/TowardsThePrior/' img.name '/right_Voriginal.png'],8);    % Luminance image

    img.enh.RGB   = imread_double([paths.images '/TowardsThePrior/' img.name '/right_tp.png'],8);
    img.enh.V     = imread_double([paths.images '/TowardsThePrior/' img.name '/right_Vtp.png'],8);

    img.deg.RGB   = imread_double([paths.images '/AgainstThePrior/' img.name '/right_ap.png'],8);
    img.deg.V     = imread_double([paths.images '/AgainstThePrior/' img.name '/right_Vap.png'],8);

    img.depth     = load([paths.images '/TowardsThePrior/' img.name '/OtherManipulationInfo/' img.name 'right_depthmapOriginal.mat']);
    img.depth     = img.depth.imZOrig;
end

function model = create_model(paths)
    env.feature = 'disp';
    env         = get_environ_stats(paths, env); % env has the following fields: bright, dark, all, rng
    % set up brain model properties
    model.N           = 120;                              % number of neurons for simulation
    model.R           = 50;                               % mean population firing rate
    model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
    model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')
    model = build_model_cell_population(env, model);    
end

function [predictions, brains] = model_response(model, images, sz, version)
    resp_orig = zeros(length(images), 1);
    resp_enh = zeros(length(images), 1);
    resp_deg = zeros(length(images), 1);
    %brains = zeros(length(images), 1);
    % apply brain model to images
    for x = 1:length(images)
        try
            display(['Applying brain model to image ' num2str(x)]);
    
            % convert images to gamma-removed grayscale
            images{x}.orig.V = rgb2gray(images{x}.orig.RGB.^(2.2));
            images{x}.enh.V = rgb2gray(images{x}.enh.RGB.^(2.2));
            images{x}.deg.V = rgb2gray(images{x}.deg.RGB.^(2.2));
    
            % downsize images for quicker analysis
            orig = imresize(images{x}.orig.V,[sz, sz]);
            enh = imresize(images{x}.enh.V,[sz, sz]);
            deg = imresize(images{x}.deg.V,[sz, sz]);
            
            %don't use original depth map
            usedepth = 1;
            
            if ~usedepth
                depth = zeros(sz);  % without depth map
            else
                interp = inpaint_nans(images{x}.depth, 3);
                depth = imresize(interp, [sz, sz]); 
            end

    
            % run images through brain model
            brains(x).orig = calcModel(model, orig, depth, version);  
            brains(x).enh  = calcModel(model, enh, depth, version);
            brains(x).deg  = calcModel(model, deg, depth, version);

            % get overall scene volume from brain
            resp_orig(x) = brains(x).orig.volume;
            resp_enh(x) = brains(x).enh.volume;
            resp_deg(x) = brains(x).deg.volume;
        catch err
            disp(strcat('Error, skipping ', num2str(x)));
            disp(num2str(err.stack(1).file));
            disp(num2str(err.stack(1).line));
        end;
    end

    % convert brain responses to differences
    predictions.enh_deg    = (resp_enh - resp_deg)';
    predictions.enh_orig   = (resp_enh - resp_orig)';
    predictions.orig_deg   = (resp_orig - resp_deg)';
end


function brain = calcModel(model, img, dmap, calctype)
    image.pixels = single(img);
    image.depth = single(dmap);    
    switch calctype
        case 'newRGC'
            image.rgc = convert_image_to_rgc_response(image.pixels);
            % simulate visual processing of depth
            image.disparity = convert_depth_to_disparity(image.depth);      
            image.max = single(max(max(image.rgc))); 
        case 'oldRGC'
            pad = [50 50];
            image.pixels = padarray(image.pixels, pad);
            image.depth = padarray(image.depth, pad);
            
            image = convert_image_to_rgc_response_old(image);   % simulate retinal processing
            image = convert_depth_to_disparity_old(image);      % simulate visual processing of depth
        otherwise
            %do nothing
    end
    
    
    %% allocate memory
    brain.disparity = NaN*ones(size(image.disparity));
    
    image.rgc = single(image.rgc);
    image.disparity = single(image.disparity);
    image.max = single(image.max);
        
    %% break image.rgc into small chunks
    
    luminance = image.rgc;
    clamped = abs(luminance)>image.max;
    max_l = sign(luminance)*image.max;
    luminance(clamped)= max_l(clamped);
    nlum = luminance/image.max;
    disp = image.disparity;
    %% num of blocks
    blockSize = 50;
    [nx, ny] = size(nlum);
    
    % small images don't need chunking 
    if (nx <= blockSize && ny <= blockSize)
         brain.disparity = calc_chunk(model, nlum, disp);
    else
        qRows = floor(nx / blockSize);
        rRows = rem(nx, blockSize);
    
        blockR = [blockSize * ones(1, qRows), rRows];
        qCols = floor(ny / blockSize);
        rCols = rem(ny, blockSize);
        blockC = [blockSize * ones(1, qCols), rCols];
        validR = blockR(blockR > 0);
        validC = blockC(blockC > 0);
        cellLum = mat2cell(nlum, validR, validC);
        cellDisp = mat2cell(disp, validR, validC);
    
        bdisp = cell(size(cellLum));
        %% apply model to each sub-segment of image.rgc
    
        for i = 1:length(validR)
            for j = 1:length(validC)
                bdisp{i, j} = calc_chunk(model, cellLum{i, j}, cellDisp{i, j});
            end
        end
        
        %% concat the results back together
        brain.disparity = cell2mat(bdisp);
    end
    
    brain.volume = abs(quantile(brain.disparity(:),0.95) - quantile(brain.disparity(:),0.05));
    brain.image = image;
end
%% apply model to image
function brain_disparity = calc_chunk(model, img, disp)
    
    %% pre-allocate memory, STORE AS SINGLE
    brain_disparity = NaN*ones(size(disp), 'single'); %initialize brain disparity response
    
    [nx, ny] = size(img);
    ng = length(model.gain.bright);
    nr = length(model.env.rng);

    gain_bright = zeros(nx*ny, ng, 'single');
    gain_dark = zeros(nx, ng, 'single');
    gain_tot = zeros(nx*ny, ng, 'single');
    gain_3d = zeros(nr, ng, nx*ny, 'single');
    cell_resp3d = zeros(nr, ng, nx*ny, 'single');
    pop_resp3d = zeros(nx, ng, nx*ny, 'single');
    pop_resp2d = zeros(nx*ny, ng, 'single');
    val2d = zeros(nr, nx*ny, 'single');
    
    model.env.rng = single(model.env.rng);
    model.gain.bright = single(model.gain.bright);
    modelgain.dark = single(model.gain.dark);
    model.response = single(model.response);
    model.preferences = single(model.preferences);
    pr_new = [];
    % iterate through columns
    for j = 1:ny
        
        nlum = img(:, j);
        disparity = disp(:, j);
        bright  = nlum.*(nlum >0);
        dark = nlum.*(nlum<0);
    
        mgain_b = mean(model.gain.bright);
        mgain_d = mean(model.gain.dark);
    
        gain_bright = bright*model.gain.bright + repmat((nlum >0).*(1 - bright)*mgain_b, [1 ng]);
        gain_dark = abs(dark)*model.gain.dark + repmat((nlum < 0).*(1 - abs(dark))*mgain_d, [1 ng]);

        gain_tot = gain_bright + gain_dark;
        gain_3d = repmat(reshape(gain_tot', [1 ng nx]),  [nr 1 1]);
        resp_3d = repmat(reshape(model.response', [nr ng 1]), [1 1 nx]);
        cell_resp3d = gain_3d.*resp_3d;
    
        if(sum(abs(disparity)>60) > 1)
            disp('disparity is over 60');
        end

        pop_resp3d = interp1(model.env.rng, cell_resp3d, disparity);
        
        [mi, mj, ~] = size(pop_resp3d);
        midx = cumsum([1:mi:mi*mj; mi*mj*ones(mi - 1, mj)]);
        pop_resp2d = pop_resp3d(midx);
        
        try
            val2d = interp1(model.preferences, pop_resp2d', model.env.rng, 'cubic', 'extrap');    
        %val2d(isnan(val2d)) = 0;
        catch err
            disp('Error interpolating');
        end
        bd = wmean(repmat(model.env.rng', [1 nx]), val2d);
        brain_disparity(:, j) = reshape(bd, [1, nx]);
    end
    clear gain_3d;
    clear cell_resp3d;
    clear pop_resp3d;
end


function calc_addAnswerScreen(dbtype)
    mpath = main_setPath_Experiment;
    scene_path = fullfile(mpath.results_scenes, dbtype);
    xDivaStimList = dir([scene_path filesep '*.mat']);    
    for i = 1:numel(xDivaStimList)
        filepath = fullfile(scene_path, xDivaStimList(i).name);
        add_answerScreen(filepath);
    end
end


function add_answerScreen(path_to_file, varargin)
    
    disp(['replacing ' path_to_file]);
    load(path_to_file);
    if (numel(varargin) >0)
        imgScreen = varargin{1};
    else
        [x, y1, ~, ~] = size(images);
        y = floor(y1*0.5);
        color_channels = 3;
        center_x = floor(x*0.5);
        center_y = floor(y*0.5);
        r = floor(0.01*x);
        
        [xgrid, ygrid] = meshgrid(1:x, 1:y);   
        xv = xgrid - center_x;    % offset the origin
        yv = ygrid - center_y;
        circlemask = xv.^2 + yv.^2 <= r.^2;
        % Use the mask to select part of the image
        circle_image = 255*ones(x, y) .* double(circlemask)';
        imgScreen = zeros(x, y, color_channels);
        imgScreen(:, :, 2) = circle_image;
        
    end
    
    images(:, :, :, 5) = uint8(repmat(imgScreen, [1 2 1]));
    imageSequence(end) = 5;
    save(path_to_file, 'images', 'imageSequence');
end

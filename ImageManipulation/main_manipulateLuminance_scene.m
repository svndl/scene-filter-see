function res = main_manipulateLuminance_scene(varargin)

% Enhances/degrades a SINGLE scene 
% main_ManipulateScene() will ask to select the directory AND
% manipulation flag
% main_ManipulateScene(source_dir, manipulation_flag) will attempt to manipulate scene
% @source_dir accordins to manipulation_flag ('tp', 'ap');

    path = main_setPath_Manipulation;

    if (nargin == 0)
       loadpath =  uigetdir('/');
       flag = input('Enter manipulation flag (tp/ap)', 's');       
    else
        loadpath = varargin{1};
        flag = varargin{2};
    end
    
    if (~exist(loadpath, 'dir'));
        str_err = ['Path ' loadpath ' is not valid, quitting'];
        error(str_err);
    end
    
    path.source = loadpath;
    disp([path.source ' manipulating ' flag]);
    res = edit_manipulateScene(path.source, flag);
    res.savepath = path.results;
    res.metadata = path.metadata;
    write_saveImages(res);
end
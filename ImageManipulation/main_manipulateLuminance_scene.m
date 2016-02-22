function res = main_manipulateLuminance_scene(varargin)

% Enhances/degrades a SINGLE scene 
% main_ManipulateScene() will ask to select the directory AND
% manipulation flag
% main_ManipulateScene(source_dir, manipulation_flag) will attempt to manipulate scene
% @source_dir accordins to manipulation_flag ('tp', 'ap');

    mpath = main_setPath_Manipulation;

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
    
    mpath.source = loadpath;
    disp([mpath.source ' manipulating ' flag]);
    res = edit_manipulateScene(mpath.source, flag);
    res.savepath = mpath.results;
    
    %% depth map alignment 
    %cut 20 pixels from depth map and image, concatenate them together
%     depth_stripe = flipud(5*normM(res.imZ(1:40, :)));
%     
%     lum_stripe = 5*rgb2gray(res.imRGB(1:40, :, :));
%     lum_depth_stripe = cat(1, lum_stripe, depth_stripe);
%     
%     scrsz = get(0,'ScreenSize');
%     f = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/4]);
%     imagesc(lum_depth_stripe);
%     axis tight;
%     colormap('grey');
%     saveas(f, [res.savepath filesep 'UT_dl' filesep res.name 'depth+lum'], 'pdf');
%     close(f);

%%
    
    res.metadata = mpath.metadata;

    write_saveImages(res);
end
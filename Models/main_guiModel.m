function main_guiModel(varargin)
    close all;
    
    if (nargin == 0)
        dbType = 'mb';
    else
        dbType = varargin{1};
    end
    
    s = load_SceneModel(dbType);
    list_s = {};
    for i = 1:numel(s);
        list_s = {list_s{:}, s{i}.name};
    end;
    S.data = s;
    
    default_pos = 1;
    S.currentScene = getScene(S.data, default_pos);
       
    S.fh = figure('units','pixels',...
              'position',[10 10 2000 2000],...
              'menubar','none',...
              'name','SceneEditor',...
              'numbertitle','off',...
              'resize','on');
   
    S.pp_scene = uicontrol('style','pop',...
                 'unit','pix',...
                 'position',[490 10 280 20],...
                 'backgroundc',get(S.fh,'color'),...
                 'fontsize',12,'fontweight','bold',... 
                 'string',list_s,'value',default_pos);
    S.pp_size = uicontrol('style','pop',...
                 'unit','pix',...
                 'position',[490 10 280 20],...
                 'backgroundc',get(S.fh,'color'),...
                 'fontsize',12,'fontweight','bold',... 
                 'string',list_s,'value',default_pos);

    S.pp_calc = uicontrol('style','pop',...
                 'unit','pix',...
                 'position',[490 10 280 20],...
                 'backgroundc',get(S.fh,'color'),...
                 'fontsize',12,'fontweight','bold',... 
                 'string',list_s,'value',default_pos);
             
    S.image = axes('units','pixels',...
            'position',[50 200 800 800], 'xtick',[],'ytick',[], 'box', 'on');
        
    %align([S.left S.right],'distribute','bottom');    
    set(S.pp_scene,'callback',{@pp_scene, S});  % Set the popup callback.
    set(S.pp_size,'callback',{@pp_size, S});  % Set the popup callback.
    set(S.pp_calc,'callback',{@pp_calc, S});  % Set the popup callback.
    updateCrossPos(S);    
end

function [] = pp_call(varargin)
% Callback for popupmenu.
    S = varargin{3};  % Get the structure.
    P = get(S.pp, 'val'); % Get the users choice from the popup     
    S.currentScene = getScene(S.data, P);
    %update slider/edit info
    updateSceneHandles(S);
    set(S.text, 'visible', 'off')   
    updateCrossPos(S);
end    

function [] = pb_call(varargin)
    S = varargin{3};  % Get calling handle and structure.
    right = S.currentScene.right;
    left = S.currentScene.left;
    offset = S.currentScene.offset;
    offset0 = S.currentScene.offset0;
    dH = S.currentScene.dH;
    
    name = S.currentScene.name;
    
    path = main_setPathExperiment;
    save([path.metadata_gui_scenes filesep 'gui_' S.currentScene.name '.mat'], 'name','right', 'left', 'offset', 'dH', 'offset0');
    
    rx = edit_drawCross(right, 30, -offset);
    lx = edit_drawCross(left, 30, offset);
    d = gui_getDisplay;
    shiftH = offset(2) + dH;
    lA = edit_positionScene(lx, d.h, shiftH);
    rA = edit_positionScene(flipdim(rx, 2), d.h, shiftH);
   
    sceneA = cat(2, lA, rA);
    imwrite(sceneA, [path.metadata_gui_scenes filesep 'gui_' S.currentScene.name '.jpeg']);
    %write matfiles
    
    set(S.text, 'visible', 'on');
end

function updateCrossPos(S)
    S.currentScene.name
    S.currentScene.rx = edit_drawCross(S.currentScene.right, 30, -S.currentScene.offset);
    S.currentScene.lx = edit_drawCross(S.currentScene.left, 30, S.currentScene.offset);
    midV = floor(0.5*size(S.currentScene.lx, 1));
    midH = floor(0.5*size(S.currentScene.lx, 2));
    midLeft = S.currentScene.lx(midV - 400:midV + 400, midH-400:midH + 400, :);
    midRight = S.currentScene.rx(midV - 400:midV + 400, midH-400:midH + 400, :);
	
    set(0,'CurrentFigure',S.fh);
    set(S.fh,'CurrentAxes',S.left); imshow(midLeft);
    set(S.fh,'CurrentAxes',S.right); imshow(midRight);
    updateCallbacks(S);
end
%will be called when new scene is loaded for the first time
function updateSceneHandles(S)
    %update edit field value
    set(S.ed, 'string', num2str(S.currentScene.offset(2)));
    set(S.edH, 'string', num2str(S.currentScene.dH));   
    
    updateCallbacks(S);
end
function out = getScene(s, pos)
    scene = s{pos};
    if (~isfield(scene, 'offset0'))
        out = gui_getScene(scene);
        out.offset = floor(0.5*out.offset0);
        out.dH = 0;
    else
       out = scene;
    end
end
function updateCallbacks(S)
% 
    set(S.pp, 'callback', {@pp_call, S});  % update the popup callback.    
    set(S.ed, 'callback', {@ed_call, S});  % update the edit callback.
    set(S.edH, 'callback', {@edH_call, S});  % update the edit callback.    
    set(S.pb, 'callback', {@pb_call, S});
end

function gui_CrossEditor(varargin)
    close all;
    
    if (nargin == 0)
        dbType = 'ut';
    else
        dbType = varargin{1};
    end
    
    s = load_XDivaScene(dbType);
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
   
    S.pp = uicontrol('style','pop',...
                 'unit','pix',...
                 'position',[350 110 180 20],...
                 'backgroundc',get(S.fh,'color'),...
                 'fontsize',12,'fontweight','bold',... 
                 'string',list_s,'value',default_pos);
    
    % distance from LEFT edge of the gui
    text_edit.X0 = 150;
    % horizontal gap between the next edit field
    text_edit.dX = 110;
    % width of edit field 
    text_edit.X = 60;
    
    
    % distance from BOTTOM of the gui
    text_edit.Y0 = 30;
    % vertical gap between the next edit field    
    text_edit.dY = 10;
    % height of edit field 
  
    text_edit.Y = 30;
    
    
    S.textH = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[130 110 60 30],...
                 'fontsize',16,...
                 'string', 'Hor', 'visible', 'on');     

    S.textV = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[240 110 60 30],...
                 'fontsize',16,...
                 'string', 'Vert', 'visible', 'on');     
    % Cross shift text and edit         
    S.textCross = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[50 70 60 30],...
                 'fontsize',16,...
                 'string', 'Cross', 'visible', 'on');     
           
    S.edX = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[130 70 60 30],...
                 'fontsize',16,...
                 'string',num2str(S.currentScene.offset(2)));
    
    S.edY = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[240 70 60 30],...
                 'fontsize',16,...
                 'string',num2str(S.currentScene.offset(1)));
             
    %Scene shift and edit        
    S.textShift = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[50 30 60 30],...
                 'fontsize',16,...
                 'string', 'Scene', 'visible', 'on');     

             
    S.edHX = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[130 30 60 30],...
                 'fontsize',16,...
                 'string', '0');
    
    S.edHY = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[240 30 60 30],...
                 'fontsize',16,...
                 'string','0');
             
    S.pb = uicontrol('style','push',...
                 'units','pix',...
                 'position',[550 110 60 30],...
                 'backgroundcolor','w',...
                 'HorizontalAlign','left',...
                 'string','Save X',...
                 'fontsize',14,'fontweight','bold');             
    S.text = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[750 110 160 30],...
                 'fontsize',16,...
                 'string', 'Changes saved!', 'visible', 'off');     
     S.left = axes('units','pixels',...
            'position',[50 200 800 800], 'xtick',[],'ytick',[], 'box', 'on');
        
     S.right = axes('units','pixels',...
            'position',[1000 200 800 800], 'xtick',[],'ytick',[], 'box', 'on');
    
    %align([S.left S.right],'distribute','bottom');    
    set(S.pp,'callback',{@pp_call, S});  % Set the popup callback.
    set(S.pb, 'callback', {@pb_call, S});
    set(S.edX,'call',{@edX_call, S});  % Sharedclose all Callback.
    set(S.edY,'call',{@edY_call, S});  % Sharedclose all Callback.
    set(S.edHX,'call',{@edHX_call, S});  % Sharedclose all Callback.
    set(S.edHY,'call',{@edHY_call, S});  % Sharedclose all Callback.

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

function [] = edX_call(varargin)
    % Callback for the edit box and slider.
    [h, S] = varargin{[1,3]};  % Get calling handle and structure.
    new_offset = str2double(get(h,'string'));
    S.currentScene.offset(2) = round(new_offset);
    updateCrossPos(S);
    updateCallbacks(S);    
end

function [] = edY_call(varargin)
    % Callback for the edit box and slider.
    [h, S] = varargin{[1,3]};  % Get calling handle and structure.
    new_offset = str2double(get(h,'string'));
    S.currentScene.offset(1) = round(new_offset);
    updateCrossPos(S);
    updateCallbacks(S);    
end

function [] = edHX_call(varargin)
    % Callback for the edit box and slider.
    [h, S] = varargin{[1,3]};  % Get calling handle and structure.
    new_shift = str2double(get(h,'string'));
    S.currentScene.dH(2) = round(new_shift);
    updateCallbacks(S);    
end

function [] = edHY_call(varargin)
    % Callback for the edit box and slider.
    [h, S] = varargin{[1,3]};  % Get calling handle and structure.
    new_shift = str2double(get(h,'string'));
    S.currentScene.dH(1) = round(new_shift);
    updateCallbacks(S);    
end

function [] = pb_call(varargin)
    S = varargin{3};  % Get calling handle and structure.
    right = S.currentScene.right;
    left = S.currentScene.left;
    offset = S.currentScene.offset;
    offset0 = S.currentScene.offset0;
    dH = S.currentScene.dH;
    
    name = S.currentScene.name;
    
    path = main_setPath_Experiment;
    save([path.metadata_gui_scenes filesep 'gui_' S.currentScene.name '.mat'], 'name','right', 'left', 'offset', 'dH', 'offset0');
    
    rx = edit_drawCross(right, 30, [offset(1), - offset(2)]);
    lx = edit_drawCross(left, 30, [offset(1), offset(2)]);
    d = calc_getDisplay;
    shiftH = offset + dH;
    lA = edit_positionScene(lx, [d.v, d.h], shiftH, 'hv');
    rA = edit_positionScene(flipdim(rx, 2), [d.v, d.h], shiftH, 'hv');
   
    sceneA = cat(2, lA, rA);
    sceneA = sceneA.^(1/2.2);
    imwrite(sceneA, [path.metadata_gui_scenes filesep 'gui_' S.currentScene.name '.jpeg']);
    %write matfiles
    
    set(S.text, 'visible', 'on');
end

function updateCrossPos(S)
    S.currentScene.rx = edit_drawCross(S.currentScene.right, 30, [S.currentScene.offset(1), -S.currentScene.offset(2)]);
    S.currentScene.lx = edit_drawCross(S.currentScene.left, 30, [S.currentScene.offset(1), S.currentScene.offset(2)]);
    midV = floor(0.5*size(S.currentScene.lx, 1));
    midH = floor(0.5*size(S.currentScene.lx, 2));
    midLeft = S.currentScene.lx(midV - 400:midV + 400, midH-400:midH + 400, :);
    midRight = S.currentScene.rx(midV - 400:midV + 400, midH-400:midH + 400, :);
	
    set(0,'CurrentFigure',S.fh);
    set(S.fh,'CurrentAxes',S.left); imshow(midLeft.^(1/2.2));
    set(S.fh,'CurrentAxes',S.right); imshow(midRight.^(1/2.2));
    updateCallbacks(S);
end
%will be called when new scene is loaded for the first time
function updateSceneHandles(S)
    %update edit field value
    set(S.edX, 'string', num2str(S.currentScene.offset(2)));
    set(S.edY, 'string', num2str(S.currentScene.offset(1)));
    set(S.edHX, 'string', num2str(S.currentScene.dH(1)));   
    set(S.edHY, 'string', num2str(S.currentScene.dH(2)));   
    
    updateCallbacks(S);
end
function out = getScene(s, pos)
    scene = s{pos};
    if (~isfield(scene, 'offset0'))
        out = gui_getScene(scene);
        out.offset = floor(0.5*out.offset0);
        out.dH = [0 0];
    else
       out = scene;
    end
end
function updateCallbacks(S)
% 
    set(S.pp, 'callback', {@pp_call, S});  % update the popup callback.    
    set(S.edX, 'callback', {@edX_call, S});  % update the edit callback.
    set(S.edHX, 'callback', {@edHX_call, S});  % update the edit callback.    
    set(S.edY, 'callback', {@edY_call, S});  % update the edit callback.
    set(S.edHY, 'callback', {@edHY_call, S});  % update the edit callback.    
    set(S.pb, 'callback', {@pb_call, S});
end

function [sceneS, sceneE, sceneO, sceneB] = make_GetAllVersions(name, path, varargin)

    if (nargin ==1)
        background = 0;
    else
        background = varargin{1};
    end
    
   
    xDivaPath = path.metadata_gui_scenes;
    srcPath = path.source;
    
    % loading xDiva Stereo modified 
    xDivaFilename = strcat(xDivaPath, filesep, 'gui_', name, '.mat');
    
    % assuming matfile can be anywhere
    matFilename = strcat(name, '.mat');
    
    
    if (~exist(matFilename, 'file'))
        image_path = strcat(srcPath, filesep, name);
        disp(['Manipulating ' name]);
        matScene = main_manipulateLuminance_scene(image_path, 'tp');
    else
        matScene = load(matFilename);
    end
    
    if (~exist(xDivaFilename, 'file'))
        matScene = load(matFilename);
        xScene = gui_getScene(matScene);
        save([xDivaPath filesep 'gui_' filename], 'xScene.name','xScene.right', 'xScene.left', 'xScene.offset', 'xScene.dH', 'xScene.offset0');
    else
        xScene = load(xDivaFilename);
    end;
    [leftE, rightE] = edit_prepScene(matScene, 'E');
    [leftO, rightO] = edit_prepScene(matScene, 'O');
        
        
    
    %% STEREO

    shiftH = xScene.offset(2) + xScene.dH;        
    sceneS = mkScene(xScene.left, xScene.right, xScene.offset, shiftH, background);
    
    %% 2D
    %sceneE = mkScene(leftE, rightE, 0, 0);
    %sceneO = mkScene(leftO, rightO, 0, 0);

    d = calc_getDisplay;   
    leftEx = mkOne(leftE, xScene.offset);
    rightEx = mkOne(rightE, xScene.offset);
    
    leftOx = mkOne(leftO, xScene.offset);
    rightOx = mkOne(rightO, xScene.offset);
    
    lEA = edit_positionScene(leftEx, d.h, shiftH, background);   
    rEA = edit_positionScene(flipdim(rightEx, 2), d.h, -shiftH, background);
              
    lOA = edit_positionScene(leftOx, d.h, shiftH, background);   
    rOA = edit_positionScene(flipdim(rightOx, 2), d.h, -shiftH, background);

    sceneE = cat(2, lEA, rEA); 
    sceneO = cat(2, lOA, rOA);
    
    %% blank
    
    blank = background*ones(size(leftE));
    sceneB = mkScene(blank, blank, xScene.offset, shiftH, background);
end

 function s = mkScene(left, right, offset, shiftH, background)
    d = getDisplay;   
    
    lxA = mkOne(left,offset);
    rxA = mkOne(right, -offset);
    
    lA = edit_positionScene(lxA, d.h, shiftH, background);   
    rA = edit_positionScene(flipdim(rxA, 2), d.h, shiftH, background);
              
    s = cat(2, lA, rA); 
 end
 
 function xs = mkOne(s, offset)
 
    d = getDisplay;
    s1 = imresize(s, [d.v NaN]);
    xs = edit_drawCross(s1, 30, offset);
 end 
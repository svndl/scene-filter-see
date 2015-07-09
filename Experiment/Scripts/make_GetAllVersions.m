function [sceneS, sceneE, sceneO, sceneB] = make_GetAllVersions(name, path, varargin)

    if (nargin == 1)
        background = 0;
    else
        background = varargin{1};
    end
        
    xDivaPath = path.metadata_gui_scenes;
    matPath =  path.matimages;
    srcPath = path.images;
    
    % loading xDiva Stereo modified 
    xDivaFilename = strcat(xDivaPath, filesep, 'gui_', name, '.mat');
    
    % assuming matfile can be anywhere
    matFilename = strcat(matPath, filesep, name, '.mat');
    
    if (~exist(matFilename, 'file'))
        image_path = strcat(srcPath, filesep, name);
        disp(['Manipulating ' name]);
        matScene = main_manipulateLuminance_scene(image_path, 'tp');
    else
        matScene = load(matFilename);
    end
    
    %by this point we should have the matfile info loaded
    
    if (~exist(xDivaFilename, 'file'))
        xScene = gui_getScene(matScene);
        save([xDivaPath filesep 'gui_' name], '-struct', 'xScene');
    else
        xScene = load(xDivaFilename);
    end;
        
        
    %% STEREO

    shiftH = xScene.offset + xScene.dH;        
    sceneS = mkScene(xScene.left, xScene.right, xScene.offset, shiftH, background);
    
    %% 2D
    %sceneE = mkScene(leftE, rightE, 0, 0);
    %sceneO = mkScene(leftO, rightO, 0, 0);
    [leftE, rightE] = edit_prepScene(matScene, 'E');
    [leftO, rightO] = edit_prepScene(matScene, 'O');

    d = calc_getDisplay;   
    leftEx = mkOne(leftE, xScene.offset);
    rightEx = mkOne(rightE, xScene.offset);
    
    leftOx = mkOne(leftO, xScene.offset);
    rightOx = mkOne(rightO, xScene.offset);
    
    lEA = edit_positionScene(leftEx, d, shiftH, background);   
    rEA = edit_positionScene(flipdim(rightEx, 2), d, -shiftH, background);
              
    lOA = edit_positionScene(leftOx, d, shiftH, background);   
    rOA = edit_positionScene(flipdim(rightOx, 2), d, -shiftH, background);

    sceneE = cat(2, lEA, rEA); 
    sceneO = cat(2, lOA, rOA);
    
    %% blank
    
    blank = background*ones(size(leftE));
    sceneB = mkScene(blank, blank, xScene.offset, shiftH, background);
end

 function s = mkScene(left, right, offset, shiftH, background)
    d = calc_getDisplay;   
    
    lxA = mkOne(left, offset);
    rxA = mkOne(right, -offset);
    
    lA = edit_positionScene(lxA, d, shiftH, background);   
    rA = edit_positionScene(flipdim(rxA, 2), d, shiftH, background);
              
    s = cat(2, lA, rA); 
 end
 
 function xs = mkOne(s, offset)
 
    d = calc_getDisplay;
    s1 = imresize(s, [d.v NaN]);
    xs = edit_drawCross(s1, 30, offset);
 end

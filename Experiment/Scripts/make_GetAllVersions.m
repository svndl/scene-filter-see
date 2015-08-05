function varargout = make_GetAllVersions(name, path, list, varargin)
    if (isempty(varargin))
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
    nV = numel(list);
    varargout = cell(1, nV + 1);
    shiftH = xScene.offset + xScene.dH;
    offset_2d = [0, 0];        

    for l = 1:nV
        switch list{l}
            case 'S'
                %% STEREO
                sceneS = mk3DScene(xScene.left, xScene.right, xScene.offset, shiftH, background);
                varargout{l} = sceneS;
            case 'E'
                %% Enhanced
                [leftE, rightE] = edit_prepScene(matScene, 'E');
                %sceneE = mk2DScene(leftE, rightE, xScene.offset, shiftH, background);
                sceneE = mk2DScene(leftE, rightE, offset_2d, offset_2d, background);
                varargout{l} = sceneE;
            case 'O'
                [leftO, rightO] = edit_prepScene(matScene, 'O');               
                %sceneO = mk2DScene(leftO, rightO, xScene.offset, shiftH, background);
                sceneO = mk2DScene(leftO, rightO, offset_2d, offset_2d, background);
                varargout{l} = sceneO;
            case 'D'
                image_path = strcat(srcPath, filesep, name);                
                matSceneD = main_manipulateLuminance_scene(image_path, 'ap');
                [leftD, rightD] = edit_prepScene(matSceneD, 'D');
                xSceneD = gui_getScene(matSceneD);
                %sceneD = mk2DScene(leftD, rightD, xSceneD.offset, shiftH, background);                
                sceneD = mk2DScene(leftD, rightD, offset_2d, offset_2d, background);                                
                varargout{l} = sceneD;
            otherwise
        end
    end
    
    %% blank
    
    blank = background*ones(size(matScene.right));
    sceneB = mk2DScene(blank, blank, offset_2d, offset_2d, background);
    varargout{nV + 1} = sceneB;
end

 function s = mk3DScene(left, right, offset, shiftH, background)
    d = calc_getDisplay;   
    
    lxA = mkOne(left, offset);
    rxA = mkOne(right, -offset);
    
    lA = edit_positionScene(lxA, [d.v d.h], shiftH, background);   
    rA = edit_positionScene(flipdim(rxA, 2), [d.v d.h], shiftH, background);
              
    s = cat(2, lA, rA); 
 end
 
 function s = mk2DScene(left, right, offset, shiftH, background)
    d = calc_getDisplay;
    
    leftX = mkOne(left, offset);
    rightX = mkOne(right, offset);
        
    lA = edit_positionScene(leftX, [d.v d.h], shiftH, background);   
    rA = edit_positionScene(flipdim(rightX, 2), [d.v d.h], -shiftH, background);
    s = cat(2, lA, rA); 
 end
 
 function xs = mkOne(s, offset)
 
    d = calc_getDisplay;
    s1 = imresize(s, [d.v NaN]);
    xs = edit_drawCross(s1, 30, offset);
 end

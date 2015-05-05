function xScene = gui_getScene(s)

    [leftA, rightA] = prepScene(s, 'S');
    offset0 = estimateDisparity(leftA, rightA);
    d = getDisplay;
        
    right = imresize(rightA, [d.v NaN]);
    left = imresize(leftA, [d.v NaN]);
    
    %place crosses, save as jpegs/matfiles
    xScene.left = left;
    xScene.right = right;
    xScene.offset0 = offset0;
    xScene.offset = offset0;
    xScene.dH = 0;
    xScene.name = s.name;
end



function xScene = gui_getScene(s)

    [leftA, rightA] = edit_prepScene(s, 'S');
    %offset0 is a 1D array with 2 elements
    offset0 = calc_estimateDisparity(leftA, rightA);
    d = calc_getDisplay;
        
    right = imresize(rightA, [d.v NaN]);
    left = imresize(leftA, [d.v NaN]);
    
    %place crosses, save as jpegs/matfiles
    xScene.left = left;
    xScene.right = right;
    xScene.offset0 = offset0;
    xScene.offset = offset0;
    xScene.dH = [0 0];
    xScene.name = s.name;
end



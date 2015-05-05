function out = edit_drawCross(image, height, offset)
    
    %default value of cross liner;
    outer = 0.5;
    
    if (size(image, 3) > 0)
        outer = mean(mean(rgb2gray(image)));
    else
        outer = mean(image(:));
    end
    % zero offset = > place cross exactly on image center
    if (nargin < 3)
        offset = [0, 0];
    end;
        
    % outer parameters: mean lum, 1 pix off center
    outer_thick = 1;
    outer_code = 1;
    % inner parameters: white, 1 pix off center
    inner_code = 0.5;
    inner_thick = 1;
    
    
    dummy = zeros(size(image, 1), size(image, 2));   
    center0 = floor([size(image, 1), size(image, 2)]*0.5);
    
    center = center0 + offset; 
    %draw inner
    dummy(center(1) - inner_thick:center(1) + inner_thick, center(2) - height:center(2) + height) = inner_code;
    dummy(center(1) - height:center(1) + height, center(2) - inner_thick:center(2) + inner_thick) = inner_code;
    
    %outer boundaries
    outer_boundaryV = [center(1) - height - 1, center(1) - inner_thick - 1, center(1) + inner_thick + 1, center(1) + height + 1];
    outer_boundaryH = [center(2) - height - 1, center(2) - inner_thick - 1, center(2) + inner_thick + 1, center(2) + height + 1];
    
    %draw vertical outer
    dummy(outer_boundaryV(1):outer_boundaryV(2), outer_boundaryH(2) - 2*outer_thick:outer_boundaryH(2)) = outer_code;
    dummy(outer_boundaryV(1):outer_boundaryV(2), outer_boundaryH(3):outer_boundaryH(3) + 2*outer_thick) = outer_code;
    
    dummy(outer_boundaryV(2):outer_boundaryV(3), outer_boundaryH(1) -  2*outer_thick:outer_boundaryH(1)) = outer_code;
    dummy(outer_boundaryV(2):outer_boundaryV(3), outer_boundaryH(4):outer_boundaryH(4) + 2*outer_thick) = outer_code;
    
    dummy(outer_boundaryV(3):outer_boundaryV(4), outer_boundaryH(2)- 2*outer_thick:outer_boundaryH(2)) = outer_code;
    dummy(outer_boundaryV(3):outer_boundaryV(4), outer_boundaryH(3):outer_boundaryH(3) + 2*outer_thick) = outer_code;
    
    %draw horizontal outer
    dummy(outer_boundaryV(1) - 2*outer_thick:outer_boundaryV(1), outer_boundaryH(2):outer_boundaryH(3)) = outer_code;
    dummy(outer_boundaryV(4):outer_boundaryV(4) + 2*outer_thick, outer_boundaryH(2):outer_boundaryH(3)) = outer_code;
    
    dummy(outer_boundaryV(2) - 2*outer_thick:outer_boundaryV(2), outer_boundaryH(1):outer_boundaryH(2)) = outer_code;
    dummy(outer_boundaryV(3):outer_boundaryV(3) + 2*outer_thick, outer_boundaryH(1):outer_boundaryH(2)) = outer_code;

    dummy(outer_boundaryV(2) - 2*outer_thick:outer_boundaryV(2), outer_boundaryH(3):outer_boundaryH(4)) = outer_code;
    dummy(outer_boundaryV(3):outer_boundaryV(3) + 2*outer_thick, outer_boundaryH(3):outer_boundaryH(4)) = outer_code;
    
    dummy = repmat(dummy,[1,1,size(image,3)]);
    out = image;
    out(dummy == 0.5) = 1;
    out(dummy == 1) = outer;
end



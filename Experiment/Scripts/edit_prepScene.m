function [left, right] = edit_prepScene(s, type)

    %% pull out different versions of left/right
    switch type
        case 'S'
            left = s.left;
            right = s.right;
        case 'E'
            left = s.imRGBnew;
            right = s.imRGBnew;
        case 'O'
            left = s.imRGB;
            right = s.imRGB;
        otherwise
    end
end
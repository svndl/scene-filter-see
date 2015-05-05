function shifted = edit_positionScene(scene, windowH, shift, varargin)

    if (nargin == 3)
        background = 0;
    else
        background = varargin{1};
    end
    
    %difference between scene width and screen resolution
    dH = floor(0.5*(windowH - size(scene, 2)));
    ds = dH - shift;
    
    % breakdown of possible values
    
    % dH<=0 : scene is eq or larger than screen
    % cut 2*shift from the left
    % pad from the left/right with shift
    
    if (dH <=0)
        %crop to fit the monitor
        scene_cropped0 = scene(:, abs(dH) + 1:end - abs(dH), :); 
        
        %crop for shift
        scene_cropped1 = scene_cropped0(:, 2*shift + 1:end, :);
        shifted = padarray(scene_cropped1, [0 shift], background);
    else
        if (ds >= 0)
            % shift amount is less than distance to the monitor edge
            scene_padded_left = padarray(scene, [0 ds], background, 'pre');
            shifted = padarray(scene_padded_left, [0 dH + shift], background, 'post');
        else
            %shift distance is greated than distance to the left edge
            % crop the scene from the left by ds + shift, zero-pad from the right  
            scene_cropped = scene(:, abs(ds) + 2*shift + 1:end, :);
            padded_right = padarray(scene_cropped, [0 dH + shift], background, 'post');
            shifted = padarray(padded_right, [0 shift], background);        
        end
    end
end

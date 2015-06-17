function shifted = edit_positionScene(scene, window, shift, varargin)

    background = 0;
    if (nargin == 5)  
        background = varargin{2};
    end
    
    shift_direction = 'h';
    
    if (nargin == 4)
        shift_direction = varargin{1};
    end
    
    
    %difference between scene width and screen resolution
    diff = floor(0.5*(window - [size(scene, 1) size(scene, 2)]));
    shift = abs(shift);
    switch shift_direction
        case 'v'
            dV = diff(1);
            shiftV = shift(1);
            s = permute(scene, [2 1 3]);
            shiftedV = edit_positionScene1D(s, dV, shiftV, background);
            shifted = permute(shiftedV, [2 1 3]);
        case 'h'
            dH = diff(2);
            shiftH = shift(2);            
            shifted = edit_positionScene1D(scene, dH, shiftH, background);
        case 'hv'
            s = permute(scene, [2 1 3]);
            shiftedV = edit_positionScene1D(s, diff(1), shift(1), background);
            
            shifted = edit_positionScene1D(permute(shiftedV, [2 1 3]), diff(2), shift(2), background);
        otherwise
            shifted = edit_positionScene1D(scene, diff(2), shift(2), background);
    end
end

function shifted = edit_positionScene1D(scene, dH, shift, background)

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

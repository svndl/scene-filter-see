function display = calc_getDisplay
    PlanarX = 16;
    PlanarY = 9;
        
    %max vertical and horisontal resolution w. respect to aspect ratio
    
    display.v = 1080;
    display.h = 1080*PlanarX/PlanarY;
end
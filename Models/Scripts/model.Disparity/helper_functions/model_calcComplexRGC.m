function im_new = model_calcComplexRGC(im, appix)
    %appix = 1.4; %edit appix value    
    rgcs            = load_croner_kaplan_rgc_info;      % load in the parameters for modeling the spatial receptive fields of RGCs
    fltrs           = make_rgc_filters(rgcs, appix);    % make difference of Gaussian filters to model RGC receptive fields
    on              = filter_image(im, fltrs,'ON');      % apply the RGC models to the image matrix for ON pathway
    off             = filter_image(im, fltrs,'OFF');     % apply the RGC models to the image matrix for OFF pathway
    
    weights = [9, 9, 1, 1];
    w_on = (weights(1)*on(1).im + weights(2)*on(2).im + weights(3)*on(3).im + weights(4)*on(4).im)/sum(weights);
    w_off = (weights(1)*off(1).im + weights(2)*off(2).im + weights(3)*off(3).im + weights(4)*off(4).im)/sum(weights);
    
    im_new = w_on + w_off;
    %show_results(im,on,off,rgcs,fltrs);     
    
    
    
    
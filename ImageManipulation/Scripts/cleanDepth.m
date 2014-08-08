%set dmap and disparity map ranges to .01 and .99 quantiles to get rid of outliers
% then inpaint NaN values
function cleaned = cleanDepth(image)

    %normalize dmap and disparity map, to .01 and .99 quantiles to get rid of
    %outliers
    cleaned = image;
    cleaned.imZ(cleaned.imZ > quantile(cleaned.imZ(:), 0.99)) = quantile(cleaned.imZ(:), 0.99);
    cleaned.imZ(cleaned.imZ < quantile(cleaned.imZ(:), 0.01))  = quantile(cleaned.imZ(:), 0.01);
    cleaned.dispmap(cleaned.dispmap > quantile(cleaned.dispmap(:), 0.99)) = quantile(cleaned.dispmap(:), 0.99);
    cleaned.dispmap(cleaned.dispmap < quantile(cleaned.dispmap(:), 0.01)) = quantile(cleaned.dispmap(:), 0.01);

    %fill in depth and disparity maps nans
    cleaned.imZ     = inpaint_nans(cleaned.imZ, 2);
    cleaned.dispmap = inpaint_nans(cleaned.dispmap, 2);

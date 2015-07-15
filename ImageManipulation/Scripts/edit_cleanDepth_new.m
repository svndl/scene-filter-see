function d = edit_cleanDepth_new(img, dmap, blurOption)
% clean the depthmap : remove values outside the 1%-99% range
% and remove NaNs. Blur Option is for UT images only, used
% to get rid of pixels after correction 
% written by Alexandra Y., updated by Shuichi T.

    if(nargin < 2)
        blurOption = 0; 
    end
    
    dmap_copy = dmap;
    dmap_valid = inpaint_nans(dmap_copy, 2);
    
    q99 = quantile(dmap_valid(:), 0.99);
    q01 = quantile(dmap_valid(:), 0.01);

    dmap_valid(dmap_valid > q99) = q99;
    dmap_valid(dmap_valid < q01) = q01;
    
    d = dmap_valid;
    [col, row] = size(d);

%     if (blurOption)
        % original filter settings
%         gauss = fspecial('gauss', 100, 5);
%         d = conv2(d, gauss, 'same');
%     end

    switch blurOption
        case 'gauss'    % Original gaussian filter
            gauss = fspecial('gauss', 100, 5);
            d = conv2(d, gauss, 'same');
        case 'usm'      % Unsharp masking applied to gaussian-filtered depth
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d_usm = d + (d - d_gss);
            d_usm(d_usm > max(max(d))) = max(max(d));
            d_usm(d_usm < min(min(d))) = min(min(d));
            d = d_usm;
        case 'jbl'      % Joint bilateral filter
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d = jbfilter2(d, d_gss);
        case 'jbl_twc'  % Joint bilateral filter (twice)
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d_jbf = jbfilter2(d, d_gss);
            d = jbfilter2(d, d_jbf);
        case 'jbl_adp'  % Joint bilateral filter with depth adaptation
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d = d.*d_gss + (ones(col, row) - d).*jbfilter2(d, d_gss);
        case 'jbl_y'    % depth and luminance (Y) of original image
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            img_y = rgb2ycbcr(img);
            img_y = img_y(:,:,1);
            img_y = img_y/(max(max(img_y)));
            d_jbf = jbfilter2(d, img_y);
            d = jbfilter2(d_jbf, img_y);
        otherwise       % no processing
    end
end

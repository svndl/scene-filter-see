function d = edit_cleanDepth(dmap, blurOption)
% clean the depthmap : remove values outside the 1%-99% range
% and remove NaNs. Blur Option is for UT images only, used
% to get rid of pixels after correction 

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
        case 1    % Original filter configuration
            gauss = fspecial('gauss', 100, 5);
            d = conv2(d, gauss, 'same');
        case 2    % Gaussian LPF in weaker settings
            gauss = fspecial('gauss', 15, 3);
            d = conv2(d, gauss, 'same');
        case 3    % Unsharp masking applied to Gaussian-filtered depth
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d_usm = d + (d - d_gss);
            d_usm(d_usm > max(max(d))) = max(max(d));
            d_usm(d_usm < min(min(d))) = min(min(d));
            d = d_usm;
        case 4  % Joint bilateral filter
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d = jbfilter2(d, d_gss);
        case 5  % Unsharp masking in case 3 and bilateral filter
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d_usm = d + (d - d_gss);
            d_usm(d_usm > max(max(d))) = max(max(d));
            d_usm(d_usm < min(min(d))) = min(min(d));
            d = bilateral(d_usm, 3, 0.3);
        case 6  % Joint bilateral filter with depth adaptation (linear)
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d = d.*d_gss + (ones(col, row) - d).*jbfilter2(d, d_gss);
        case 7  % Joint bilateral filter with depth adaptation (non-linear)
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d_jbf = jbfilter2(d, d_gss);
            d = nonlinear_coeff(d, d_gss, d_jbf);
        case 8  % Joint bilateral filter (twice)
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
        case 9  % Joint bilateral filter (twice)
            gauss = fspecial('gauss', 100, 5);
            d_gss = conv2(d, gauss, 'same');
            d = d/max(max(d));
            d(d > 1) = 1;
            d(d < 0) = 0;
            d_gss = d_gss/(max(max(d_gss)));
            d_gss(d_gss > 1) = 1;
            d_gss(d_gss < 0) = 0;
            d_jbf = jbfilter2(d, d_gss);
            d_jbf = jbfilter2(d, d_jbf);
            d = nonlinear_coeff(d, d_gss, d_jbf);
        otherwise
            gauss = fspecial('gauss', 100, 5);
            d = conv2(d, gauss, 'same');
    end
end

function out = nonlinear_coeff(d, d_gss, d_jbf)

[col, row] = size(d);
coeff_mat = ones(col, row);

for j = 1:col
    for i = 1:row
%         coeff_mat(j, i) = 0.5 + 0.5 * cos(d(j,i) * pi);
        coeff_mat(j, i) = 1 - 1/(1 + exp(-30 * (d(j,i) - 0.4)));
    end
end

out = (ones(col, row) - coeff_mat).*d_gss + coeff_mat.*d_jbf;

end



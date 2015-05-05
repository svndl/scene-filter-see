function plot_allScaleDecomp(scenes, save_path)
    n = numel(scenes.original);
    
    
    laplacian(idx, :) = pyr_orig.ld_corr(1, :);

    %%plot each scene
    
    %%plot all together
    try
        export_fig()
    catch
        saveas();
    end
end

function [pos_idx, neg_idx] = split_data(pyramid)
    p_diff = diff(pyramid, 1, 2);
    %rise
    pos_idx = sum((p_diff > 0), 2) == size(p_diff, 2);
    %fall
    neg_idx = sum((p_diff < 0), 2) == size(p_diff, 2);
    %inconsistent
end
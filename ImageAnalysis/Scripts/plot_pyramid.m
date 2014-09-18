function f = plot_pyramid(pyr, dataX0, dataY, pyrname)
    
    % figure true height (exclude NaNs)
    columns = size(pyr, 2);
    p0 = pyr(~isnan(pyr));
    p1 = reshape(p0, length(p0)/columns, columns);
    
    pyrH = size(p1, 1);
    
    f = figure('Name', pyrname, 'visible', 'off', 'units','normalized','outerposition',[0 0 1 1]);
    scales = {'fine scale', 'mid scale1', 'mid scale 2', 'coarse scale 1', 'coarsest scale 2'};
    xflabel = 'Relative correlatoin at ';
    yflabel = '% more 3d';
    fmarkers = {'*', 'o', '+'};
    legend = {'tp-ap', 'tp-orig', 'orig-ap'};
    orig_label.x = 'Relative correlatoin, original image';
    orig_label.y = yflabel;
    orig_label.legend = legend;
    %
    plot_level(dataX0, dataY, fmarkers, orig_label, 1);
    
    for h = 1:pyrH
        axis_labels.x = strcat(xflabel, scales{h});
        axis_labels.y = yflabel;
        axis_labels.legend = legend;
        plot_level(p1(h, :)', dataY, fmarkers, axis_labels, h + 1);
    end
end
    
function h = plot_level(dataX, dataY, fmarkers, axis_labels, plotnum)

    nsets = numel(fmarkers);
    npoints = length(dataX)/nsets;
    
    subplot(2, 3, plotnum);
    axis tight;
    for n = 1:nsets
        sIdx = npoints*(n - 1) + 1;
        eIdx = npoints*n;
        h = scatter(dataX(sIdx:eIdx), dataY(sIdx:eIdx), fmarkers{n}, 'LineWidth', 2); hold on
    end
    xlabel(axis_labels.x); hold on;
    ylabel(axis_labels.y); hold on;            
    legend(axis_labels.legend{1:end});
    
    % regression
    [p, S, mu] = polyfit(dataX, dataY, 1);
    [rho, pv] = corr(dataX, dataY);  

    [yfit, ~] = polyval(p, dataX ,S, mu);
    plot(dataX, yfit,':k','LineWidth', 2);
    
    %figuring where to put text
    [minX, minInd] = min(dataX);
    %minYX = dataY(minInd);
      
    % range for text was determined empirically
    deltaX = 0.01;
    tx = minX + deltaX;
    ty1 = 0.45;
    ty2 = 0.47;
    
    text(tx, ty1, strcat('p = ', num2str(pv)), 'FontSize',18);
    text(tx, ty2, strcat('r = ', num2str(rho)), 'FontSize',18);
end
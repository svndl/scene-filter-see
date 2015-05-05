function f = plot_ratedScaleDecomp(pyr, dataX0, dataY, pyrname)
        
    pyrH = size(pyr, 1);
    if (strcmp(pyrname, 'Laplacian'))
        pyrH = pyrH -1;
    end
    
    f = figure('Name', pyrname, 'visible', 'off', 'units','normalized','outerposition',[0 0 1 1]);
    scales = {' fine scale',  ' mid scale 1', ' mid scale 2', ' coarse scale 1', ' coarsest scale 2'};
    xflabel = 'Relative correlation at ';
    yflabel = '% more 3d';
    fmarkers = {'*', 'd', '+'};
    legend = {'enhanced-degraded', 'enhanced-original', 'original-degraded'};
    orig_label.x = 'Relative correlation, original image';
    orig_label.y = yflabel;
    orig_label.legend = legend;
    %
    plot_level(dataX0, dataY, fmarkers, orig_label, 1);
    
    for h = 1:pyrH
        axis_labels.x = strcat(xflabel, scales{h});
        axis_labels.y = yflabel;
        axis_labels.legend = legend;
        plot_level(pyr(h, :)', dataY, fmarkers, axis_labels, h + 1);
    end
end
    
function h = plot_level(dataX, dataY, fmarkers, axis_labels, plotnum)

    nsets = numel(fmarkers);
    npoints = length(dataX)/nsets;
    
    subplot(3, 2, plotnum);
    axis tight;
    for n = 1:nsets
        sIdx = npoints*(n - 1) + 1;
        eIdx = npoints*n;
        h = scatter(dataX(sIdx:eIdx), dataY(sIdx:eIdx), fmarkers{n}, 'LineWidth', 2); hold on
    end
    xlabel(axis_labels.x); hold on;
    ylabel(axis_labels.y); hold on;            
    %display legend only for the first plot
    if (plotnum == 1)
        leg = legend(axis_labels.legend{1:end});
        m = findobj(leg, 'type', 'patch');
        set(m, 'LineWidth', 2);
    end
    % regression
    [p, S, mu] = polyfit(dataX, dataY, 1);
    [rho, pv] = corr(dataX, dataY);  

    [yfit, ~] = polyval(p, dataX ,S, mu);
    plot(dataX, yfit,'k','LineWidth', 2);
    
    %figuring where to put text
    minX = min(dataX);
    maxX = max(dataX);
    %minYX = dataY(minInd);
      
    % range for text was determined empirically
    deltaX = 0.01;
    tx = 0.5*(maxX - minX) + deltaX;
    ty1 = 0.43;
    ty2 = 0.47;
    pv_str = num2str(pv, 2);
    rho_str = num2str(rho, 2);
    text(tx, ty1, strcat('p = ', pv_str(1:4)), 'FontSize',16);
    text(tx, ty2, strcat('r = ', rho_str(1:4)), 'FontSize',16);
end
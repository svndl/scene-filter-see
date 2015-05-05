function handle = main_plot(handle, value1, value2, plotTitle, xTitle, yTitle, plot_color, varargin)

    set(0, 'currentfigure', handle);
    
    if (nargin > 7)
        nplots = varargin{2};
        plot_number = varargin{1};
    
        subplot(nplots, 1, plot_number); hold on;
    end     
    title(plotTitle, 'FontSize', 18);    
    
    plot(value1, value2 ,'ko','MarkerFaceColor', plot_color);   
    xlabel(xTitle, 'FontSize', 18);
    ylabel(yTitle, 'FontSize', 18);
    legend(plotTitle);

    lh = lsline;
    set(lh, 'color', plot_color)

    [rho, phi] = corr(value1, value2);
    limX = min(value1);
    limY = min(value2);
    text(2*range(limX)/3 + min(limX), limY + 5, ['r = ' num2str(rho, 2)], 'FontSize', 16);
    text(2*range(limX)/3 + min(limX), limY + 10, ['p = ' num2str(phi, 2)], 'FontSize', 16);
end

function do_plot(pred,percept,paths,title,limX,pyr)
%
% plot whole iamge luminance depth correlation predictors

f = setupfig(6,6.5,10); hold on; suptitle(title);

if ~pyr
    
    % concat all conditions for regression
    pred.all        = [pred.enh_deg pred.enh_orig pred.orig_deg];
    percept.all     = [percept.enh_deg percept.enh_orig percept.orig_deg];
    
    
    subplot(2,2,1); hold on;
    plot_correl(pred.enh_orig,percept.enh_orig,getcolor(1),'Enhanced > Original',1,limX)
    
    subplot(2,2,2); hold on;
    plot_correl(pred.enh_deg,percept.enh_deg,getcolor(2),'Enhanced > Degraded',1,limX)
    
    subplot(2,2,3); hold on;
    plot_correl(pred.orig_deg,percept.orig_deg,getcolor(3),'Original > Degraded',1,limX)
    
    subplot(2,2,4); hold on;
    plot_correl(pred.all,percept.all,'k','All Together',1,limX)
    plot_correl(pred.enh_orig,percept.enh_orig,getcolor(1),'All Together',0,limX)
    plot_correl(pred.enh_deg,percept.enh_deg,getcolor(2),'All Together',0,limX)
    plot_correl(pred.orig_deg,percept.orig_deg,getcolor(3),'All Together',0,limX)
    
else
    
    % concat all conditions for regression
    pred.all        = [pred.enh_deg pred.enh_orig pred.orig_deg];
    percept.all     = cat(2,percept.enh_deg,percept.enh_orig,percept.orig_deg);
    
    pyr_labels = {'Coarse Scale','Mid Scale 1','Mid Scale 2','Fine Scale'};
    
    for p = 1:4
        subplot(2,2,p); hold on;
        plot_correl(pred.all(p,:),percept.all,'k',pyr_labels{p},1,limX)
        plot_correl(pred.enh_orig(p,:),percept.enh_orig,getcolor(1),pyr_labels{p},0,limX)
        plot_correl(pred.enh_deg(p,:),percept.enh_deg,getcolor(2),pyr_labels{p},0,limX)
        plot_correl(pred.orig_deg(p,:),percept.orig_deg,getcolor(3),pyr_labels{p},0,limX)
        
    end
    
end
try
    export_fig([paths.results '/' title '.pdf']);
catch err
    saveas(f, strcat(paths.results, '/', title, '.pdf'), 'pdf');
end
display([ title 'plot has been generated and saved to Results'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_correl(x,y,c,tle,doline,limX)

plot(x,y,'ko','MarkerFaceColor',c);

if(doline)
    lh = lsline;
    set(lh,'color',c)
    [r,p] = corr(x',y');
    text(2*range(limX)/3 + min(limX),40,['r = ' num2str(r,2)]);
    text(2*range(limX)/3 + min(limX),35,['p = ' num2str(p,2)]);
end

plot([-2 2],[50 50],'k:');
plot([0 0],[25 75],'k:');

ylim([25 75]); xlim(limX); box on; axis square;
title(tle);
xlabel('Predictor Magnitude');
ylabel('Percent judged more 3D');




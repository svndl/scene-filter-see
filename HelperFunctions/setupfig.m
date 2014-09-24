function [] = setupfig(wid,ht,ft)
set(gcf ,'windowStyle','normal');
set(gcf,'color','w');
set(gcf, 'Units', 'inches');
set(gcf, 'Position', [1 1 wid ht]);

set(0,'DefaultAxesFontSize', ft)
set(0,'DefaultTextFontSize', ft)

set(0,'DefaultlineMarkerSize',6)
set(0,'defaultlinelinewidth',1)
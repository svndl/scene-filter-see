function [] = plotLuminanceDepthCorrelations()

% This function plots the correlation between luminance and depth in the
% images before and after manipulation

% Emily Cooper, Stanford University 2014


%keep figures all together
set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultAxesFontSize', 28)
set(0,'DefaultAxesFontWeight', 'Normal')
set(0,'DefaultTextFontSize', 28)
set(0, 'DefaultAxesBox', 'on');
set(0,'defaultlinelinewidth',1)

%load scene correlation info
load('luminanceDepthCorrelations.mat')

fntsize = 28;

%get scenes sort indices and correlations
all_rvals = corrDat.corrOrig;
[~,sort_ind] = sort(all_rvals);

%open figure
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
set(gcf,'color','w');
bg = subaxis(1,1,1,'MR',0,'ML',0,'MT',0,'MB',0); hold on; axis off; axis([0 1 0 1]);
pt1 = axes('Position',[0.1 0.4 0.8 0.5]); hold on;

%bar colors
colors1 = gray(8);
colors2 = gray(7);
colors = [ [ones(length(colors1),1) colors1(:,1) colors1(:,1)] ; flipud([colors2(:,1) colors2(:,1) ones(length(colors2),1)]) ];

%category delimiters
a1 = area([0.6 0.9733],[1 1],-1,'FaceColor',[1 1 1],'LineStyle','-');
a2 = area([0.9733 1.0800],[1 1],-1,'FaceColor',[1 1 1],'LineStyle','-');
a3 = area([1.0800 1.4],[1 1],-1,'FaceColor',[1 1 1],'LineStyle','-');

%category titles
text(0.76+0.0265,-0.85,'consistent','HorizontalAlignment','center','FontSize',fntsize,'FontAngle','oblique');
text(1.0265,-0.85,'neutral','HorizontalAlignment','center','FontSize',fntsize,'FontAngle','oblique');
text(1.267-0.0265,-0.85,'inconsistent','HorizontalAlignment','center','FontSize',fntsize,'FontAngle','oblique');

%build structures for bar plots
%original scene corrs
values = cat(1,corrDat.corrOrig(sort_ind),zeros(1,length(corrDat.corrOrig)));
%towards prior
lowerErrors = corrDat.corrTP(sort_ind)-corrDat.corrOrig(sort_ind);
%against prior
upperErrors = corrDat.corrOrig(sort_ind)-corrDat.corrAP(sort_ind);

%plot bars
hbar = bar(values);

%plot additional markers
for col = 1:length(sort_ind)
    
    %get x position
    x = get(get(hbar(col),'children'),'xdata');
    x = mean(x(:,1),1);
    
    %original
    plot(x,[values(1,col)],'ko','LineWidth',1,'MarkerFaceColor',colors(col,:),'MarkerSize',10)
    
    %towards prior
    plot([x x],[values(1,col) values(1,col)+lowerErrors(1,col)],'k-','LineWidth',1)
    plot(x,[values(1,col)+lowerErrors(1,col)],'k^','LineWidth',1,'MarkerFaceColor',colors(col,:),'MarkerSize',10)
    
    %against prior
    plot([x x],[values(1,col) values(1,col)-upperErrors(1,col)],'k-','LineWidth',1)
    plot(x,[values(1,col)-upperErrors(1,col)],'kv','LineWidth',1,'MarkerFaceColor',colors(col,:),'MarkerSize',10)
    
    bar_loc(col) = x;
end

box on
axis([0.599 1.4 -1.001 1.001]);

set(pt1,'XTick',bar_loc);
set(pt1,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'});
set( pt1, 'YDir', 'reverse' );
ylabel('Luminance/Depth Correlation');
xlabel('Scenes');
colormap(colors);

addpath('../../../HelperFunctions/export_fig');

export_fig './luminanceDepthCorrelationPlot' -pdf


function [] = plotPerceptualResults()

% This function reproduces the bar plots of perceptual results from the
% experiment

% Emily Cooper, Stanford University 2014


%add path to helpful functions
addpath('../../../HelperFunctions/','../../../HelperFunctions/export_fig');

%main experiment
main = load('../../Data/mainExperimentData.mat');

%control experiment
cont = load('../../Data/controlExperimentData.mat');


%figure 3 panel A - all 6 pairwise condition comparisions for main
%experiment

%conditions to compare
label = {'s v o',   's v tp',   's v ap',   'tp v ap',  'tp v o',   'o v ap'};
cond1 = {'stereo',  'stereo',   'stereo',   'tp',       'tp',       'orig'};
cond2 = {'orig',    'tp',       'ap',       'ap',       'orig',     'ap'};

for c = 1:length(cond1)
    
    cond1vcond2 = main.data.trials.resp_Amore3DthanB( ...
    main.data.trials.condA == find(ismember(main.data.conditionTypes,cond1{c})) & ...
    main.data.trials.condB == find(ismember(main.data.conditionTypes,cond2{c})) ...
    );

    if c < 6
        [cond1vcond2Bar(c),cond1vcond2CI(:,c)] = binofit(sum(cond1vcond2),numel(cond1vcond2));
    else
        %invert this one so it compares ap to orig, not orig to ap
        [cond1vcond2Bar(c),cond1vcond2CI(:,c)] = binofit(sum(~cond1vcond2),numel(cond1vcond2));
    end
    
end

%error values
cond1vcond2CI = abs(cond1vcond2CI - repmat(cond1vcond2Bar,2,1));

%figure style
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
set(gcf,'color','w');
bg = subaxis(1,1,1,'MR',0,'ML',0,'MT',0,'MB',0); hold on; axis off; axis([0 1 0 1]);
pt1 = axes('Position',[0.1 0.4 0.5 0.5]); hold on;

%plot bars
b = barwitherr(100.*cond1vcond2CI',100.*cond1vcond2Bar','EdgeColor',[0 0 0]);
set(b(1),'FaceColor',[0.6 0.6 0.6]);
set(b,'barwidth',0.75)
ylabel('Percent judged more 3D')
hold on;
plot([0 7],[50 50],'k--');
ylim([0 100])
xlim([0 7]);
set(gca,'XTickLabel',{'s v o','s v tp','s v ap','tp v ap','tp v o','ap v o'})

export_fig './perceptualResultsPlot1' -pdf

%values reported in paper
display(['percent stereo preferred: ' num2str(mean([cond1vcond2Bar(1:3)]),2)]);
display(['percent tp preferred over ap: ' num2str(cond1vcond2Bar(4),2)]);
display(['percent tp preferred over orig: ' num2str(cond1vcond2Bar(5),2)]);
display(['percent ap preferred over orig: ' num2str(cond1vcond2Bar(6),2)]);


%figure 3 panel B - each scene separately for the tp v ap comparison
%also grab image info of - greater perceived contrast, greater lum/depth
%correlation, greater variance
for s = 1:length(main.data.scenesListSorted)
    
    %grab the relevant trials
    tpvapInds = main.data.trials.scene_number == s & ...
        main.data.trials.condA == find(ismember(main.data.conditionTypes,'tp')) & ...
        main.data.trials.condB == find(ismember(main.data.conditionTypes,'ap'));
    
    tpVorigInds = main.data.trials.scene_number == s & ...
        main.data.trials.condA == find(ismember(main.data.conditionTypes,'tp')) & ...
        main.data.trials.condB == find(ismember(main.data.conditionTypes,'orig'));
    
    origVapInds = main.data.trials.scene_number == s & ...
        main.data.trials.condA == find(ismember(main.data.conditionTypes,'orig')) & ...
        main.data.trials.condB == find(ismember(main.data.conditionTypes,'ap'));
    
    
    %percent more 3D
    tpVap = main.data.trials.resp_Amore3DthanB(tpvapInds);
    tpVorig = main.data.trials.resp_Amore3DthanB(tpVorigInds);
    origVap = main.data.trials.resp_Amore3DthanB(origVapInds);
    
    [tpVapBar(s),tpVapCI(:,s)] = binofit(sum(tpVap),numel(tpVap));
    [tpVorigBar(s),tpVorigCI(:,s)] = binofit(sum(tpVorig),numel(tpVorig));
    [origVapBar(s),origVapCI(:,s)] = binofit(sum(origVap),numel(origVap));
    

    %lum depth correlation
    tpCorrVapCorr(s) = unique(main.data.trials.AcorrMinusBcorr(tpvapInds));
    tpCorrVorigCorr(s) = unique(main.data.trials.AcorrMinusBcorr(tpVorigInds));
    origCorrVapCorr(s) = unique(main.data.trials.AcorrMinusBcorr(origVapInds));
    
    %image contrast difference
    tpVarVapVar(s) = unique(main.data.trials.AvarMinusBvar(tpvapInds));
    tpVarVorigVar(s) = unique(main.data.trials.AvarMinusBvar(tpVorigInds));
    origVarVapVar(s) = unique(main.data.trials.AvarMinusBvar(origVapInds));
    
    
    %percent more Contrast
    tpvapCInds = cont.data.trials.scene_number == s & ...
        cont.data.trials.condA == find(ismember(cont.data.conditionTypes,'tp')) & ...
        cont.data.trials.condB == find(ismember(cont.data.conditionTypes,'ap'));
    
    tpVorigCInds = cont.data.trials.scene_number == s & ...
        cont.data.trials.condA == find(ismember(cont.data.conditionTypes,'tp')) & ...
        cont.data.trials.condB == find(ismember(cont.data.conditionTypes,'orig'));
    
    origVapCInds = cont.data.trials.scene_number == s & ...
        cont.data.trials.condA == find(ismember(cont.data.conditionTypes,'orig')) & ...
        cont.data.trials.condB == find(ismember(cont.data.conditionTypes,'ap'));
    
    
    tpVapC = cont.data.trials.resp_AmoreContrastthanB(tpvapCInds);
    tpVorigC = cont.data.trials.resp_AmoreContrastthanB(tpVorigCInds);
    origVapC = cont.data.trials.resp_AmoreContrastthanB(origVapCInds);
    
    [tpVapBarC(s),tpVapCCI(:,s)] = binofit(sum(tpVapC),numel(tpVapC));
    [tpVorigBarC(s),tpVorigCCI(:,s)] = binofit(sum(tpVorigC),numel(tpVorigC));
    [origVapBarC(s),origVapCCI(:,s)] = binofit(sum(origVapC),numel(origVapC));
    
    
end

%error values
cond1vcond2CI = abs(tpVapCI - repmat(tpVapBar,2,1));

fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
set(gcf,'color','w');
bg = subaxis(1,1,1,'MR',0,'ML',0,'MT',0,'MB',0); hold on; axis off; axis([0 1 0 1]);
pt1 = axes('Position',[0.1 0.4 0.5 0.5]); hold on;

%category delimiters
a1 = area([0.6 0.9733],[100 100],0,'FaceColor',[1 1 1],'LineStyle','-');
a2 = area([0.9733 1.0800],[100 100],0,'FaceColor',[1 1 1],'LineStyle','-');
a3 = area([1.0800 1.4],[100 100],0,'FaceColor',[1 1 1],'LineStyle','-');

%get bar locations
hbar = bar(cat(1,tpVapBar,zeros(1,length(tpVapBar))));
for col = 1:length(tpVapBar)
    x = get(get(hbar(col),'children'),'xdata');
    bar_loc(col) = mean(x(:,1),1);
end

%bar colors
colors1 = gray(8);
colors2 = gray(7);
colors  = [ [ones(length(colors1),1) colors1(:,1) colors1(:,1)] ; flipud([colors2(:,1) colors2(:,1) ones(length(colors2),1)]) ];

%plot bars
b = barwitherr(100.*cat(3,cat(1,cond1vcond2CI(1,:),zeros(1,length(tpVapBar))), ...
    cat(1,cond1vcond2CI(1,:),zeros(1,length(tpVapBar)))), ...
    100.*cat(1,tpVapBar,zeros(1,length(tpVapBar))),'EdgeColor',[0 0 0]); hold on;

%plot chance
plot([0 2],[50 50],'k--');
box on
axis([0.599 1.4 0 100]);

set(pt1,'XTick',bar_loc);
set(pt1,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'});
ylabel('Percent judged more 3D');
xlabel('Scenes');
colormap(colors);

export_fig './perceptualResultsPlot2' -pdf


%compare main experiment results to contrast control
allbars     = [tpVapBar tpVorigBar origVapBar] - 0.5; %main experiment, above or below chance
allbarsC    = [tpVapBarC tpVorigBarC origVapBarC] - 0.5; %control experiment, above or below chance
allbarsVar  = [tpVarVapVar tpVarVorigVar origVarVapVar]; %image variance, greater (positive) or less
allbarsCorr = -[tpCorrVapCorr tpCorrVorigCorr origCorrVapCorr]; %lum/depth correlation, more consisnt (positive) or less

prefThresh = 0.05; %we only count preferences greater than this

expPrefs        = sign(allbars).*(abs(allbars) >= prefThresh);
expPrefsC       = sign(allbarsC).*(abs(allbarsC) >= prefThresh);
expPrefsVar     = sign(allbarsVar).*(abs(allbarsVar) >= 0);
expPrefsCorr    = sign(allbarsCorr).*(abs(allbarsCorr) >= 0);

display(['total number of images with a 3D preference = ' num2str(sum(expPrefs ~= 0))]);

display(['% of these scenes with the same contrast preference = ' num2str(sum(expPrefs ~= 0 & expPrefsC == expPrefs)./sum(expPrefs ~= 0))]);
display(['% of these scenes with more image variance = ' num2str(sum(expPrefs ~= 0 & expPrefsVar == expPrefs)./sum(expPrefs ~= 0))]);
display(['% of these scenes more consistent with lum/depth = ' num2str(sum(expPrefs ~= 0 & expPrefsCorr == expPrefs)./sum(expPrefs ~= 0))]);

display(['% tp judged more contrast = ' num2str(mean(mean(tpVapBarC)))]);
display(['correlation between = ' num2str(corr(tpVapBar',tpVapBarC'))]);

keyboard

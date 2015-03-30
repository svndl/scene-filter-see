function do_plot_model(paths, brain, image)

% load environmental distributions
env.feature = 'disp';
env         = get_environ_stats(env); % env has the following fields: bright, dark, all, rng

% set up default brain model properties
model.N           = 7;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'uniform';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'uniform';                        % cell population response gain ('uniform' or 'optimal')

model1 = build_model_cell_population(env, model);

% set up optimized model
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

model2 = build_model_cell_population(env, model);
model2.env = model1.env;


% set up optimized model for decoding
model.N           = 7;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

model3 = build_model_cell_population(env, model);


% figure of uniform and optimal populations

f1 = setupfig(6,6.5,10); hold on;

subplot(3,2,1:2); hold on; title('Environmental Probabilities');
h(1) = plot(env.rng,env.bright./sum(env.bright),'r');
h(2) = plot(env.rng,env.dark./sum(env.dark),'b');
xlabel('Binocular Disparity (arcmin)');
ylabel('Probability ON/OFF');
xlim([min(env.rng) max(env.rng)]);
legend(h,'brights','darks');

text(-50,3.5e-3,'A','fontweight','bold');

plot_tuning_curves(model1,1)
text(0,72,'B','fontweight','bold');

plot_tuning_curves(model2,2)
text(0,72,'C','fontweight','bold');

savestr = strcat(paths.results,'/Model Framework.pdf');
try
    export_fig(savestr);
catch err
    saveas(f1, savestr, 'pdf');
end


ind = 8;
rdblcmap = gray;

%rdblcmap = [cat(2,ones(size(rdblcmap,1),1),rdblcmap(:,1),rdblcmap(:,1))];
%rdblcmap = cat(1,rdblcmap,cat(2,flipud(rdblcmap(:,2)),flipud(rdblcmap(:,3)),ones(size(rdblcmap,1),1)));

rdblcmap = [cat(2,rdblcmap(:,1),rdblcmap(:,1),ones(size(rdblcmap,1),1))];
rdblcmap = cat(1,rdblcmap,cat(2,ones(size(rdblcmap,1),1),flipud(rdblcmap(:,1)),flipud(rdblcmap(:,2))));


% figure of decoding

f2 = setupfig(6,4,10); hold on;

br_resp = model3.resp_bright(:,model3.env.rng == 0);
dk_resp = model3.resp_dark(:,model3.env.rng == 0);

br_sol = wmean(model3.preferences',br_resp);
dk_sol = wmean(model3.preferences',dk_resp);

subplot(2,3,1); hold on;
plot(model3.preferences,br_resp,'ro-','markerfacecolor','r')
plot(model3.preferences,dk_resp,'bo-','markerfacecolor','b')

xlabel('Binocular Disparity (arcmin)');
xlabel('Neuron Responses');
text(40,14,'d = 0');
text(-50,16,'A','fontweight','bold');
xlim([-60 60]);

subplot(2,3,4); hold on;
plot(model3.preferences,br_resp,'ro-','markerfacecolor','r')
plot(model3.preferences,dk_resp,'bo-','markerfacecolor','b')

text(-5,16,'B','fontweight','bold');

plot(br_sol,5,'kv','markerfacecolor','r');
plot(dk_sol,5,'kv','markerfacecolor','b');
xlabel('Binocular Disparity (arcmin)');
xlabel('Neuron Responses');
xlim([-6 6]);

subplot(2,3,2); hold on; title('{\bf C }Original image');
imagesc(flipud(brain(ind).orig.image.pixels)); colormap gray; axis image off; freezeColors

subplot(2,3,5); hold on; title('{\bf E }Bright/dark image');
imagesc(flipud(brain(ind).orig.image.rgc)); colormap(rdblcmap); axis image off; freezeColors
caxis([-brain(ind).orig.image.max brain(ind).orig.image.max]);

subplot(2,3,6); hold on; title('{\bf F }Decoded depth map')
imagesc(flipud(brain(ind).orig.disparity)); colormap gray; axis image off;

subplot(2,3,3); hold on; title('{\bf D }True depth map')
imagesc(flipud(image(ind).depth)); colormap cool; axis image off;

savestr = strcat(paths.results,'/Model Example.pdf');

try
    export_fig(savestr)
catch err
    saveas(f2, savestr, 'pdf');
end

keyboard

% 
% subplot(3,2,4); hold on; xlabel('Image');
% imagesc(brain(1).orig.image.rgc);
% axis image; colorbar; colormap gray;
% caxis([-1 1]);
% 
% subplot(3,2,6); hold on; xlabel('Disparity Map (arcmin)');
% imagesc(brain(1).orig.disparity);
% axis image; colorbar

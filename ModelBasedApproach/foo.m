close all;
clear all;

addpath(genpath('..'));
testing  = 1;

% set up brain model to use

model.N           = 15;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')
model.feature     = 'disp';

model = build_model_cell_population(model);

% load in image and disparity map

if(testing)
    image.pixels    = mkFract(124,1.2);
    image.pixels    = (image.pixels - min(image.pixels(:)))./range(image.pixels(:));
    image.depth     = mkFract(124,1);
    image.depth    = (image.depth - min(image.depth(:)))./range(image.depth(:));
else
end

image = convert_image_to_rgc_response(image);
image = convert_depth_to_disparity(image);

brain = apply_model_to_image(model,im,dispmap);

figure;  hold on;
plot_tuning_curves(model)

keyboard
plot_env_probabilities(disps,r_inc,env_inc,env_dec,env_all,prefs_new,feature)


% Fisher info for equal and learned gains
fnMax = max([fnON fnOFF fnON2 fnOFF2]) + 0.05*range([fnON fnOFF fnON2 fnOFF2]);
fnMin = min([fnON fnOFF fnON2 fnOFF2]) - 0.05*range([fnON fnOFF fnON2 fnOFF2]);
subaxis(4,3,5,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
plot_fisher(disps,fnON,'r',[fnMin fnMax],feature)
plot_fisher(disps,fnOFF,'b--',[fnMin fnMax],feature)

subaxis(4,3,6,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
plot_fisher(disps,fnON2,'r',[fnMin fnMax],feature)
plot_fisher(disps,fnOFF2,'b--',[fnMin fnMax],feature)



% subaxis(4,6,12,'Spacing',spac, 'Padding',pad, 'Margin',marg); hold on;
% plot_discrimination(disps,fnON2,'r',[discMin discMax],feature)
% plot_discrimination(disps,fnOFF2,'b--',[discMin discMax],feature)


% mutual info as a function of spike rate
miMax = max([MI MI2 MIBr MIBr2 MIDk MIDk2]) + 0.05*range([MI MI2 MIBr MIBr2 MIDk MIDk2]);
miMin = min([MI MI2 MIBr MIBr2 MIDk MIDk2]) - 0.05*range([MI MI2 MIBr MIBr2 MIDk MIDk2]);
subaxis(4,3,8,'Spacing',spac, 'Padding',pad, 'Margin',marg);
plot_X_for_Rs(Rsim,MI,MIBr,MIDk,[miMin miMax],'mutual information')

subaxis(4,3,9,'Spacing',spac, 'Padding',pad, 'Margin',marg);
plot_X_for_Rs(Rsim,MI2,MIBr2,MIDk2,[miMin miMax],'mutual information')





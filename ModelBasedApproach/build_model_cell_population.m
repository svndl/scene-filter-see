function [model] = build_model_cell_population(popDensity,popGain,showPlots,R,N,feature)
%
% Model information carried in V1 complex cells as a function of Hebbian
% learning
%
% Emily Cooper, Stanford University, 2014
%
%
% popDensity: spacing of cells in environment
%
%           1 = uniform spacing
%           2 = optimized spacing
% popGain:
%           1 = uniform gain
%           2 = optimizied gain
%
% N,R:      number of neurons and max population spike rate
% feature:  which visual property to analyze - 'f' for theoretical
%            uniform variable, 'disp' for binocular disparity
%

addpath('./helper_functions_modeling/')


% Visual feature properties in the environment
[e_br,e_dk,e_all,rng]     = get_environ_stats(feature);         % environmental probabilities for increments and decrements

% Model cell properties
prefs                       = linspace(min(rng),max(rng),N);    % tuning preference locations
spacing                     = range(prefs)/N;                   % spacing between cells
cell_sigma                  = 0.55*spacing;                     % this sigma tiles spacing approx. uniformly in for Gaussian cells


% Population type specific parameters                       
if strcmp(popDensity,'uniform')  
    pop = ones(1,length(rng))/length(rng);                      % uniform cell spacing   
elseif strcmp(popDensity,'optimal')
    pop = e_all;  end                                           % optimal cell spacing 

warp                        = make_warping_function(pop,rng);   % Tuning preference warping - guided by the integral of the population prior

% Generate tuning function for each cell
for d = 1:N
    
    pref                = prefs(d);                         % this cells original tuning preference           
    prefs_new(d)        = interp1(warp,rng,pref);   % find inverse of cumsum distribution                                    % new peak location 
    cell_response       = spacing * gaussian_tuning(pref,cell_sigma,warp);                             % Gaussian tuning function of cell
    [g_br(d),g_dk(d)]   = set_response_gain(popGain,rng,e_all,e_br,e_dk,prefs_new(d));   % gain for population type

    r_br(d,:)        = R * g_br(d) * cell_response;                                                     % tuning function response ON
    r_dk(d,:)        = R * g_dk(d) * cell_response;                                                     % tuning function response ON

end

model.feature = feature;
model.rng = rng;
model.e_br = e_br;
model.e_dk = e_dk;
model.e_all = e_all;

model.r_br = r_br;
model.r_dk = r_dk;


% fnON                = compute_fisher(cell_firing_inc);              % Fisher information when stimulus is ON
% fnOFF               = compute_fisher(cell_firing_dec);              % Fisher information when stimulus if OFF
%     
% % Lower bound on Mutual information with scene prior
% %MI                  = compute_MI_new(env_inc,env_dec,r_inc,unit_vals,fnON,fnOFF);  % Weighted MI according to overall ON ratio
% %MIBr = MI;
% %MIDk = MI;
% 
% MIBr                = compute_MI(env_inc,fnON);           % Mutual information between ON firing and ON stimulus
% MIDk                = compute_MI(env_dec,fnOFF);          % Mutual information between OFF firing and OFF sitmulus
% MI                  = ( r_inc * MIBr ) + ( ( 1 - r_inc ) * MIDk );  % Weighted MI according to overall ON ratio
% 
% % Visualize Results
% if(showPlots)
%     plot_model(disps,env_inc,env_dec,env_all,pop,warp,N,prefs_new,resp_inc,resp_dec,gainON,fnON,fnOFF); 
% end

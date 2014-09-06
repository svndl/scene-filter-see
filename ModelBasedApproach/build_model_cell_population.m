function [m] = build_model_cell_population(m)
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

% Visual feature properties in the environment
[m.e_br,m.e_dk,m.e_all,m.rng]     = get_environ_stats(m.feature);         % environmental probabilities for increments and decrements

% Model cell properties
prefs                       = linspace(min(m.rng),max(m.rng),m.N);    % tuning preference locations
spacing                     = range(prefs)/m.N;                   % spacing between cells
m.cell_sigma                  = 0.55*spacing;                     % this sigma tiles spacing approx. uniformly in for Gaussian cells

% Population type specific parameters                       
if strcmp(m.popDensity,'uniform')  
    m.pop = ones(1,length(m.rng))/length(m.rng);                      % uniform cell spacing   
elseif strcmp(m.popDensity,'optimal')
    m.pop = m.e_all;  end                                           % optimal cell spacing 

warp                        = make_warping_function(m);   % Tuning preference warping - guided by the integral of the population prior

% Generate tuning function for each cell
for d = 1:m.N
    
    pref                = prefs(d);                         % this cells original tuning preference           
    m.prefs_new(d)        = interp1(warp,m.rng,pref);   % find inverse of cumsum distribution                                    % new peak location 
    cell_response       = spacing * gaussian_tuning(pref,m.cell_sigma,warp);                             % Gaussian tuning function of cell
    [m.g_br(d),m.g_dk(d)]   = set_response_gain(m,m.prefs_new(d));   % gain for population type

    m.r_br(d,:)        = m.R * m.g_br(d) * cell_response;                                                     % tuning function response ON
    m.r_dk(d,:)        = m.R * m.g_dk(d) * cell_response;                                                     % tuning function response ON

end


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

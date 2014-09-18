function model = build_model_cell_population(env, params)
%
% Model information carried in V1 complex cells as a function of Hebbian
% learning
%
% Emily Cooper, Stanford University, 2014
% 
% params structure:
% params.popDensity -- 'uniform' or 'optimal'
% params.popGain -- 'uniform' or 'optimal'
% params.N, params.R -- number of neurons and max population spike rate
% params.feature -- visual property to analyze 'f' for theoretical
% uniform variable, 'disp' for binocular disparity

    %% Model cell properties
    
    % tuning preference locations
    prefs = linspace(min(env.rng), max(env.rng), params.N);   
    % spacing between cells    
    spacing = range(prefs)/params.N;                   
    % this sigma tiles spacing approx. uniformly in for Gaussian cells
    cell_sigma = 0.55*spacing;                     


    %% Population type specific parameters    
    switch params.popDensity
        case 'uniform'  
            pop = ones(1, length(env.rng))/length(env.rng);                     
        case 'optimal'
            pop = env.all;
        otherwise
    end                                           

    warp = make_warping_function(pop, env.rng);   % Tuning preference warping - guided by the integral of the population prior

    new_prefs = interp1(warp, env.rng, prefs);
    cell_response = spacing * gaussian_tuning(prefs, cell_sigma, warp); 
    gain = set_response_gain(params.popGain, env, new_prefs);
    r_bright = params.R *repmat(gain.bright, length(warp), 1)'.*cell_response; 
    r_dark = params.R *repmat(gain.dark, length(warp), 1)'.*cell_response;
    
    
    model.feature = params.feature;
    model.rng = env.rng;
    model.e_bright = env.bright;
    model.e_dark = env.dark;
    model.e_all = env.all;

    model.r_bright = r_bright;
    model.r_dark = r_dark;
end
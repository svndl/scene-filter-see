function model = model_mkCellPopulation(env, model)
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
    prefs = linspace(min(env.rng), max(env.rng), model.N);   
    % spacing between cells    
    spacing = range(prefs)/model.N;                   
    % this sigma tiles spacing approx. uniformly in for Gaussian cells
    cell_sigma = 0.55*spacing;                     


    %% Population type specific parameters    
    switch model.popDensity
        case 'uniform'  
            pop = ones(1, length(env.rng))/length(env.rng);                     
        case 'optimal'
            pop = env.all;
        otherwise
    end                                           

    warp = model_mkWarpingFn(pop, env.rng);   % Tuning preference warping - guided by the integral of the population prior

    new_prefs = interp1(warp, env.rng, prefs);
    cell_response = spacing * model_mkGaussianTuning(prefs, cell_sigma, warp); 
    gain = model_setResponseGain(model.popGain, env, new_prefs);
    resp_bright = model.R *repmat(gain.bright, length(warp), 1)'.*cell_response; 
    resp_dark = model.R *repmat(gain.dark, length(warp), 1)'.*cell_response;
    
    
    model.env = env;
    model.gain = gain;
    model.response = model.R*cell_response;
    model.preferences = new_prefs;
    model.resp_bright = resp_bright;
    model.resp_dark = resp_dark;
end
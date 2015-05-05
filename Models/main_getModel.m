function model = main_getModel(varargin)

    if(nargin == 0)
        feature = 'disp';
        cell_pop = 'optimal';
    end
    
    env.feature = feature;
    env         = model_getEnvStats(env); % env has the following fields: bright, dark, all, rng
    % set up brain model properties
    model.N           = 120;                              % number of neurons for simulation
    model.R           = 50;                               % mean population firing rate
    model.popDensity  = cell_pop;                        % cell population density ('uniform' or 'optimal'
    model.popGain     = cell_pop;                        % cell population response gain ('uniform' or 'optimal')
    model = model_mkCellPopulation(env, model);    
end
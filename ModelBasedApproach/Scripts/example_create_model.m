function model = example_create_model


env.feature      = 'disp';
%% Visual feature properties in the environment
% environmental probabilities for brights and darks
% env is a structure with the folloving fields:
% env.bright
% env.dark
% env.all
% env.rng

env = get_environ_stats(env.feature);

% set up brain model to use

model.N           = 120;                              % number of neurons for simulation
model.R           = 50;                               % mean population firing rate
model.popDensity  = 'optimal';                        % cell population density ('uniform' or 'optimal'
model.popGain     = 'optimal';                        % cell population response gain ('uniform' or 'optimal')

model = build_model_cell_population(env, model);

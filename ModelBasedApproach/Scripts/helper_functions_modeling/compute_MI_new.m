function [MI] = compute_MI_new(env_inc,env_dec,r_inc,unit_vals,fnON,fnOFF)

% compute the mutual information between an environmental probability
% distribution (with unit spacing) and the Fisher information in a neural
% population

env = [r_inc*env_inc (1-r_inc)*env_dec];

env_fn = [r_inc*env_inc(1:end-1) (1-r_inc)*env_dec(1:end-1)];
fn = [fnON fnOFF];

H = -sum((env/sum(env)) ...               % differential entropy of probability density prior distribution
    .* log2((env/sum(env))));              % note: if this is gaussian, entropy has simple solution: 0.5*log(2*pi*exp(1)*(sigma^2))

MI = H + (1/2) * sum( (env_fn/sum(env_fn)) .* log2(fn/(2*pi*exp(1))) );  % Mutual information

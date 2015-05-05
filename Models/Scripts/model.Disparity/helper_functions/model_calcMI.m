function MI = model_calcMI(env,fn)

% compute the mutual information between an environmental probability
% distribution (with unit spacing) and the Fisher information in a neural
% population


H = -sum((env/sum(env)) ...               % entropy of probability density prior distribution
    .* log((env/sum(env))));              % note: if this is gaussian, entropy has simple solution: 0.5*log(2*pi*exp(1)*(sigma^2))


MI = H + (1/2) * sum( (env(1:end-1)/sum(env(1:end-1))) .* log(fn/(2*pi*exp(1))) );  % Mutual information

%H = -sum(env ...               % entropy of probability density prior distribution
%    .* log(env));              % note: if this is gaussian, entropy has simple solution: 0.5*log(2*pi*exp(1)*(sigma^2))

%MI = H + (1/2) * sum( env(1:end-1) .* log(fn/(2*pi*exp(1))) );  % Mutual information
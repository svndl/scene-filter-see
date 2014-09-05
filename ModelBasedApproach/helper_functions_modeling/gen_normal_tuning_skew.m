function [resp] = gen_normal_tuning_skew(mu,s,p,k,range)

% evaluate generalized normal distribution with mean u, sigma s, power p, and skewness k over supplied range


alpha = s*sqrt(2); %alpha variable is equal to variance/2

pdf = p / (2*alpha*gamma(1/p)) * exp( -(abs(range-mu)/alpha).^p );
cdf = 1/2 + sign(k*(range-mu)) .* (gammainc((abs(k*(range-mu)/alpha)).^p, 1/p, 'lower')) / (2*gamma(1/p));
resp = 2 * pdf .* cdf;

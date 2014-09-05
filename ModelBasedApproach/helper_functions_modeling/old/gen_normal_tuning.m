function [resp] = gen_normal_tuning(mu,s,p,range)

% evaluate generalized normal distribution with mean u, sigma s, and power p over supplied range


resp = ( p/( 2*s*gamma(1/p)*sqrt(2) ) )* ...
    exp( -abs( (range-mu) / ( s*sqrt(2) ) ).^p );

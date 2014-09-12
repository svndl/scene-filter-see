function [resp] = gaussian_tuning(u,s,range);

% evaluate gaussian distribution with mean u and sigma s over supplied range

resp = ( 1/( s*sqrt(2*pi) ) )* ...
    exp( -1/2.* ( ( range - u )./s ) .^2 );
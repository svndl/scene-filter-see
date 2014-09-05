function [warp] = make_warping_function(pop,rng)
%
% warping function for an optimal neuronal population is the integral of
% the environmental probability distribution (see Ganguli & Simoncelli
% 2010)
%

warp    = cumsum(pop) - pop(1);                     % take cumulative
warp    = (range(rng)/range(warp))*warp + min(rng); % normalize cumsum of the prior to full stimulus range


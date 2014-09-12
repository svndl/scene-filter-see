function [warp] = make_warping_function(m)
%
% warping function for an optimal neuronal population is the integral of
% the environmental probability distribution (see Ganguli & Simoncelli
% 2010)
%

warp    = cumsum(m.pop) - m.pop(1);                     % take cumulative
warp    = (range(m.rng)/range(warp))*warp + min(m.rng); % normalize cumsum of the prior to full stimulus range


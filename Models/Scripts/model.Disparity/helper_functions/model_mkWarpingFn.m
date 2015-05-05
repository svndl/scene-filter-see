function warp_n = model_mkWarpingFn(pop, rng)
%
% warping function for an optimal neuronal population is the integral of
% the environmental probability distribution (see Ganguli & Simoncelli
% 2010)
%
    % take cumulative
    warp = cumsum(pop) - pop(1);                     
    
    % normalize cumsum of the prior to full stimulus range
    warp_n = (range(rng)/range(warp))*warp + min(rng); 
end


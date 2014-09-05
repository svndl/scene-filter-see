function [warp] = make_warping_function(pop,disps)

% warping function for an optimal neuronal population is the integral of the prior assumption
% if doing discrimination maximumization, take the prior to the power of 0.5

warp = cumsum(pop) - pop(1);
warp = (range(disps)/range(warp))*warp + min(disps); % normalize cumsum of the prior to full disparity range


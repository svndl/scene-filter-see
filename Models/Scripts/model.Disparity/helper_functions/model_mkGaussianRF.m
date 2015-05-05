function filt = model_mkGaussianRF(x,sig)

filt     = exp( -x.^2 / (2*sig^2) );      % central gaussian
filt     = filt'*filt;              % make it 2D
filt     = filt / sum(filt(:));     % normalize to sum to 1
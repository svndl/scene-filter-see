function  [fn] = compute_fisher(resp)

% compute Fisher information of a neuronal population

fn  = zeros( 1, size(resp,2)-1 );                                   % initialize matrix

for k = 1:size(resp,1)                                              % for each neuron
    crTmp                   = resp(k,:);                            % grab tuning function
    crTmp(crTmp < 1e-100)   = 1e-100;                               % set zeros to be very small so that FN goes to zero rather than infinity - NEED TO CHECK THIS
    
    fn                      = fn + ...
                            ( (diff(crTmp).^2) ./ crTmp(1:end-1) ); % add the FN into the running population sum
end

fn(fn == 0)                 = 1e-100;                               % give fn small values to avoid undefined mutual information
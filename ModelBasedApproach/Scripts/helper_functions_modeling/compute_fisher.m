function fn = compute_fisher(resp)
% compute Fisher information of a neuronal population     
    crTmp = resp;
    
    crTmp(crTmp < 1e-100) = 1e-100;
    fn_m = (diff(crTmp, 1, 2).^2)./crTmp(:, 1:end - 1);
    fn = sum(fn_m);

    % give fn small values to avoid undefined mutual information
    fn(fn == 0) = 1e-100;                              
end
function resp = gen_normal_tuning(mu, s, pw, x)
% evaluate generalized normal distribution with mean mu, sigma s, and power
% p over supplied range rng
    %support vector mu 
    
    x1 = repmat(x, length(mu), 1);
    mu1 = repmat(mu, length(x), 1)';

    resp = (pw/( 2*s*gamma(1/pw)*sqrt(2)))*exp( -abs((x1 - mu1)/( s*sqrt(2))).^pw);
end

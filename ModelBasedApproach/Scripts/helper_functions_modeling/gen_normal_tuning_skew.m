function resp = gen_normal_tuning_skew(mu, s, pw, k, x)
% evaluate generalized normal distribution with 
% Input parameters: 
% {mu, s, pw} -- mean, variance and power
% {k, x} -- skewness over supplied range x

    %alpha variable is equal to variance/2
    a = s*sqrt(2); 
    
    %to support vector mu
    x1 = repmat(x, length(mu), 1);
    mu1 = repmat(mu, length(x), 1)';
    x_mu = x1 - mu1;
    
    %probability distribution function
    pdf = pw/(2*a*gamma(1/pw))*exp( -(abs(x_mu)/a).^pw );
    
    %cumulative distribution function
    cdf = 0.5 + sign(k*(x_mu)).*...
        (gammainc((abs(k*(x_mu)/a)).^pw, 1/pw, 'lower'))/(2*gamma(1/pw));
    resp = 2*pdf.* cdf;
end

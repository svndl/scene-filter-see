function resp = gaussian_tuning(mu, s, x)
    
    %resp = zeros(length(mu), length(x));
    % enable vector support
    % new x will be the 
    x1 = repmat(x, length(mu), 1);
    mu1 = repmat(mu, length(x), 1)';
    % i-th row will be x - mu(i)    
    % evaluate gaussian distribution with mean u and sigma s over supplied range
    
    resp = 1/( s*sqrt(2*pi) )*exp(-0.5*((x1 - mu1)./s ).^2);
end
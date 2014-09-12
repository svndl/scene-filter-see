function [e] = get_environ_stats(e)
%
% get statistical distributions for brights, darks, and overall for the
% feature
%

if strcmp(e.feature,'f')
    
    % theoretical visual features has a uniform distribution
    
    e.rng     = -49:49;                                       % visual feature values
    e.br    = 0.5*ones(1,length((e.rng)))./length(e.rng);   % probabilities for brights
    e.dk    = e.br;                                         % probabilities for darks
    
elseif strcmp(e.feature,'disp')
    
    nss = load('../EnvironStats/nss_basic.mat');
    
    % binocular disparities in the Van Hateren dataset
    
    numsamples = 1001;
    
    e.rng     = linspace(-60,60,numsamples);         % disparity values (arminutes)
    Xz      = linspace(-60,60,length(nss.vh.Xz(2:end-1)));
    e.br    = nss.vh.pON*nss.vh.Zon(2:end-1);                   % proportion bright amplitude * bright distribution
    e.dk    = nss.vh.pOFF*nss.vh.Zoff(2:end-1);
    
    % sub sample for smooth modeling
    
    e.br = interp1(Xz,e.br,e.rng);
    e.dk = interp1(Xz,e.dk,e.rng);
    
end

e.all   = e.br + e.dk;                                         % overall probability
function [e_br,e_dk,e_all,rng] = get_environ_stats(feature)
%
% get statistical distributions for brights, darks, and overall for the
% feature
%

if strcmp(feature,'f')
    
    % theoretical visual features has a uniform distribution
    
    rng     = -49:49;                                       % visual feature values
    e_br    = 0.5*ones(1,length((range)))./length(range);   % probabilities for brights
    e_dk    = e_br;                                         % probabilities for darks
    
elseif strcmp(feature,'disp')
    
    load('environ_stats.mat');
    
    % binocular disparities in the Van Hateren dataset
    
    numsamples = 1001;
    
    rng     = linspace(-60,60,numsamples);         % disparity values (arminutes)
    Xz      = linspace(-60,60,length(vh.Xz(2:end-1)));
    e_br    = vh.pON*vh.Zon(2:end-1);                   % proportion bright amplitude * bright distribution
    e_dk    = vh.pOFF*vh.Zoff(2:end-1);
    
    % sub sample for smooth modeling
    
    e_br = interp1(Xz,e_br,rng);
    e_dk = interp1(Xz,e_dk,rng);
    
end

e_all   = e_br + e_dk;                                         % overall probability
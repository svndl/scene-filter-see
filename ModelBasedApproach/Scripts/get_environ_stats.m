function env = get_environ_stats(paths,feature)
%
% get statistical distributions for brights, darks, and overall for the
% feature

numsamples = 1001; % number of upsamples

switch feature
    case'f'
        % theoretical visual features has a uniform distribution
        x = -49:49;
        % probabilities for brights and darks
        e_bright = 0.5*ones(1, length(x))./length(x);
        e_dark = e_bright;
    case 'disp'
        % binocular disparities in the Van Hateren dataset
        load([paths.env '/nss_basic.mat']);
        disp_limit = 60; %(arminutes)
        x = linspace(-disp_limit, disp_limit, numsamples);
        Xz = linspace(-disp_limit, disp_limit, length(vh.Xz(2:end - 1)));
        % proportion bright amplitude * bright distribution
        e_bright = vh.pON*vh.Zon(2:end - 1);
        e_dark = vh.pOFF*vh.Zoff(2:end - 1);
        
        % subsample for smooth modeling
        e_bright = interp1(Xz, e_bright, x);
        e_dark = interp1(Xz, e_dark, x);
    otherwise
        e_bright = 0;
        e_dark = 0;
        x = 0;
end
% overall probability
env.rng = x;
env.bright = e_bright;
env.dark = e_dark;
env.all = env.bright + env.dark;
env.feature = 'feature';
end
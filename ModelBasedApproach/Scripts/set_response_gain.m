function gain = set_response_gain(popGain, env, pref)
% returns response gain depending on selected population gain
    switch popGain
        
        case 'uniform'    
            g_bright = 0.5*ones(1, length(pref));
            g_dark = 0.5*ones(1, length(pref));
    
        case 'optimal'
            p_br  = interp1(env.rng, env.bright, pref);     
            p_dk  = interp1(env.rng, env.dark, pref);
            p_all = interp1(env.rng, env.all, pref);
    
            g_bright = p_br./p_all;
            g_dark = p_dk./p_all;
        otherwise
           g_bright = 0;
           g_dark = 0;
    end
    gain.bright = g_bright;
    gain.dark = g_dark;
end

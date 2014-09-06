function [g_br,g_dk] = set_response_gain(m,pref)

if strcmp(m.popGain,'uniform');
    
    g_br = 0.5;
    g_dk = 0.5;
    
elseif strcmp(m.popGain,'optimal');
    
    p_br  = interp1(m.rng,m.e_br,pref);      % probability of bright and dark
    p_dk  = interp1(m.rng,m.e_dk,pref);
    p_all = interp1(m.rng,m.e_all,pref);
    
    g_br = p_br/p_all;
    g_dk = p_dk/p_all;
    
end
   
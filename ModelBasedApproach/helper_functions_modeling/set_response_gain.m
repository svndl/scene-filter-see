function [g_br,g_dk] = set_response_gain(popGain,rng,e_br,e_dk,e_all,pref)

if strcmp(popGain,'uniform');
    
    g_br = 0.5;
    g_dk = 0.5;
    
elseif strcmp(popGain,'optimal');
    
    p_br  = interp1(rng,e_br,pref);      % probability of bright and dark
    p_dk  = interp1(rng,e_dk,pref);
    p_all = interp1(rng,e_all,pref);
    
    g_br = p_br/p_all;
    g_dk = p_dk/p_all;
    
end
   
function [g] = set_response_gain(popGain,env_inc,env_all,pref,disps,gPower)

% determine the response gain of a cell for ON or OFF 

if popGain == 1                                                             % uniform gain
    
    g = 0.5;                                                                % gain sums to 1, so 0.5 means ON/OFF gains are equal
    
elseif popGain == 2                                                         % optimal gain
    
    perc_inc       = env_inc./env_all;                                      % percent of all input that is ON
    prob_at_pref   = perc_inc(abs(disps - pref) == min(abs(disps - pref))); % find percent at stimulus preference
    prob           = mean(prob_at_pref);                                    % make sure it's just one value
    g = prob^gPower;
    
end
function env = model_setEnvProbs(disps, r_inc, dp)
% generate generic ON and OFF probability distributions
% Input parameters:
% LPNORM -- power of generalized distribution
% skew  -- skew of generalized dsitributions (+ON, -OFF)
% p_mu  -- mean for disparity probability dist
% p_sig -- sigma for disparity probability dist

    LPNORM = 2;                                                                      
    k = 0;                                                                       

    p_mu = 0;                                                                       
    p_sig = 25;
    
    % convert d prime to difference of means between incs and decs    
    delta = dp * sqrt( 0.5 * ( 2 * (p_sig^2) ) );                                    
    
    % increment/decrement probability distribution
    env_inc   = model_genNormTuningSkew( p_mu - (delta/2) , p_sig, LPNORM , k, disps );  
    env_dec   = model_genNormTuningSkew( p_mu + (delta/2) , p_sig, LPNORM , -k, disps ); 
    
    % make sum to 1
    env.incement = env_inc/sum( env_inc ); 
    env.decrement = env_dec/sum( env_dec );                       
    % make overall probability dist according to ON/OFF ratio
    env.all = ( r_inc * env.incement ) + ( ( 1 - r_inc ) * env.decrement );
end
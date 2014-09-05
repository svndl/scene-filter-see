function [env_inc,env_dec,env_all] = set_generic_environmental_probabilities(disps,r_inc,dp)

% generate generic ON and OFF probability distributions

LPNORM    = 2;                                                                       % power of generalized distribution
k         = 0;                                                                       % skew of generalized dsitributions (+ON, -OFF)

p_mu      = 0;                                                                       % mu for disparity probability dist
p_sig     = 25;                                                                      % sigma for disparity probability dist
delta     = dp * sqrt( 0.5 * ( 2 * (p_sig^2) ) );                                    % convert d prime to difference of means between incs and decs

env_inc   = gen_normal_tuning_skew( p_mu - (delta/2) , p_sig, LPNORM , k, disps );  % increment probability distribution
env_inc   = env_inc / sum( env_inc );                                               % make sum to 1
env_dec   = gen_normal_tuning_skew( p_mu + (delta/2) , p_sig, LPNORM , -k, disps ); % decrement probability distribution
env_dec   = env_dec / sum( env_dec );                                               % make sum to 1
env_all   = ( r_inc * env_inc ) + ( ( 1 - r_inc ) * env_dec );                      % make overall probability dist according to ON/OFF ratio
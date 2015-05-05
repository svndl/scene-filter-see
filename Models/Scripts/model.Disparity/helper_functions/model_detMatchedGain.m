function [w_off, w_on, esr] = model_detMatchedGain(p_on, p_on_opt, popGain)

    % desired complex cell spike rate
    rC = 1; 

    p_off = 1 - p_on;
    
    switch popGain

        case 2
            % weight function that is proportional to learned probability
            w_on = 2/((1 - p_on_opt)/p_on_opt + 1);
            w_off = 2 - w_on;
        case 1
            w_on = 1;
            w_off = 1;
        otherwise
            w_on = 0;
            w_off = 0;
    end

    r_on = 1;
    r_off = w_on./w_off;
    esr = p_off*(r_off + w_off.*r_off) + p_on*(r_on + w_on.*r_on);
    esr = esr/(rC*2);


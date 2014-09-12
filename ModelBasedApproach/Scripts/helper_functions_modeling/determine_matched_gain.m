function [wOFF, wON, esr] = determine_matched_gain(pON,pONopt,popGain)

rC = 1; % desired complex cell spike rate

pOFF = 1 - pON;

if popGain == 2
    % weight function that is proportional to learned probability
    wON = 2/(((1-pONopt)/pONopt) + 1);
    wOFF = 2 - wON;
elseif popGain == 1
    wON = 1;
    wOFF = 1;
end

rON = 1;

rOFF = wON./wOFF;

esr = pOFF*(rOFF + wOFF.*rOFF) + pON*(rON + wON.*rON);

esr = esr/(rC*2);


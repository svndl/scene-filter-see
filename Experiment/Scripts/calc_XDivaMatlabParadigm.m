function TotalFrames = calc_XDivaMatlabParadigm(freq)

    %freq = 0.5;
    monitorFrequency = 60;
    
    desiredCoreDuration = 1;
    
    nCoreBins = 1;
    nPreludeBins = 0;
    nCoreSteps = 1;
    
    
    nFrmPerTotalCycle = monitorFrequency/freq;
    %% calc desired numbers
%     desiredBinDuration = desiredCoreDuration/nCoreBins;
%     desiredStepDuration = desiredCoreDuration/nCoreSteps;
    
    %minofTwo = min(desiredBinDuration, desiredStepDuration);
    
    %sbs = shortest of bin/step
    nCoreSBS = max(nCoreBins, nCoreSteps);
    
	totalCycleS	= 1/freq;
	sbsDurationS = desiredCoreDuration/nCoreSBS;
	totalCyclesPerSBS = round(sbsDurationS/totalCycleS);
    
    if( totalCyclesPerSBS == 0)	
        totalCyclesPerSBS  = 1;
    end

	%newActualCoreDurS	= totalCyclesPerSBS*totalCycleS * nCoreSBS;
	newNmbFramesPerSBS	= totalCyclesPerSBS*nFrmPerTotalCycle;
    TotalFrames = nCoreSBS*totalCyclesPerSBS*newNmbFramesPerSBS;
end
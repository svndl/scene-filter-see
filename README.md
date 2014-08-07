scene-filter-see
================

This repository contains code for analyzing the relationship between scene image properties and perceptual judgments

IMAGE MANIPULATION: high-res versions of the original and manipulated images used in the experiments; Matlab code that generated the manipulations, which can be altered and run within the current directory



PERCEPTUAL EXPERIMENT: response data from 20 subjects from two perceptual experiments

Each .mat file contains a structure with the data from the main experiment or the control experiment.

There are 3 upper level fields:

-conditionTypes: the image manipulations being compared
	-'tp' is towards the prior
	-'ap' is against the prior
	-'orig' is unmanipulated
	-'stereo' is stereo 3D

-scenesListSorted: directory names for the 15 scenes used in the experiment, sorted from most negative to most positive luminance/depth correlation. These file names match the directories in ImageManipulation

-scenesListSortedRvals: Pearson r correlation values between luminance and depth for these scenes

-trials: contains 7 field with a row for each trial in the experiment
	-subj   		%subject number
    	-scene_number  		%index of original scene - can be used with scenesListSorted to determine scene name
    	-condA     		%one condition from trial - indexes into conditionTypes to determine the manipulation
    	-condB          	%other condition from trial - indexes into conditionTypes to determine the manipulation
    
    	-AcorrMinusBcorr   	%did condition A's image have a more negative correlation than B?
    	-AvarMinusBvar     	%did condition A's image have greater image variance than condition B?

    	Responses:
    
    	for main experiment:
        	-resp_Amore3DthanB      	%was condition A judged more 3D than B?
    	for control experiment:
        	-resp_AmoreContrastthanB 	%was condition A judged more Contrasty than B?

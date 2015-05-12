function main_runAnalysis
% This script is the best way to make yourself familiar with the project.
% Once you run it, it'll ask you to enter the type of analysis you'd like to run.
% 
%
% Current analysis options are:
%
%   1 -> Will load perceptual ratings and plot them as a function of
%   luminance-depth correlation (Experiment 1).
%   2 -> Will produce coarse-to-fine depth correlation for rated images (Experiment 1).
%   3 -> Will run disparity model and compare its output with the
%   perceptual ratings (Experiment 1).
%   4 -> Will run image enhancement manipulation only, no analysis
    close all;


    path = main_setPath;    % add all subfolders to your path

    %% I. Ask for user input
    str_opt1 = 'Press 1 to load perceptual ratings and plot them as a function of luminance-depth correlation (Experiment 1) \n';
    str_opt2 = 'Press 2 to run coarse-to-fine depth correlation analysis for rated images (Experiment 1) \n';
    str_opt3 = 'Press 3 to run disparity model and compare its output with the perceptual ratings (Experiment 1) \n';
    str_opt4 = 'Press 4 to run disparity model and compare its output with the perceptual ratings (Experiment 2) \n';
    str_opt5 = 'Press 5 to run image enhancement procedure \n';    
    
    str_opt6 = 'Press 0 to quit\n';

    fprintf([str_opt1, str_opt2, str_opt3, str_opt4, str_opt5, str_opt6]);

    str_prompt = 'Your choise is: ';
    usr_input = input(str_prompt);
    
%     str_note1('Will attempt to load rated scenes from Experiment/Data. \n')
%     [img, percept] = main_getRatedScenes;

    % run specified approach style to generate and test predictors
    switch usr_input
        case 0
            fprintf('Quitting ...\n');
        case 1
            fprintf('Running ratings luminance/depth correlation analysis \n');
            main_LumDepthCorr_Percept(path);
        case 2
        
            fprintf('Running coarse-to-fine luminance/depth correlation analysis \n');
            
        case 3
            [img, percept] = main_getRatedScenes('ssvep');
                        
            do_plot(pred, percept, path,'Model-Based Brain Picture Responses',[-0.0001 0.0001], 0);   
            % generate figure illustrating brain model
            do_plot_model(path, model, brain);
        case 4
            [img, percept] = main_getRatedScenes('vep');
        case 5
            fprintf('Performing luminance manipulation and no other analyses \n');
            manipulateLuminanceAllImages;
        otherwise
            fprintf('unknown approach, please try again \n');
            main_runAnalysis;
    end

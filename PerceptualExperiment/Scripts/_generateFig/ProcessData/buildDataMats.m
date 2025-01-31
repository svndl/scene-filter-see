function [] = buildDataMats()

% This function takes individual subject files from the perceptual
% experiments and builds a single data structure for all trials

% Emily Cooper, Stanford University 2014

    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    raw_data1_path = fullfile(curr_path, 'RawData');
    raw_data2_path = fullfile(curr_path, 'RawDataContrast');
    mpath = strtok(userpath, pathsep);
    %src_path = fullfile(mpath, 'scene-filter-see', 'ImageManipulation', 'Images', 'Originals');
    res_path = fullfile(mpath, 'scene-filter-see', 'PerceptualExperiment', 'Data');
    
    
for exp = 1:2
    
    %main experiment
    if exp == 1
        subj_folder = raw_data1_path; 
        
        %these are the conditions we're loading
        data.conditionTypes = {'ap' , 'orig', 'tp', 'stereo'};
        conditionNums  = [-1         0       1       3];
        
    elseif exp == 2
        subj_folder = raw_data2_path;

        %these are the conditions we're loading
        data.conditionTypes = {'ap' , 'orig', 'tp'};
        conditionNums  = [-1        0       1 ];
    end
    
    %load scene correlation info
    load('luminanceDepthCorrelations.mat')
    load('luminanceDepthVariances.mat')
    
    %data matrix, each row is an individual trial:
    
    data.trials.subj                    = [];   %subject number
    data.trials.scene_number            = [];   %number index of original scene sorted from neg to pos luminance/depth correlation
    data.trials.condA                   = [];   %one condition from trial
    data.trials.condB                   = [];   %other condition from trial
    
    if exp == 1
        data.trials.resp_Amore3DthanB       = [];   %was condition A judged more 3D than B?
    elseif exp == 2
        data.trials.resp_AmoreContrastthanB = [];   %was condition A judged more Contrasty than B?
    end
    
    data.trials.AcorrMinusBcorr         = [];   %did condition A's image have a more negative correlation than B?
    data.trials.AvarMinusBvar           = [];   %did condition A's image have greater image variance than condition B?
    

      
    %load data
    %for each subject
    subj_list = dir(fullfile(subj_folder, '*.mat'));
    
    for s = 1:numel(subj_list)
        
        display(['subject ' subj_list(s).name]);
        
        %get responses
        load(fullfile(subj_folder, subj_list(s).name));
        
        if s == 1
            
            %sort scenes based on correlation
            all_scenes = corrDat.scene;
            all_rvals = corrDat.corrOrig;
            [rvals_sort,sort_ind] = sort(all_rvals);
            
            scenes_sort = all_scenes(sort_ind);
            data.scenesListSorted = scenes_sort;
            data.scenesListSortedRvals = rvals_sort;
            
            corrDat.corrOrig = corrDat.corrOrig(sort_ind);
            corrDat.corrTP = corrDat.corrTP(sort_ind);
            corrDat.corrAP = corrDat.corrAP(sort_ind);
            
        end
        
        %for each scene
        for c = 1:length(dat.conds)
            
            scene = dat.conds(c).scene;
            
            %find index of this scene in sorted correlation list
            scene_ind = find(ismember(scenes_sort, ['..' filesep 'Images' filesep 'Originals' filesep scene ]));
            
            if ~isempty(scene_ind)
                
                %for each trial
                for t = 1:length(dat.conds(c).trials.trial)
                    
                    %grab condition numbers and response value
                    ims(1) = dat.conds(c).trials.pairs(t,1);
                    ims(2) = dat.conds(c).trials.pairs(t,2);
                    resp = dat.conds(c).trials.resp(t);
                    
                    
                    %only take conditions of interest - other conditions are
                    %from a different experiment
                    if (ims(1) == -1 || ims(1) == 0 || ims(1) == 1 || ims(1) == 3) && ...
                            (ims(2) == -1 || ims(2) == 0 || ims(2) == 1 || ims(2) == 3)
                        
                        
                        %subject and scene info
                        data.trials.subj = [data.trials.subj ; s];
                        data.trials.scene_number = [data.trials.scene_number ; scene_ind];
                        
                        %conditions
                        A = find(conditionNums == max(ims));
                        B = find(conditionNums == min(ims));
                        
                        data.trials.condA = [data.trials.condA ; A];
                        data.trials.condB = [data.trials.condB ; B];

                        %response
                        if exp == 1
                            data.trials.resp_Amore3DthanB = [data.trials.resp_Amore3DthanB ; ims(resp) == max(ims)];
                        elseif exp == 2
                            data.trials.resp_AmoreContrastthanB = [data.trials.resp_AmoreContrastthanB ; ims(resp) == max(ims)];
                        end
                        
                        
                        %scene/image info
                        if strcmp(data.conditionTypes{A},'tp')
                            Acorr = corrDat.corrTP(scene_ind);
                            Avar = varDat.varTP(scene_ind);
                        elseif strcmp(data.conditionTypes{A},'ap')
                            Acorr = corrDat.corrAP(scene_ind);
                            Avar = varDat.varAP(scene_ind);
                        elseif strcmp(data.conditionTypes{A},'orig') || strcmp(data.conditionTypes{A},'stereo')
                            Acorr = corrDat.corrOrig(scene_ind);
                            Avar = varDat.varOrig(scene_ind);
                        end
                        
                        if strcmp(data.conditionTypes{B},'tp')
                            Bcorr = corrDat.corrTP(scene_ind);
                            Bvar = varDat.varTP(scene_ind);
                        elseif strcmp(data.conditionTypes{B},'ap')
                            Bcorr = corrDat.corrAP(scene_ind);
                            Bvar = varDat.varAP(scene_ind);
                        elseif strcmp(data.conditionTypes{B},'orig') || strcmp(data.conditionTypes{B},'stereo')
                            Bcorr = corrDat.corrOrig(scene_ind);
                            Bvar = varDat.varOrig(scene_ind);
                        end
                        
                        %image differences
                        data.trials.AcorrMinusBcorr = [data.trials.AcorrMinusBcorr ; Acorr - Bcorr];
                        data.trials.AvarMinusBvar = [data.trials.AvarMinusBvar ; Avar - Bvar];
                        
                        
                    end
                    
                end
            end
        end
    end
    
    if exp == 1
        save(fullfile(res_path, 'mainExperimentData.mat'),'data')
    elseif exp == 2
        save(fullfile(res_path,' controlExperimentData.mat'),'data')
    end
    
    clear data;
    
    
end
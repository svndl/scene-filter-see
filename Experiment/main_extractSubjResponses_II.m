function main_extractSubjResponses_II 
    
    path_experiment = main_setPath_Experiment;
    subj = dir(path_experiment.metadata_exp2);
    resp_file = 'RTSeg_s00';
    sceneList = 'stimset_blk_list.mat';
    cndList = 'conditions.mat';
    load(sceneList);
    load(cndList);
    %conditions = {'EO', 'ES', 'OE', 'OS', 'SE', 'SO'};
    
    cndLength = 60;
    numCnd = numel(Conditions);
    numScenes = numel(stimset_blk_list);
    %each scene was presented 4 times 
    subjCount = 0;
    EO = zeros(numScenes, 1);
    SE = zeros(numScenes, 1);
    SO = zeros(numScenes, 1);
    
    EO_sceneCount = zeros(numScenes, 1);
    SE_sceneCount = zeros(numScenes, 1);
    SO_sceneCount = zeros(numScenes, 1);
    for i = 1:numel(subj)
        if (subj(i).name(1) ~= '.' && subj(i).isdir)
            % go into directory, extract trials for each subject
            disp(['processing ' subj(i).name]);
            path = fullfile(path_experiment.metadata_exp2, subj(i).name, resp_file);
            summary = load_analyze(path, cndLength, numCnd, numScenes);
            if (length(summary.cndId)<5)
                continue;
            end
            % subject's responses
            responses = extract_responses(summary);
            EO = EO + responses.EO;
            SE = SE + responses.SE;
            SO = SO + responses.SO; 
            EO_sceneCount = EO_sceneCount + responses.EO_scenecount;
            SE_sceneCount = SE_sceneCount + responses.SE_scenecount;
            SO_sceneCount = SO_sceneCount + responses.SO_scenecount;
%             disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
%             print_ConditionResult(stimset_blk_list, EO, {'Enh', 'Orig'}, subjCount);
%             disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
%             
%             print_ConditionResult(stimset_blk_list, SO, {'Stereo', 'Orig'}, subjCount);
%             disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
%             
%             print_ConditionResult(stimset_blk_list, SE, {'Stereo', 'Enh'}, subjCount);
%             disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            subjCount = subjCount + 1;
        end
    end
    disp(['Processed ' num2str(subjCount) ' valid subjects']);
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');    
    %print_ConditionResult(stimset_blk_list, EO, {'Enh', 'Orig'}, subjCount);
    print_ConditionResult(stimset_blk_list, EO, {'Enh', 'Orig'}, EO_sceneCount);
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');    
    %print_ConditionResult(stimset_blk_list, EO, {'Enh', 'Orig'}, subjCount);
    print_ConditionResult(stimset_blk_list, SO, {'Stereo', 'Orig'}, SO_sceneCount);
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');    
    %print_ConditionResult(stimset_blk_list, EO, {'Enh', 'Orig'}, subjCount);
    print_ConditionResult(stimset_blk_list, SE, {'Stereo', 'Enh'}, SE_sceneCount);
    save_ConditionResult(path_experiment, stimset_blk_list, EO, 'Enh-Orig', EO_sceneCount);    
end


function summary = load_analyze(path, cndLength, numCnd, numScenes)
    all_cndId = zeros(cndLength*numCnd, 1);
    all_trialId = zeros(cndLength*numCnd, 1);
    all_resp = cell(cndLength*numCnd, 1);
    
    idx = 1;
    for i = 1:numCnd
        % loading files RT_Seg*02-07.mat - this is where the answers are stored 
        session_part = strcat(path, num2str(i + 1), '.mat');
        load(session_part);
        cndId  = [TimeLine.cndNmb]';
        trialId = [TimeLine.trlNmb]';
        resp = {TimeLine.respString}';
        
        all_cndId(idx:idx + length(cndId) - 1) = cndId;
        all_trialId(idx:idx + length(trialId) - 1) = trialId;
        all_resp(idx:idx + numel(resp) - 1) = resp;
        idx = idx + length(cndId);
        %interested in timeline field only
%         all_cndId(cndLength*(i - 1) + 1:cndLength*i) = [TimeLine(1:1:cndLength).cndNmb]';
%         all_trialId(cndLength*(i - 1) + 1:cndLength*i) = [TimeLine(1:1:cndLength).trlNmb]';
%        all_resp(cndLength*(i - 1) + 1:cndLength*i) = {TimeLine(1:1:cndLength).respString}';
    end
    %truncate zero tails
    all_cndId = all_cndId(all_cndId > 0);
    all_trialId = all_trialId(all_trialId > 0);
    all_resp = all_resp(~cellfun('isempty', all_resp));
    
    
    missed_idx = strcmp(all_resp, 'Mis');
    valid_resp = all_resp(~missed_idx);
    AoverB = strcmp(valid_resp, 'La');
    trialId = all_trialId(~missed_idx);
    cndId = all_cndId(~missed_idx);
    overN = (trialId > numScenes);
    sceneId = overN.*(trialId - numScenes) + (1 - overN).*trialId;
    summary.cndId = cndId;
    summary.sceneId = sceneId;
    summary.AoverB = AoverB;
end
function responses = extract_responses(summary)

    res_matrix = [summary.cndId, summary.sceneId, summary.AoverB];
    sorted_cnd = sortrows(res_matrix);
    %conditions, as they were presented
    eo = 1;
    es = 2;
    oe = 3;
    os = 4;
    se = 5;
    so = 6;
    
    %merge the results of conditions (1, 4); (2, 5) and (3, 6);
    cnd_EO = sorted_cnd(sorted_cnd(:, 1, 1) == eo, :, :);    
    cnd_OE = sorted_cnd(sorted_cnd(:, 1, 1) == oe, :, :);
    
    scenes_EO_OE = [cnd_EO(:, 2, :); cnd_OE(:, 2, :)];
    
    responses.EO_scenecount = histc(scenes_EO_OE, unique(scenes_EO_OE));
    responses.EO = sum_responses(cnd_EO(:, 2:3), cnd_OE(:, 2:3));
    
    cnd_ES = sorted_cnd(sorted_cnd(:, 1, 1) == es, :, :);   
    cnd_SE = sorted_cnd(sorted_cnd(:, 1, 1) == se, :, :);   
    scenes_ES_SE = [cnd_ES(:, 2, :); cnd_SE(:, 2, :)];
    
    responses.SE_scenecount = histc(scenes_ES_SE, unique(scenes_ES_SE));    
    responses.SE = sum_responses(cnd_SE(:, 2:3), cnd_ES(:, 2:3));
    
    cnd_OS = sorted_cnd(sorted_cnd(:, 1, 1) == os, :, :);   
    cnd_SO = sorted_cnd(sorted_cnd(:, 1, 1) == so, :, :);   
    scenes_OS_SO = [cnd_OS(:, 2, :); cnd_SO(:, 2, :)];
    
    responses.SO_scenecount = histc(scenes_OS_SO, unique(scenes_OS_SO));
    responses.SO = sum_responses(cnd_SO(:, 2:3), cnd_OS(:, 2:3));
    
end

function s = sum_responses(answers_cndAB, answers_cndBA)
    s = zeros(30, 1);
    for i = 1:length(answers_cndAB)
        s(answers_cndAB(i, 1)) = s(answers_cndAB(i, 1)) + answers_cndAB(i, 2);
    end
    for i = 1:length(answers_cndBA)
        s(answers_cndBA(i, 1)) = s(answers_cndBA(i, 1)) + (1 - answers_cndBA(i, 2));
    end    
end

function print_ConditionResult(sceneList, respMatrix, charCndName, sceneCount)

    for i = 1:numel(sceneList)
       s = [sceneList{i} ' reported to have more depth in ' charCndName{1} ' vs ' charCndName{2} ' ' num2str(respMatrix(i)) ' out of ' num2str(sceneCount(i)) ' or ' num2str(100*respMatrix(i)/sceneCount(i)) '%'];
       disp(s);
    end
end

function save_ConditionResult(path, sceneList, respMatrix, charCndName, sceneCount)
    save(fullfile(path.results, [charCndName '.mat']), 'sceneList', 'respMatrix', 'sceneCount');
end
    
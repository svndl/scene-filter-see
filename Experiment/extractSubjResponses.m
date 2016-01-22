function [ratings, count] = extractSubjResponses(databasePath, numCnd, numScenes)
    
    subjDir = dir2(databasePath);
    resp_file = 'RTSeg_s00';
    
    nSubj = numel(subjDir);
    
    ratingsDir = zeros(nSubj, numCnd, numScenes);
    countDir = zeros(nSubj, numCnd, numScenes);    
    
    subjCount = 1;
    for subjDirIdx = 1:nSubj
        try
            if (subjDir(subjDirIdx).name(1) ~= '.' && subjDir(subjDirIdx).isdir)
                % go into directory, extract trials for each subject
                disp(['processing ' subjDir(subjDirIdx).name]);
                path = fullfile(databasePath, subjDir(subjDirIdx).name, resp_file);
                summary = load_analyze(path, numScenes);
                if (length(summary.cndId)<5)
                    continue;
                end
                % subject's responses
                [scenesCount, responses] = extract_responses(summary, numCnd, numScenes);
                ratingsDir(subjCount, :, :) = responses;
                countDir(subjCount, :, :) = scenesCount;
                subjCount = subjCount + 1;
            end      
        catch
            disp(['Error loading ' subjDir(subjDirIdx).name]);
        end
    end
    ratings = ratingsDir(1:subjCount, :, :);
    count = countDir(1:subjCount, :, :);
end


function summary = load_analyze(path, numScenes)

    RTSeg_List = dir([path '*.mat']);
    nRTSeg = numel(RTSeg_List) - 1;
    
    cndId = cell(nRTSeg, 1);
    trialId = cell(nRTSeg, 1);
    resp = cell(nRTSeg, 1);
    for i = 1:nRTSeg
        % loading files RT_Seg*02-07.mat - this is where the answers are stored 
        session_part = strcat(path, num2str(i + 1), '.mat');
        load(session_part);
        cndId{i}  = [TimeLine.cndNmb]';
        trialId{i} = [TimeLine.trlNmb]';
        resp{i} = {TimeLine.respString}';
    end
    
    all_cndId = cat(1, cndId{:});
    all_trialId = cat(1, trialId{:});
    all_resp = cat(1, resp{:});
    
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
function [scenesCount, responses] = extract_responses(summary, nConditions, nScenes)

    res_matrix = [summary.cndId, summary.sceneId, summary.AoverB];
    sorted_cnd = sortrows(res_matrix);
    scenesCount = zeros(nConditions, nScenes);
    responses = zeros(nConditions, nScenes);
    
    try
        for cn = 1:nConditions
            dataChunk = sorted_cnd(sorted_cnd(:, 1) == cn, :, :);
            cndChunk = dataChunk(:, 2:3);
            scenesCount(cn, :) = histc(cndChunk(:, 1), 1:nScenes);
        
            for sn = 1:nScenes
                s = sum(cndChunk(cndChunk(:, 1) == sn, :), 1);
                responses(cn, sn) = s(2);
            end    
        end
    catch
        disp(['Error at cnd#' num2str(cn) ' scene #' num2str(sn)]);
    end
end


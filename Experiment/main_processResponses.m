function main_processResponses

    database = 'Live3D';
    
    switch database
        case 'Middlebury'
            datatype = 'SEO';
        case 'Live3D'
            datatype = 'SDEO';    
        otherwise
    end
    
    path_experiment = main_setPath_Experiment;
    databasePath = fullfile(path_experiment.metadata_exp2, database);
    resultsPath = fullfile(path_experiment.results, database);
    if (~exist(resultsPath, 'dir'))
        mkdir(resultsPath);
    end
    eC = loadConditions(databasePath);
    eS = loadScenes(databasePath);
  
    nCnd = numel(eC.Conditions);
    nScenes = numel(eS.Scenes);
    
    [ratings, count] = extractSubjResponses(databasePath, nCnd, nScenes);    
    unique_cnd = cellstr(nchoosek(datatype, 2));
    
    for uc = 1:numel(unique_cnd)
        cn = char(unique_cnd(uc));
        
        AB_ratings = ratings(:, ismember(eC.Conditions, cn), :); 
        BA_ratings = ratings(:, ismember(eC.Conditions, fliplr(char(cn))), :);
        
        AB_count = count(:, ismember(eC.Conditions, cn), :); 
        BA_count = count(:, ismember(eC.Conditions, fliplr(cn)), :);
        
        ABBA_ratings = AB_ratings + BA_count - BA_ratings;
        ABBA_count = AB_count + BA_count;
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');    
        print_ConditionResult(eS.Scenes, squeeze(sum(ABBA_ratings, 1)), {cn(1), cn(2)}, squeeze(sum(ABBA_count, 1)));        
        barPlot(squeeze(ABBA_ratings), squeeze(ABBA_count),  eS.Scenes, [cn, ' ratings'], resultsPath);
        save_ConditionResult(fullfile(resultsPath, cn), eS.Scenes, squeeze(sum(ABBA_ratings, 1)), squeeze(sum(ABBA_count, 1)));        
    end
end

function Conditions = loadConditions(databasePath)
    cndList = 'conditions.mat';
    Conditions = load(fullfile(databasePath, cndList), 'Conditions');
end
function Scenes = loadScenes(databasePath)
    sceneList = 'scene_list.mat';
    Scenes = load(fullfile(databasePath, sceneList), 'Scenes');
end

function print_ConditionResult(sceneList, respMatrix, charCndName, sceneCount)

    for i = 1:numel(sceneList)
       s = [sceneList{i} ' reported to have more depth in ' charCndName{1} ' vs ' charCndName{2} ' ' num2str(respMatrix(i)) ' out of ' num2str(sceneCount(i)) ' or ' num2str(100*respMatrix(i)/sceneCount(i)) '%'];
       disp(s);
    end
end

function save_ConditionResult(pathRes, sceneList, respMatrix, sceneCount)
    save([pathRes '.mat'], 'sceneList', 'respMatrix', 'sceneCount');
end

function barPlot(dataMat, sceneCount, stimset_blk_list, ttl, pathRes)
    

    fractionMat = dataMat./sceneCount;
    
    
    nScenes = size(fractionMat, 2);
    nSubj = size(fractionMat, 1);
    sem = nanstd(fractionMat)./sqrt(nSubj);
    ts = tinv([0.025 0.975], nSubj - 1);
    
    %repMean = repmat(mean(fractionMat), [size(ts, 2) 1]);
    CI =  ts'*sem;
    
    scrsz = get(0,'ScreenSize');
    h = figure('Position', [1 scrsz(4)/2 scrsz(3)/2 scrsz(4)]);
    title(ttl, 'FontSize', 18);
    xLabel = 'Scenes';
    yLabel = 'User ratings, %'; 
    xlabel(xLabel, 'FontSize', 18);
    ylabel(yLabel, 'FontSize', 18);

    barwitherr(100*cat(3, cat(1, CI(1, :), zeros(1, nScenes)), ...
        cat(1, CI(1,:), zeros(1, nScenes))), ...
        100.*cat(1, nanmean(fractionMat), zeros(1, nScenes)), 'EdgeColor',[0 0 0]); hold on;
    l = legend(stimset_blk_list{:});
    set(l, 'Interpreter', 'none');
    filename = fullfile(pathRes, char(ttl));
    saveas(h, filename, 'pdf');
    close gcf;
end


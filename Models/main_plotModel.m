function f = main_plotModel(figTitle, responses, ratings, scene_list)

    f = figure;
    
    
    xLabel = 'Model response';
    yLabel = 'User ratings'; 
    
    subplot(1, 2, 1); hold on;
    title(figTitle, 'FontSize', 18);
    
    false_pos_idx = logical((ratings < 50).*(responses > 0));
    false_neg_idx = logical((ratings > 50).*(responses < 0));    
    good_idx = logical(1 - (false_pos_idx + false_neg_idx));
    
    limX = [min(responses), max(responses)];
    limY = [min(ratings), max(ratings)];

    
    plot(responses(false_pos_idx), ratings(false_pos_idx), 'ko','MarkerFaceColor', 'r', 'MarkerSize', 7); hold on;
    plot(responses(false_neg_idx), ratings(false_neg_idx), 'ko','MarkerFaceColor', 'b', 'MarkerSize', 7); hold on;
    plot(responses(good_idx), ratings(good_idx), 'ko','MarkerFaceColor', 'g', 'MarkerSize', 7); hold on;
    
    legend({'False Pos', 'False Neg', 'Correct'});
    
    xlabel(xLabel, 'FontSize', 18);
    ylabel(yLabel, 'FontSize', 18);

    plot([0, 0], limY, '.-.k'); hold on;
    plot(limX, [50, 50], '.-.k'); hold on;
    
    [p, ~] = polyfit(responses, ratings, 1);
    plot(responses, polyval(p, responses), '-.k', 'LineWidth', 2); hold on;
    
    [rho, phi] = corr(responses, ratings);
    
    % Text at bottom left
    text(2*range(limX(1))/3 + min(limX(1)), limY(1) + 5, ['\rho = ' num2str(rho, 2)], 'FontSize', 16);
    text(2*range(limX(1))/3 + min(limX(1)), limY(1) + 10, ['\phi = ' num2str(phi, 2)], 'FontSize', 16); 
   
    subplot(1, 2 ,2);
    axis off;
    
    nScenes = numel(scene_list);
    for i = 1:nScenes
        
        strVal = [scene_list{i} ' Model = ' num2str(responses(i)) ' r = ' num2str(ratings(i), 2) '%'];
        text(0, i/nScenes, strVal, 'FontSize', 10, 'Interpreter', 'none');
    end
end
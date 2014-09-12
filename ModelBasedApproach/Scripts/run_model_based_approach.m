% correlate the preceptual ratings with overall depth in brain model
% response

% example for testing this analysis out on noise images

% simulate 5 image pairs
for m = 1:5
    
    % perceptual rating for this image comparison
    more3D(m) = rand;
    
    brain1 = predict_model_response([],1,1,0);
    brain2 = predict_model_response([],1,1,0);
    
    moreBrainResponse(m) = brain1.volume - brain2.volume;
    
end

figure; hold on;

plot(moreBrainResponse,more3D,'ko','markerfacecolor','k');
xlabel('brain response magnitude'); ylabel('percent more 3D');

lsline

export_fig example.pdf
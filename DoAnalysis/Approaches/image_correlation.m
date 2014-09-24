function pred = image_correlation(image)
%
% analyze the predictiveness of whole image luminance/depth correlation for
% perceptual responses

for x = 1:length(image)
    
    validZs = ~isnan(image(x).depth);       % indices with valid depth estimates
    
    % calculate current image correlations
    corr_orig(x) = corr(image(x).depth(validZs), image(x).orig.V(validZs));
    corr_enh(x) = corr(image(x).depth(validZs), image(x).enh.V(validZs));
    corr_deg(x) = corr(image(x).depth(validZs), image(x).deg.V(validZs));
    
end

% convert image correlations to differences
pred.enh_deg    = -(corr_enh - corr_deg);
pred.enh_orig   = -(corr_enh - corr_orig);
pred.orig_deg   = -(corr_orig - corr_deg);

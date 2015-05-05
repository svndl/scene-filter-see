function [percept, luminance] = calc_perceptScene(varargin)

    if (nargin == 3)
        [percept, luminance] = getOldPercept(varargin{1}, varargin{2}, varargin{3});
    end
    
end

function [percept, luminance] = getOldPercept(dat, trl, sn)
% compute percent more 3D from perceptual trial data
%
% there are 3 comparisons:
% (1) enh_orig (enhanced v original)
% (2) orig_deg (original v degraded)
% (3) enh_deg  (enhanced v degraded)

    percept.scene_name = dat.scenesListSorted{sn};

    % get indices for each type of trial
    enh_degInds = dat.trials.scene_number == sn & ...
        trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
        trl.condB == find(ismember(dat.conditionTypes, 'ap'));

    enh_origInds = dat.trials.scene_number == sn & ...
        trl.condA == find(ismember(dat.conditionTypes, 'tp')) & ...
        trl.condB == find(ismember(dat.conditionTypes, 'orig'));

    orig_degInds = dat.trials.scene_number == sn & ...
        trl.condA == find(ismember(dat.conditionTypes, 'orig')) & ...
        trl.condB == find(ismember(dat.conditionTypes, 'ap'));

    %percent more 3D
    percept.enh_deg   = 100*sum(trl.resp_Amore3DthanB(enh_degInds))/length(trl.resp_Amore3DthanB(enh_degInds));
    percept.enh_orig  = 100*sum(trl.resp_Amore3DthanB(enh_origInds))/length(trl.resp_Amore3DthanB(enh_origInds));
    percept.orig_deg  = 100*sum(trl.resp_Amore3DthanB(orig_degInds))/length(trl.resp_Amore3DthanB(orig_degInds));
    
    luminance.scene_name = dat.scenesListSorted{sn};

    luminance.enh_deg = unique(trl.AcorrMinusBcorr(enh_degInds));
    luminance.enh_orig = unique(trl.AcorrMinusBcorr(enh_origInds));                
    luminance.orig_deg = unique(trl.AcorrMinusBcorr(orig_degInds));
end

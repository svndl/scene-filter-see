function pyr = mkScaleDecomposition(images, pyramid, varargin)
    nImages = numel(images.orig);
    nPyrs = numel(pyramid.type);
    orig = cell(nImages, nPyrs);
    enh = cell(nImages, nPyrs);
    deg = cell(nImages, nPyrs);
    
    for n = 1:nImages
        V_orig = rgb2gray(images.orig{n}.RGB);
        V_enh = rgb2gray(images.enh{n}.RGB);
        V_deg = rgb2gray(images.deg{n}.RGB);
        pyr_orig = pyrAnalysis(V_orig, images.depthmap{n}, pyramid.height, pyramid.type);
        pyr_enh = pyrAnalysis(V_enh, images.depthmap{n}, pyramid.height, pyramid.type);
        pyr_deg = pyrAnalysis(V_deg, images.depthmap{n}, pyramid.height, pyramid.type);
        corr
        if (nargin > 0)
            savefig_path = varargin{1};
            s.name = images.names{n};
            s.orig = orig{n};
            s.enh = enh{n};
            s.deg = deg{n};
            
            plot_sceneScalesDecomp(s, savefig_path)
        end
    end
    pyr.orig = orig;
    pyr.enh = enh;
    pyr.deg = deg;
end
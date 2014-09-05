%% tests laplacian pyramid
%% uses matlabPyrTools toolbox by Eero Simoncelli 

function test_wPyr

    %% check if toolbox is loaded
    if ( ~exist('pgmRead')) %#ok<EXIST>
        error('toolbox is not linked, please add to path before continue');
    end
    
    %disp('toolbox is found');
    
    %path_img = '~/Documents/MATLAB/scene-filter-see/ImageManipulation/Images/Originals';
    
    path_img = '../Images/Originals';


    listing = dir(path_img);
    try
        k = 1;
        while(strcmp(listing(k).name(1),'.'))
            k = k + 1;
        end
              
        nImages = length(listing) - k + 1;
        
        ld_corr = zeros(nImages, 3, 3);
        ld_bands = zeros(9, nImages);
        mean_lum = zeros(9, nImages);
        for l = k:length(listing)
            
            idx = l - k + 1;
            image_path = strcat(path_img, '/', listing(l).name);
            image = loadImages(image_path);
            im = rgb2gray(image.imRGB);
            cleaned = cleanDepth(image);
            depth = cleaned.imZ;
            imSubSample = 0;
            [pyrIm, pindIm] = buildWpyr(im, 5 - imSubSample);
            [pyrD, pindD] = buildWpyr(depth, 5 - imSubSample);
            
%             showSpyr(pyrIm, pindIm);
%             showSpyr(pyrD, pindD);
            
            nlevs = floor(wpyrHt(pindIm));
            nbands = 3;
            for lnum = 1:nlevs
                for bnum = 1:nbands
                    %% calculating lum-depth correlations at different bands/levels
                    lum = wpyrBand(pyrIm, pindIm, lnum, bnum);
                    depth = wpyrBand(pyrD, pindD, lnum, bnum);
                    ldcorr = corr2(lum, depth);
                    ld_corr(idx, lnum, bnum) = ldcorr;
                    band_idx = (lnum - 1)*nlevs + bnum;
                    ld_bands(band_idx, idx) = ldcorr;
                    mean_lum(band_idx, idx) = mean(mean(lum));
                end
            end
        end
    catch err
        disp(strcat('Test_wPyr:Error loading ', path));
        disp(err.message);
        disp(err.cause);
        disp(err.stack(1));
        disp(err.stack(2));
    end
    %% look at lum-depth corr at each band/level   
    disp('done');
    figure(1);
    
    subplot(2, 1, 1);
    stem(ld_bands);
    title('Depth-luminance correlations at different bands');
    ylabel('Luminance-depth correlation');
    xlabel('Band number');
        
    subplot(2, 1, 2);

    stem(ld_bands);
    title('Mean luminance value at different bands');
    ylabel('Mean luminance');
    xlabel('Band number');
    stem(mean_lum);
end
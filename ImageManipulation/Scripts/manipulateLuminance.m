function [] = manipulateLuminance(dir_name,flag)

% This function takes an image directory and algorithm flag as input, and
% applies the depth enhancement algorithm to the image contained in that
% directory. The directory must contain both the image and depth maps in a
% format handled by loadImages. The directory also must contain a stereo
% partner for the image, which will be loaded and saved to ensure that both
% images in the stereopair are in matching formats, unless this step has
% already been completed with a previous function call. Note that the second 
% image for the LiveColor+3D database is identical to the main image. A 
% second image with disparity will be created manually in Photoshop.
% Currently the function can handle images from the 
% Middlebury Stereo 
% (http://vision.middlebury.edu/stereo/data/) and 
% LiveColor+3D
% (http://live.ece.utexas.edu/research/3dnss/live_color_plus_3d.html)
% databases.
%
% example call:
%       manipulateLuminance('mb_aloe','tp')
%
%
% Emily Cooper, Stanford University 2014
%
% FLAGS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tp = negative luminance/depth correlation
% ap = positive luminance/depth correlation


% SET UP OUTPUT DIRECTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(flag,'tp')
    new_dir = ['../Images/TowardsThePrior/' dir_name '/'];
elseif strcmp(flag,'ap')
    new_dir = ['../Images/AgainstThePrior/' dir_name '/'];
else
    error('unknown manipulation flag');
end

if ~exist(new_dir, 'dir')
    mkdir(new_dir);
end


% SETUP STEPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%add path to helpful functions
addpath('../../../HelperFunctions/');

%show images and summaries in matlab figures
showResults = 0;
%store luminance/depth correlation of original and manipulation in a mat file
storeCorrelation = 0;

% load images
[imRGB,imLeftRGB,imZ,dispmap,median_pixel_disparity] = loadImages(dir_name);
% imRGB is the image to be enhanced, imLeftRGB is the other image in the
% stereo pair, which is really just carried through the function and not
% enhanced (because it has no associated depth map). imZ and dispmap are
% the depth map and disparity maps. median_pixel_disparity is
% the average disparity from the dispmap, which is used to decide how to
% crop the image

% crop images and depth maps to be square
[imRGB,imLeftRGB,imZOrig,dispmap] = cropImages(imRGB,imLeftRGB,imZ,dispmap,median_pixel_disparity);

%convert images to float 0-1 - these are all 8 bit
imRGB   = double(imRGB)./(255);
imLeftRGB  = double(imLeftRGB)./(255);

%linearize to undo PNG gamma encoding of 1/2.2 on image to be manipulated
%(will be restored at the end of function)
imRGB = imRGB.^(2.2);

% set dmap and disparity map ranges to .01 and .99 quantiles to get rid of outliers
% then inpaint NaN values
[imZ,dispmap] = cleanDepth(imZOrig,dispmap);

%invert depth map if your created an "Against the Prior" image
if strcmp(flag,'ap')
    imZ = max(imZ(:)) - imZ;
end

%depth map anchor values for normalization
medianZ = median(imZ(:));
maxZ = max(imZ(:));

% convet RGB to HSV
imHSV = rgb2hsv(imRGB);

%get value channel
imV = imHSV(:,:,3);

%initialize matrices for enhancement calculations
[xdim ydim zdim] = size(imRGB);
imM = zeros(xdim,ydim);
imS = zeros(xdim,ydim);
imVnew = zeros(xdim,ydim);


% VALUE MANIPULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for each pixel
for x = 1:xdim
    for y = 1:ydim
        
        imS(x,y) = determineSlope(imZ(x,y),medianZ,maxZ);
        
        %REMAP INTENSITY
        imVnew(x,y) = imS(x,y)*imV(x,y);
        
    end
end

% IMAGE RECONSTRUCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sum(imVnew(:) > 1) > 0 || sum(imVnew(:) < 0) > 0
    imVnew(imVnew > 1) = 1;
    imVnew(imVnew < 0) = 0;
    error('pixel values were clipped');
end

%recon color image
imHSVnew = imHSV;
imHSVnew(:,:,3) = imVnew;
imRGBnew = hsv2rgb(imHSVnew);

%reapply PNG gamma encoding
imRGB = imRGB.^(1/2.2);
imRGBnew = imRGBnew.^(1/2.2);

%show results
if(showResults)
    figure; imagesc(imZ);
    figure; imshow(imV);
    figure; imshow(imVnew);
    figure; imshow(imRGB);
    figure; imshow(imRGBnew);
end

%restore depth map if it was inverted
if strcmp(flag,'ap')
    imZ = maxZ - imZ;
end

%save images
imwrite(imRGB,[new_dir dir_name 'right_original.png']);
imwrite(imRGBnew,[new_dir dir_name 'right_' flag '.png']);

if strfind(dir_name,'mb')
    imwrite(imLeftRGB,[new_dir dir_name 'left_original.png']);
end

%save extra intermediate images
extra_dir = [new_dir 'OtherManipulationInfo/'];
mkdir(extra_dir)
imwrite(imV.^(1/2.2),[extra_dir dir_name 'right_Voriginal.png']);
imwrite(imVnew.^(1/2.2),[extra_dir dir_name 'right_V' flag '.png']);

save([extra_dir dir_name 'right_dispmap.mat'],'dispmap')
imwrite(imadjust((imZ-min(imZ(:)))./range(imZ(:))),[extra_dir dir_name 'right_depthImage.png']);
save([extra_dir dir_name 'right_depthmapOriginal.mat'],'imZOrig')
save([extra_dir dir_name 'right_depthmapClean.mat'],'imZ')

save([extra_dir dir_name 'right_slopes.mat'],'imS')


if(storeCorrelation)
    calcAndStoreCorrelations(imRGB,imRGBnew,imZOrig,dir_name,flag)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[im,imLeft,dmap,dispmap,median_pixel_disparity] = loadImages(dir_name)

% Note that Middlebury depth is in disparity units, so we load disparity
% and convert to depth. LiveColor+3D is in meters, so we load depth and
% convert to disparity. Disparity maps are not used for enhancement, but
% might be interesting for later. The disparity map is also used to
% synthesize stereo for the Live3D images, which don't come with a stereo
% pair. So we load in a dummy left eye image for these, which is actually
% just identical to the right eye image.


%load in images and depth

if ~isempty(strfind(dir_name,'mb')) %Middlebury
    
    %load files
    im          = imread(['../Images/Originals/' dir_name '/' dir_name 'right.png']);
    imLeft      = imread(['../Images/Originals/' dir_name '/' dir_name 'left.png']);
    
    dispmap     = double(imread(['../Images/Originals/' dir_name '/' dir_name 'right_depth.png'])); %note that middlebury depth is in disparity units, so we have to convert it

    %This will be used to set zero disparity point in stereogram
    %presentation:
    %average disparity in pixels, divide by two to get shift for each image,
    %divide by 4 because l/r images are 1/4 the distance appart as disparity maps
    median_pixel_disparity = round(median((dispmap(~isnan(dispmap)))/2)/4);
 
    %deal invalid values
    dispmap(dispmap == 0) = NaN;
    
    %convert disparity to depth
    mb_fl_pix       = 3740; %from middlebury documentation
    mb_baseline_mm  = 160;
    dmin            =  double(textread(['../Images/Originals/' dir_name '/dmin.txt'])); %this offset value is provided to correct disparities
    dmap            = (mb_fl_pix*mb_baseline_mm)./(dispmap+dmin);
    dmap            = dmap./1000; % convert to meters
    
    %divide disparity by 4 because l/r images are 1/4 the distance appart as disparity maps 
    dispmap = dispmap./4;
    
elseif strfind(dir_name,'live')
	
    %load files
	im          = imread(['../Images/Originals/' dir_name '/' dir_name 'right.png']);
    imLeft      = imread(['../Images/Originals/' dir_name '/' dir_name 'right.png']);
    
    load(['../Images/Originals/' dir_name '/' dir_name 'right_range.mat']);
	dmap    = scene_range;

    %deal with invalid values
    dmap(dmap == 0)     = NaN;
    
    %convert depth to diopters, which are proportionate to disparity
    dispmap = 1./dmap;
    
    %this will be set later automatically in photoshop
    median_pixel_disparity = 0;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [im,imLeft,imZ,dispmap] = cropImages(im,imLeft,imZ,dispmap,median_pixel_disparity)

%crop to square with average zero disparity
leftedge = round((size(im,2)/2) - (size(im,1)/2))-median_pixel_disparity;
leftedge2 = round((size(im,2)/2) - (size(im,1)/2))+median_pixel_disparity;
imsize = size(im,1) - 1;

im = imcrop(im,[leftedge 1 imsize imsize]);
imLeft = imcrop(imLeft,[leftedge2 1 imsize imsize]);
imZ = imcrop(imZ,[leftedge 1 imsize imsize]);
dispmap = imcrop(dispmap,[leftedge 1 imsize imsize]);

%median disparity has now effectively been removed from disparity map
dispmap = dispmap - (2*median_pixel_disparity);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imZ,dispmap] = cleanDepth(imZ,dispmap)

%normalize dmap and disparity map, to .01 and .99 quantiles to get rid of
%outliers
imZ(imZ > quantile(imZ(:),0.99))                = quantile(imZ(:),0.99);
imZ(imZ < quantile(imZ(:),0.01))                = quantile(imZ(:),0.01);
dispmap(dispmap > quantile(dispmap(:),0.99))    = quantile(dispmap(:),0.99);
dispmap(dispmap < quantile(dispmap(:),0.01))    = quantile(dispmap(:),0.01);

%fill in depth and disparity maps nans
imZ     = inpaint_nans(imZ,2);
dispmap = inpaint_nans(dispmap,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slope] = determineSlope(z,medianZ,maxZ)

zdiff = z - medianZ;

if sign(zdiff) == -1 %dont change values that are nearer than median
    slope = 1;
elseif sign(zdiff) == 1
    zdiff_norm = zdiff./(maxZ-medianZ);
    slope = 1 - ((3/4)*zdiff_norm);
else
    slope = 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = calcAndStoreCorrelations(imRGB,imRGBnew,imZOrig,dir_name,flag)

%store the original and manipulated luminance/depth correlations
imY = rgb2gray(imRGB.^2.2);
imYnew = rgb2gray(imRGBnew.^2.2);

corrOrig = corr(imZOrig(~isnan(imZOrig)),imY(~isnan(imZOrig)));
corrNew = corr(imZOrig(~isnan(imZOrig)),imYnew(~isnan(imZOrig)));

if exist('luminanceDepthCorrelations.mat','file')
    load('luminanceDepthCorrelations.mat')
    
    ind = find(ismember(corrDat.scene,dir_name));
    
    if isempty(ind)
        ind = length(corrDat.scene)+1;
    end
else
    ind = 1;
end

corrDat.scene{ind} = dir_name;
corrDat.corrOrig(ind) = corrOrig;
if strcmp(flag,'tp')
    corrDat.corrTP(ind) = corrNew;
elseif strcmp(flag,'ap')
    corrDat.corrAP(ind) = corrNew;
end

save('luminanceDepthCorrelations.mat','corrDat')

%store the original and manipulated imaeg variances
if exist('luminanceDepthVariances.mat','file')
    load('luminanceDepthVariances.mat')
    
    ind = find(ismember(varDat.scene,dir_name));
    
    if isempty(ind)
        ind = length(varDat.scene)+1;
    end
else
    ind = 1;
end

varDat.scene{ind} = dir_name;
varDat.varOrig(ind) = var(imY(:));
if strcmp(flag,'tp')
    varDat.varTP(ind) = var(imYnew(:));
elseif strcmp(flag,'ap')
    varDat.varAP(ind) = var(imYnew(:));
end

save('luminanceDepthVariances.mat','varDat')


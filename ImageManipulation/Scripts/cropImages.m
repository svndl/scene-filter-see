%crop images and depth maps to be square

function cropped = cropImages(image)
    cropped = image;

    %crop to square with average zero disparity
    leftedge = round((size(cropped.imRGB, 2)/2) - (size(cropped.imRGB, 1)/2)) - cropped.median_pixel_disparity;
    leftedge2 = round((size(cropped.imRGB, 2)/2) - (size(cropped.imRGB, 1)/2)) + cropped.median_pixel_disparity;
    imsize = size(cropped.imRGB, 1) - 1;

    cropped.imRGB = imcrop(cropped.imRGB, [leftedge 1 imsize imsize]);
    cropped.imRGBLeft = imcrop(cropped.imRGBLeft, [leftedge2 1 imsize imsize]);
    cropped.imZ = imcrop(cropped.imZ, [leftedge 1 imsize imsize]);
    cropped.imZOrig = imcrop(cropped.imZOrig, [leftedge 1 imsize imsize]);
    cropped.dispmap = imcrop(cropped.dispmap, [leftedge 1 imsize imsize]);

    %median disparity has now effectively been removed from disparity map
    cropped.dispmap = cropped.dispmap - (2*image.median_pixel_disparity);
end
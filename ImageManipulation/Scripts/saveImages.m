function saveImages(image, storeCorrelation)

    extra_dir = [image.savepath 'OtherManipulationInfo/'];

    imwrite(image.imRGB, [image.savepath 'right_original.png']);
    imwrite(image.imRGBnew, [image.savepath 'right_' image.flag '.png']);

    if strfind(image.loadpath, 'mb')
        imwrite(image.imRGBLeft, [image.savepath 'left_original.png']);
    end
    
    %save extra intermediate images
    if (~exist(extra_dir, 'dir'))
        mkdir(extra_dir);
    end
    imwrite(image.imV.^(1/2.2),[image.savepath 'right_Voriginal.png']);
    imwrite(image.imVnew.^(1/2.2),[image.savepath 'right_V' image.flag '.png']);

    save([extra_dir 'right_dispmap.mat'], '-struct', 'image', 'dispmap');
    imwrite(imadjust((image.imZ - min(image.imZ(:)))./range(image.imZ(:))),[extra_dir image.name 'right_depthImage.png']);
    save([extra_dir image.name 'right_depthmapOriginal.mat'], '-struct', 'image', 'imZOrig');
    save([extra_dir image.name 'right_depthmapClean.mat'], '-struct', 'image', 'imZ');

    save([extra_dir image.name 'right_slopes.mat'], '-struct', 'image', 'imS');


    if(storeCorrelation)
        calcAndStoreCorrelations(image);
    end


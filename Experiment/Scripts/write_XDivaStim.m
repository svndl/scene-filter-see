function write_XDivaStim(where, blankA, sceneA, blankB, sceneB, ConditionType, number)

        images(:, :, :, 1) = single(blankA);        
        images(:, :, :, 2) = single(sceneA);
        images(:, :, :, 3) = single(blankB);        
        images(:, :, :, 4) = single(sceneB);
    
        freq = 0.5; 
        nFrames = calc_XDivaMatlabParadigm(freq);
        framesPerBin = nFrames/4;
        
        imageSequence = uint32(zeros(nFrames, 1));
        imageSequence(1) = 1;
        imageSequence(framesPerBin + 1) = 2;
        imageSequence(2*framesPerBin + 1) = 3;
        imageSequence(3*framesPerBin + 1) = 4;
        
        imageSequence(nFrames, 1) = 1;    
                
        number = [num2str(floor(number/10)) num2str(rem(number, 10))];
        filename = [ConditionType  '_' number];
        jpeg_dir = [where filesep 'jpegs'];
        
        if (~exist(jpeg_dir, 'dir'))
            mkdir(jpeg_dir);
        end
        
        
        imwrite(sceneA, fullfile(jpeg_dir,[filename 'A.jpeg']));
        imwrite(sceneB, fullfile(jpeg_dir, [filename 'B.jpeg']));
        imwrite(blankA, fullfile(jpeg_dir, [filename 'blankA.jpeg']));
        imwrite(blankB, fullfile(jpeg_dir, [filename 'blankB.jpeg']));
         
        save(strcat(where, filesep, filename, '.mat'), 'images', 'imageSequence');
end


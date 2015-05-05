function write_XDivaStim(where, blankA, sceneA, blankB, sceneB, ConditionType, number)

        images(:, :, :, 1) = single(blankA);        
        images(:, :, :, 2) = single(sceneA);
        images(:, :, :, 3) = single(blankB);        
        images(:, :, :, 4) = single(sceneB);
    
        freq = 0.5; 
        nFrames = edit_calcXDivaMatlabParadigm(freq);
        framesPerBin = nFrames/4;
        
        imageSequence = uint32(zeros(nFrames, 1));
        imageSequence(1) = 1;
        imageSequence(framesPerBin + 1) = 2;
        imageSequence(2*framesPerBin + 1) = 3;
        imageSequence(3*framesPerBin + 1) = 4;
        
        imageSequence(nFrames, 1) = 1;    
                
        number = [num2str(floor(number/10)) num2str(rem(number, 10))];
        filename = [ConditionType  '_' number];
        imwrite(sceneA, strcat(where, filesep, 'jpegs', filesep, filename, 'A.jpeg'));
        imwrite(sceneB, strcat(where, filesep, 'jpegs', filesep, filename, 'B.jpeg'));
        imwrite(blankA, strcat(where, filesep, 'jpegs', filesep, filename, 'blankA.jpeg'));
        imwrite(blankB, strcat(where, filesep, 'jpegs', filesep, filename, 'blankB.jpeg'));
         
        save(strcat(where, filesep, filename, '.mat'), 'images', 'imageSequence');
end


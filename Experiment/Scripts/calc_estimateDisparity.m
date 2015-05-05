function d = calc_estimateDisparity(left, right)
    imLeft = double(rgb2gray(left));
    imRight = double(rgb2gray(right));
    
    %normalize images
    maxLeft = max(max(imLeft));
    minLeft = min(min(imLeft));

    maxRight = max(max(imRight));
    minRight = min(min(imRight));
    
    nLeft = (imLeft - minLeft)./(maxLeft - minLeft);
    nRight = (imRight - minRight)./(maxRight - minRight);
    
    
    nCols = size(imLeft, 2);
    nRows = size(imRight, 1);
    
    midCol = floor(0.5*nCols);
    midRow = floor(0.5*nRows);
    
    delta_pix = 12;
    
    midLeftPatch= nLeft(midRow - delta_pix:midRow+delta_pix, midCol - delta_pix:midCol+delta_pix);    
    midRightPatch = nRight(midRow - delta_pix:midRow + delta_pix,:);
    
    %xc = xcorr2(midRightPatch, midLeftPatch);
    %[~, imax] = max(abs(xc(:)));
    shift = calcSSD(midLeftPatch, midRightPatch);
    %shift is the START pixel,
    d1 = floor(0.5*abs(midCol - (shift + delta_pix)));
    %clamp the top offset 
    if (d1 > 150)
        d1 = 150;
    end;
    d = [0 2*d1];
%     %mkNew rightImageParch2
%     midRightPatch_new = nRight(midRow - delta_pix:midRow + delta_pix, midCol - d1:midCol + d1);
%     
%     xc = xcorr2(midRightPatch_new, midLeftPatch);
%     [~, imax] = max(abs(xc(:)));
% 
%     [rowPeak, colPeak] = ind2sub(size(xc), imax(1));
%     %NEXT offset
%     
%     offset = [rowPeak - size(midLeftPatch, 1), colPeak - size(midLeftPatch, 2)];
%     %return only horisontal offset;
%     if (abs(offset(2) - 2*d1) == 0)
%         d = [0 2*d1];
%     else
%         d = [0 max(abs(offset))];
%     end
end
function shift = calcSSD(refPatch, patch2)
    
    lengthRef = size(refPatch, 2); 
    %ssd = sum(sum(abs(refPatch)));
    ssd = 0;
    nPos = size(patch2, 2) - size(refPatch, 2);
    for i = 1:nPos
        %cut out
        subpatch = patch2(:, i:lengthRef + i - 1);
        %distance = sum(sum(abs(refPatch - subpatch)));
        distance = corr2(refPatch, subpatch);
        if (distance > ssd)
            ssd  = distance;
            shift = i;
        end
    end
end
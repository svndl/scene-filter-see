function disparity = model_calcDisparity(depth)

    %make 2-D mean depth filter
    fwid    = 50;                                                  
    frange  = -fwid:fwid;                                           
    depthfilter     = model_mkGaussianRF(frange, 10);

    if sum(sum(depth)) > 0
        padded = padarray(depth, [fwid fwid]);
        fixations = conv2(padded, depthfilter, 'same' );   
        cropped = fixations(fwid + 1:end - fwid, fwid + 1:end - fwid);
        disparity = 60.* (180/pi).* 0.064.* ( (1./cropped) - (1./depth) );
    else
%         no depth map        
        disparity = zeros(size(depth));
   end
end



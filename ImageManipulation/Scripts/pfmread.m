function img = pfmread(fpath)

    % Load a pfm image into a Matlab matrix.  
    % Compatability with Jepson pfm output format
    %

    [fid, msg] = fopen( fpath, 'r' );
    if (fid == -1)
        error(msg);
    end
    
    % read header
    type = fgetl(fid);
    if (~strcmp(type, 'Pf') && ~strcmp(type, 'PF')) 
        fclose(fid);
        error('PFM file must be of type PL/PB');      
    end
    
    xydim = sscanf(fgetl(fid), '%f');
    aspect_ratio = sscanf(fgetl(fid), '%f');
    sz = xydim(1)*xydim(2);
    [im, count] = fread(fid, sz, 'float32');   
	
    fclose(fid);  
    if (count == sz)
        img0 = reshape(im, xydim(1), xydim(2));
    else
        fprintf(1, 'Warning: File ended early!');
        img0 = reshape( [im ; zeros(sz-count,1)], xdim, ydim)';
    end
    img = rot90(img0, 1);
    
end %pfmread

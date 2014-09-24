function im = imread_double(imfile,bits)

im = imread(imfile);

im = double(im)./((2^bits) - 1);
function out = bilateral(in2, sigd, sigr)
% orgimg = input image
% sigd   = domain parameter for spatial kernel
% sigr   = range parmeter for intensity kernel

% Code Developed BY : Suraj Kamya
% kamyasuraj@yahoo.com
% Modified by Shuichi Takahashi, 2015

% Other files used in1 this function
% rpadd = another function is used
% PSN   = Peak Signal to noise ratio
% IEF   = Image Enhancement Factor

% im = imread(orgimg);
% imwrite(im,'in1.jpg');
% figure,imshow(im); title('Input Image');

w = (2*sigd)+1;
% sigr=(n*100)^2/(.003*(sigd^2));  % Adaptive Selection of R
 
% Adding Noise
% in2=imnoise(im,'Gaussian',n);
% imwrite(in2,'in2.jpg');
% figure,imshow(in2); title('Noisy Image');

% Gaussian Filter Computation
[row clm]=size(in2);

gw=zeros(w,w); % gaussian weight matrix
c=ceil(w/2); 
c=[c c]; % Centre Element Position

for i=1:w    
    for j=1:w
        q=[i,j]; % neighborhood pixel address
        gw(i,j)=norm(c-q); % Euclidean distance of window with centre pixel after differance
    end
end

Gwd=(exp(-(gw.^2)/(2*(sigd^2)))); % Gaussian window by kernel


% Padding
proci = padarray(in2,[sigd sigd],'replicate'); % proci = image for processing
[row clm] = size(proci); % Size of image
proci = proci/max(max(proci)); % changing data type
K = sigd;

L=[-K:K];
c=K+1; % c,c is the position of centre element
iter=length(L); % iterations
ind=1;

% Create waitbar.
h = waitbar(0,'Wait...');
set(h,'Name','Bilateral Fiter Processing');

for r=(1+K):(row-K) % Indexing Row of noisy pixel     
    for s=(1+K):(clm-K) % Indexing Coloumn of noisy pixel        
            for i=1:iter % Indexing Row of window
                for j=1:iter % Indexing Column of window                    
                    win(i,j)=proci((r+L(i)),(s+L(j))); % Extracting window                    
                end
            end
            I=win; % Intensity Matrix
            win=win(c,c)-win; % Intensity Differance
            win=sqrt(win.^2); % Making value positive
            Gwi=exp(-(win.^2)/(2*(sigr^2))); % Gaussian window by kernel intensity matrix.      
%             Gwi=exp(-((.003*sigd)*win.^2)/(2*(n^2))); % Adaptive
            weights=(Gwi.*Gwd)/sum(sum(Gwi.*Gwd)); % Computing weight
            Ii=sum(sum(weights.*I)); % Final value which will be used in1 place of current pixel.            
            proci(r,s)=Ii; % Replacing value
            win=[];
    end
    waitbar(r/(row-K));
end
close(h)

% Removing Padding
out = rpadd(proci,K); % Calling another function to remove padding
% proci=rpadd(proci,K); % Calling another function to remove padding
% out=im2uint8(proci);
% figure,imshow(out)
% imwrite(out,'out.png');
% title('Result Image') 

%% Quality Measures
% orgimg=im2double(imread('in1.jpg'));
% nimg=im2double(imread('in2.jpg'));
% dimg=im2double(imread('out.jpg'));  
% 
% disp('PSNR'), psn=PSN(orgimg,dimg) % PSNR
% disp('IEF'), I=IEF(orgimg,nimg,dimg)
        

        
  
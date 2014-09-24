function [col] = getcol(cnt)

colors(:,1) = [ 228 30 38 ];
colors(:,2) = [ 51 127 186 ];
colors(:,3) = [ 206 200 104 ];
colors(:,4) = [ 76 175 74 ];
colors(:,5) = [ 154 80 159 ];
colors(:,6) = [ 245 129 32 ];

colors = colors./255;

col = colors(:,cnt);
            

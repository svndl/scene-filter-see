%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slope] = determineSlope(z, medianZ, maxZ)

    zdiff = z - medianZ;

%     if sign(zdiff) == -1 %dont change values that are nearer than median
%         slope = 1;
%     elseif sign(zdiff) == 1
%         zdiff_norm = zdiff./(maxZ-medianZ);
%         slope = 1 - ((3/4)*zdiff_norm);
%     else
%         slope = 1;

    slope = 1;
    if(sign(zdiff) == 1)
        zdiff_norm = zdiff./(maxZ - medianZ);
        slope = 1 - ((3/4)*zdiff_norm);
    end
end

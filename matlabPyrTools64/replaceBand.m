function[pyr] = replaceBand( pyr, ind, level, newband )

    bandInd = pyrBandIndices( ind, level );
    pyr(bandInd) = newband(:);
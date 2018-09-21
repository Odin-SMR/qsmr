% LOAD_CO_VMR_MIPAS   
%
%   Loads VMR array for specific month and latitude bin  
%   from MIPAS a priori file
%
%
% FORMAT   co_vmr_mipas = load_co_vmr_mipas(MIPAS, mjd,lat)
%        
% OUT   co_vmr_mipas       1-D array (vs altitude)
% IN    MIPAS
%	mjd
%	lat
%
%
% 2018-06-20   Created by Francesco Grieco.

function co_vmr_mipas = load_co_vmr_mipas(MIPAS, mjd, lat)

    [yyyy,mm,dd] = mjd2date( mjd );

    LatBins    = [-90 : 10 : 90]; 

    for l = 1 : length(MIPAS.GRID2)
        if lat >= LatBins(l) && lat < LatBins(l+1)
            co_vmr_mipas = MIPAS.DATA(:,l,1,mm)
        end
    end
                           

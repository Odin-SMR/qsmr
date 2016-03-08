% MJD2LOCALTIME   Approximative local solar time
%
%    The function calculates in a simplistic manner a local solar time
%    based on modified julian date and longitude. 
%
% FORMAT   ltime = mjd2localtime( mjd, lon )
%        
% OUT   ltime     Approximative local time [0,23.9999]
% IN    mjd       Modified julian date. Tensor or scalar.
%       lon       Longitudes. Matching tensor or scalar.

% 2008-03-18   Created by Patrick Eriksson.

function ltime = mjd2localtime( mjd, lon )
                                                                            %&%
rqre_element_math( mjd, lon )                                               %&%

  
lon = shift_longitudes( lon, 0, 360 );
  
ltime = rem( 24*(mjd-floor(mjd)) + lon/15, 24 );
  
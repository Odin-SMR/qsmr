%------------------------------------------------------------------------
% NAME:    geomztan2za
%
%          Converts a vector of geometrical tangent altitudes to zenith 
%          angles. A spherical planet is assumed.
%
% FORMAT:  za = geomztan2za(re,z_plat,z_tan)
%
% RETURN:  za        Zenith angles corresponding to z_tan.
% IN:      re        Planet radius.
%          z_plat    Platform altitude.
%          z_tan     Geometrical tangent altitudes. 
%------------------------------------------------------------------------

% HISTORY: 2004-09-11   Adapted from AMI function geomtan2za
%          2000.12.18   Created by Patrick Eriksson. 


function za = geomztan2za(re,z_plat,z_tan)


za = (pi - asin((re+z_tan)./(re+z_plat)) ) * 180/pi;

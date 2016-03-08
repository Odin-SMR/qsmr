% Q2_CALC_SCAN_POS   Centre time and position of a scan, based on logdata
%
%    The function mimics how scan time and position are determined in the
%    database.
%   
% FORMAT [mjd,lat,lon,z] = q2_calc_scan_pos( LOG )
%
% OUT  MJD   Modified Julian date
%      lat   Latitude
%      lon   Longitude
%      z     Altitude 
% IN   LOG   Log data of a single scan.

% 2015-12-18   Created by Patrick Eriksson.


function [mjd,lat,lon,z] = q2_calc_scan_pos( LOG )

mjd = mean( LOG.MJDStart + LOG.MJDEnd );

r   = earth_radius;

[x1,y1,z1] = geocentric2cart( r+LOG.AltStart, LOG.LatStart, LOG.LonStart );
[x2,y2,z2] = geocentric2cart( r+LOG.AltEnd,   LOG.LatEnd,   LOG.LonEnd );

[z,lat,lon] = cart2geocentric( (x1+x2)/2, (y1+y2)/2, (z1+z2)/2 );


% Lon shall be inside [0,360]
if lon < 0
  lon = lon + 360;
end
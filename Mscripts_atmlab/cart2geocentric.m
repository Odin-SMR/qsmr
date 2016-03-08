% CART2GEOCENTRIC   converts a cartesian position to spherical coordinate 
%
%   The geocentric Cartesian coordinate system is fixed with respect to the
%   Earth, with its origin at the center of the ellipsoid and its X-, Y-,
%   and Z-axes intersecting the surface at the following points:
% 
%                 lat   lon
%       X-axis:    0     0      (Equator at the Prime Meridian)
%       Y-axis:    0    90      (Equator at 90-degrees East)
%       Z-axis:   90     0      (North Pole)
% 
%    A common synonym is Earth-Centered, Earth-Fixed coordinates, or ECEF.
%
%    If the optional arguments are given, it is ensured that latitude and
%    longitude are kept constant for zenith or nadir cases, and the longitude
%    for N-S cases. The optional input shall be interpreted as the [x,y,z]
%    is obtained by moving from [lat0,lon0] in the direction of [za0,aa0].
% 
% FORMAT  [r,lat,lon]=cart2geocentric(x,y,z[,lat0,lon0,za0,aa0]) 
%
% OUT     r      Radius 
%         lat    Latitude
%         lon    Longitude
% IN      x      Coordinate in x dimension
%         y      Coordinate in y dimension
%         z      Coordinate in z dimension
%         lat0   Original latitude
%         lon0   Original longitude
%         za0    Orignal zenith angle
%         aa0    Orignal azimuth angle

% History: created by Bengt Rydberg 2011-10-31

function [r,lat,lon]=cart2geocentric(x,y,z,lat0,lon0,za0,aa0)

rad2deg = 180/pi;   %constants( 'RAD2DEG' );


r   = sqrt( x.*x + y.*y + z.*z );
lat = rad2deg * asin( z ./ r );
lon = rad2deg * atan2( y, x ); 


if nargin > 3
  
  n = length(r);
  
  for i = 1 : n

    %Zenith or nadir?
    if za0(i) < 1e-6  |  za0(i) > 180-1e-6 
      lat(i) = lat0(i);
      lon(i) = lon0(i);
    end
    
    % N-S case (not starting at a pole)?
    if abs(lat0(i)) < 90-1e-8  & ...
      ( abs(aa0(i)) < 1e-6  |  abs(aa0(i)-180) < 1e-6 )
      % Check that not lon changed with 180 deg
      if abs(lon(i)-lon0(i)) < 1 
        lon(i) = lon0(i);
      else
        if lon0(i) > 0
          lon(i) = lon0(i) - 180;
        else
          lon(i) = lon0(i) + 180;
        end          
      end
    end      
  end
  
end



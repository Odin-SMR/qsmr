% Q2_CALC_1DVIEWGEOM   Determines geometry settings for 1D simulations
%
%    Write when curvature radius is used ...
%   
% FORMAT [r_earth,z_odin,za] = q2_calc_1dviewgeom( L1B )
%
% OUT  r_earth   Earth radius to apply.
%      z_odin    Altitude of Odin (a scalar value).
%      za        Zenith angle for each spectrum.
% IN   L1B       L1B data structure.

% 2015-12-18   Created by Patrick Eriksson.


function [r_earth,z_odin,za] = q2_calc_1dviewgeom( L1B )

% So far we use a spherical Earth  
  
r_earth = earth_radius;

r_odin = mean( sqrt( sum( L1B.GPSpos.^2, 2 ) ) );

z_odin = r_odin - r_earth;

za = vec2col( geomztan2za( r_earth, z_odin, L1B.Altitude ) );

  

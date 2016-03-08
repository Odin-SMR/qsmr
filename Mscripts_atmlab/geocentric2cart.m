% GEOCENTRIC2CART   converts from spherical coordinate to a cartesian position
%
% See Contents.m for a defintion of the geocentric coordinate system
% 
% FORMAT  [x,y,z]=geocentric2cart(r,lat,lon) 
%
% OUT     x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%
% IN      r    Radius 
%         lat  Latitude
%         lon  Longitude

% History: created by Bengt Rydberg 2011-10-31

function [x,y,z]=geocentric2cart(r,lat,lon)

deg2rad = pi/180;   %constants( 'DEG2RAD' );

latrad = deg2rad * lat;
lonrad = deg2rad * lon;

x = r .* cos( latrad );   % Common term for x and y
y = x .* sin( lonrad );
x = x .* cos( lonrad );
z = r .* sin( latrad );



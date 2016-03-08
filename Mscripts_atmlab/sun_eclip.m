function [L,ep,g] = sun_eclip(mjd)
% SUN_ECLIP Ecliptic coordinates of the Sun.
%   [l,ep,g] = sun_eclip(mjd) calculates the Sun's ecliptic longitude,
%   obliquity of the ecliptic and mean anomaly, from the Astronomical
%   Almanac (see Michalsky, 1988).  The angles are in radians.

%----------------------------------------------------------------
% Craig Haley 20/09/01
%   30-06-04 CSH made small changes
%   02-10-05 CSH vectorized
%----------------------------------------------------------------

DEGREE = pi/180.0;

D = mjd-51544.5;

%mean longitude between 0 and 360 degrees
q = 280.459+0.98564736*D;
q = mod(q,360.0);
q(q < 0) = q(q < 0)+360;

%mean anomaly in radians between 0 and 2*PI
g = 357.529+0.98560028*D;
g = mod(g,360.0);
g(g < 0) = g(g < 0)+360;
g = g*DEGREE;

%ecliptic longitude in radians between 0 and 2*PI
L = q+1.915*sin(g)+0.020*sin(2.0*g);
L = mod(L,360.0);
L(L < 0) = L(L < 0)+360;
L = L*DEGREE;

%obliquity of ecliptic in radians
ep = 23.439-0.00000036*D;
ep = ep*DEGREE;

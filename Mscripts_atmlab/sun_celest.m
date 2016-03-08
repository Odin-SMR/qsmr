function [ra,dec] = sun_celest(mjd)
% SUN_CELEST Celestial coordinates of the Sun.
%   [ra,dec] = sun_celest(mjd) calculates the Sun's Right Ascension and
%   Declination at a given time, from the Astronomical Almanac (see
%   Michalsky, 1988).  Both angles are given in radians.

%----------------------------------------------------------------
% Craig Haley 20/09/01
%   02-10-05 CSH vectorized
%----------------------------------------------------------------

DEGREE = pi/180.0;
RADIAN = 180.0/pi;

%get position of sun in ecliptic
[L,ep,g] = sun_eclip(mjd);

%right ascension in radians between 0 and 2*PI
f = RADIAN;
t = (tan(ep/2.0)).^2;
ra = L*RADIAN-f.*t.*sin(2.0*L)+(f/2.0).*t.^2.*sin(4.0*L);
ra = mod(ra,360.0);
ra(ra < 0) = ra(ra < 0)+360;
ra = ra*DEGREE;

%calculate declination in radians
dec = asin(sin(ep).*sin(L));

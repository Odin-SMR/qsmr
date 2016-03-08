function [sza,saa] = sun_angles(mjd,lat,lon)
% SUN_ANGLES Finds solar conditions.
%   [sza,saa] = sun_angles(mjd,lat,lon) calculates the Sun's zenith and
%   azimuth angles for a given location and time, from Astronomical Almanac
%   (see Michalsky, 1988).
%
%  Refraction is not considered.
%
% See also: mjd2localtime, date2mjd

%----------------------------------------------------------------
% Craig Haley 20/09/01
%   02-10-05 CSH vectorized
%----------------------------------------------------------------

DEGREE = pi/180.0;
RADIAN = 180.0/pi;

%calculate position of sun in celestial
[ra,dec] = sun_celest(mjd);

%calculate the Greenwich mean siderial time in hours
gmst = mjd2gmst(mjd);

%calculate local mean siderial time in radians
lmst = gmst+lon/15.0;
lmst = mod(lmst,24.0);
lmst(lmst < 0) = lmst(lmst < 0)+24;
lmst = lmst*15.0*DEGREE;

%calculate hour angle in radians between -PI and PI
%here we ignore the equation of the equinoxes factor
ha = lmst-ra;
ha(ha < -pi) = ha(ha < -pi)+2*pi;
ha(ha > pi) = ha(ha > pi)-2*pi;

%calculate altitude angle in radians
a = asin(sin(dec).*sin(lat*DEGREE)+cos(dec).*cos(ha).*cos(lat*DEGREE));

%calculate azimuth in radians between 0 and 2*PI
az = atan2(sin(ha),cos(ha).*sin(lat*DEGREE)-tan(dec).*cos(lat*DEGREE))+pi;

%     %calculate the refraction correction factor
%     P = 1016.0;   %pressure in millibars
%     T = 23.5;     %temperature in C
%     if (a < 15.0)
% 	    R = 0.00452*P/((273.0+T)*tan(a));
%     else
% 	    R = P*(0.1594+0.0196*a+0.00002*a*a)/((273.0+T)*(1.0+0.505*a+0.0845*a*a));
%     end

%calculate zenith and azimuth angles in degrees
sza = 90.0-(a*RADIAN);        %add R to correct for refraction
saa = az*RADIAN;

function [gmst] = mjd2gmst(mjd)
% MJD2GMST Convert modified julian date to greenwich mean sidereal time.
%   [gmst] = mjd2gmst(mjd) converts modified julian date to greenwich mean
%   sidereal time using the algorithm from the Astronomical Almanac 2002,
%   pg. B6.

%----------------------------------------------------------------
% Craig Haley 20/09/01
%   30-06-04 CSH made small changes
%   05-01-05 CSH modifed to use mjd rather than converting to jd
%----------------------------------------------------------------

%calculate the greenwich mean sidereal time at midnight
mjd2000 = 51544.5;        %Modified Julian Date of Epoch J2000.0
int_mjd = floor(mjd);
frac_mjd = mjd-int_mjd;
Tu = (int_mjd-mjd2000)/36525.0;
gmst = 24110.54841+Tu.*(8640184.812866+Tu.*(0.093104-Tu*6.2e-6));

%add the mean sidereal time interval from midnight to time
gmst = mod(gmst+frac_mjd*86400*1.00273790934,86400);

%convert to hours
gmst = gmst/3600;

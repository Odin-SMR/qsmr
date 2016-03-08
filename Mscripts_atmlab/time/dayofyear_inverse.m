function out = dayofyear_inverse(year,doy)
% DAYOFYEAR_INVERSE if you have the day of year and want the month and day.
%
% IN: 
%       year         %f
%       doy          %f
%
% OUT: structure containing e.g.
%
%  out =    yr: 2006
%           mn: 10
%          day: 27
%    dayofyear: 300
%
% USAGE out =  dayofyear_inverse(2006,254)
%
%      out = 
%               year: 2006
%              month: 9
%                day: 11
%          dayofyear: 254
%
%
% 27/8-2010 Salomon Eliasson
% 2010-10-11 Improved by Gerrit
%
% $Id: dayofyear_inverse.m 7219 2011-11-23 10:51:25Z seliasson $

errId = ['atmlab:' mfilename ':badInput'];
assert(nargin==2 && isscalar(year) && isscalar(doy),...
    errId,'requires year and doy input as scalars')
assert(doy<=daysinyear(year),errId, 'too many days')

[yr mn day] = jd2date(date2jd(double(year), 1, 0) + double(doy));
out.year = yr;
out.month = mn;
out.day = day;
out.dayofyear = doy;
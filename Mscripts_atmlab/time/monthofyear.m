function ym = monthofyear( varargin )
%MONTHOFYEAR Ordinal number of month in year.
%
%   MONTHOFYEAR(YEAR, MONTH, DAY, HOUR, MINUTE, SECOND) returns the ordinal
%   month number in the given year plus a fractional part depending on the
%   day and time of day.
%
%   Any missing MONTH or DAY will be replaced by ones.  Any missing HOUR,
%   MINUTE or SECOND will be replaced by zeros.
%
%   If no date is specified, the current date and time is used.  Gregorian
%   calendar is assumed.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 12:50:16 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

% 2006-03-31   Introduced day-1 to reduce a slight "bias". Without -1
%              the month can be 13.

   nargsin = nargin;
   error(nargchk(0, 6, nargsin));
   if nargsin
      argv = {1 1 1 0 0 0};
      argv(1:nargsin) = varargin;
   else
      argv = num2cell(clock);
   end
   [year, month, day, hour, minute, second] = deal(argv{:});

   ym = month + (dayofmonth(year, month, day-1, hour, minute, second)) ...
                ./ daysinmonth(year, month);

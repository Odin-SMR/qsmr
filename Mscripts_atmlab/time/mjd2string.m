% MJD2STRING   Converts a MJD value to a date string
%
% FORMAT   s = mjd2string( mjd [, onlyday] )
%        
% OUT   s          Date string.
% IN    mjd        Modified julian date. A single value.
% OPT   onlydate   Flag to not include hours, minutes and seconds. 
%                  Default is false.


% 2007-12-07   Created by Patrick Eriksson.


function s = mjd2string( mjd, onlyday )
%
if nargin < 2,  onlyday = false; end
  
  
[year,month,day,h,m,s] = mjd2date( mjd );


if ~onlyday
  s = sprintf( '%04d-%02d-%02d %02d:%02d:%06.3f', year,month,day,h,m,s );
else
  s = sprintf( '%04d-%02d-%02d', year,month,day );
end
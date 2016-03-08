% MJD2MONTH   Conversion of MJD to month  
%
%    Calculates the month by combining *mjd2date* and  *dayofmonth*. 
%    Fractional part of month is kept. Jan 15 is about 1.5.
%
% FORMAT   m = mjd2month(mjd)
%        
% OUT   m     Month number.
% IN    mjd   Modified julian date. Can be a vector.

% 2006-03-31   Created by Patrick Eriksson.

function m = mjd2month(mjd)
                                                         %&%
rqre_datatype( mjd, @isnumeric );                        %&%

[year, month, day, hour, minute, second] = mjd2date( mjd(:) );

%= *monthofyear* does not handle column vectors
%
if dimens(year) < 2  & length(year) > 1
  year   = vec2row( year );
  month  = vec2row( month );
  day    = vec2row( day );
  hour   = vec2row( hour );
  minute = vec2row( minute );
  second = vec2row( second );
end

%- To ensure that m gets same size as mjd
%
m = zeros( size( mjd ) );


m(:) = monthofyear( year, month, day, hour, minute, second );
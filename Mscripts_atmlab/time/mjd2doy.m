% MJD2DOY   Conversion of MJD to day of year  
%
%    Calculates the day of the year (DOY) by combining *mjd2date* and 
%    *dayofyear*. The fractional part of DOY is kept.
%
%    Note that DOY 1 starts 00:00 of January 1. The possible range of DOY is
%    then [1,367[.
%
% FORMAT   d = mjd2doy(mjd)
%        
% OUT   d     Day of year.
% IN    mjd   Modified julian date. Can be a tensor.

% 2006-03-31   Created by Patrick Eriksson.

function d = mjd2doy(mjd)
                                                                            %&%
rqre_datatype( mjd, @isnumeric );                                           %&%

%make sure the data is double
mjd = double(mjd);

[year, month, day, hour, minute, second] = mjd2date( mjd(:) );

%= *dayofyear* does not handle column vectors
%
if dimens(year) < 2  & length(year) > 1
  year   = vec2row( year );
  month  = vec2row( month );
  day    = vec2row( day );
  hour   = vec2row( hour );
  minute = vec2row( minute );
  second = vec2row( second );
end


%- To ensure that d gets same size as mjd
%
d = zeros( size( mjd ) );


d(:) = dayofyear( year, month, day, hour, minute, second );
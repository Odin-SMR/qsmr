% MJD2SEASON   Conversion of MJD to season  
%
%    Returns a number indicating the season. The year is divided into 4
%    seasons, where the months per season can be changed by *month1*.
%
% FORMAT   s = mjd2season(mjd,month1)
%        
% OUT   s        Season number.
% IN    mjd      Modified julian date. Can be a vector.
% OPT   month1   Start month of "season year". Default is 12 which
%                gives the seasons DJF, MAM, JJA and SON.

% 2006-03-31   Created by Patrick Eriksson.

function s = mjd2season(mjd,month1)
%
if nargin < 2
  month1 = 12;
end
                                                                            %&%
rqre_datatype( mjd, @isnumeric );                                           %&%
rqre_alltypes( month1, {@istensor0,@iswhole} );                             %&%
rqre_in_range( month1, 1, 12 );                                             %&%


m = floor(mjd2month(mjd)) - month1 + 1;

ind = find( m<1 );

m(ind) = m(ind)+12;

s = ceil( m/3 );




% HOMEMADE_L1B   Create L1B for testing and internal usage
%
%   The function creates a L1B structure matching the input arguments and
%   various hard-code settings. This L1B structure just contains the fields
%   used by Qsmr. Several fields are set in an approximative manner.
%
%   Most input arguments after *ztan* can either be a scalar or a vector. If
%   a vector, the length must be the same as for *ztan*. Several fields of
%   L1B are set following *O*.
%
%   A basic LOG file can alos be obtained. URL fields are filled if ScanID is
%   not NaN.
%
% FORMAT   L1B = homemade_l1b(O,ztan,lat,lon,mjd[,freqs,inttime])
%
% OUT   L1B       Simplified L1B structure
% IN    O         O structure containing data for frequency mode of concern.
%       ztan      Vector of geomtrical tangent altitudes.
%       lat       Latitude(s).
%       lon       Longitude(s).
%       mjd       Modified Julian date(s).
% OPT   scandid   Scab ID (a scalar value). Default is NaN.
%       freqs     Frequency vector. Default is [], which flags to use 
%                 O.F_BACKEND_NOMINAL.
%       z_odin    Altitude(s) of Odin.
%       inttime   Integration time(s). Default is 0.872.

% 2015-12-20   Patrick Eriksson

function [L1B,LOG] = homemade_l1b(O,ztan,lat,lon,mjd,varargin)
%
[scanid,freqs,z_odin,inttime] = optargs( varargin, { NaN, [], 600e3, 0.872 } );

%
% Hard-coded values
%
f_doppler = 11e6;    % Doppler shift. Atm freqs + f_doppler give sat freqs,
                     % value valid at "RestFreq"
r_earth   = constants( 'EARTH_RADIUS' );


%
% Start with all frequencies. 
%
nt = length( ztan );
%
%                       
if isempty(freqs)
  L1B.Frequency = repmat( vec2col(O.F_BACKEND_NOMINAL), 1, nt );
else
  L1B.Frequency = repmat( vec2col(freqs),               1, nt );  
end
%
L1B.RestFreq    = vectorfield( mean(L1B.Frequency(:,1)), nt, 'RestFreq' );
L1B.SkyFreq     = vectorfield( L1B.RestFreq+f_doppler,   nt, 'SkyFreq' );
f_lo            = O.F_LO_NOMINAL + f_doppler*O.F_LO_NOMINAL/L1B.RestFreq(1);
L1B.LOFreq      = vectorfield( f_lo,                     nt, 'LOFreq' );
 
  
%
% L1B
%
L1B.Altitude    = vectorfield( ztan,                 nt, 'ztan'          );
L1B.Backend     = vectorfield( O.BACKEND_NR,         nt, 'O.BACKEND_NR'  );
L1B.FreqMode    = vectorfield( O.FMODE,              nt, 'O.FMODE'       );
L1B.Frontend    = vectorfield( O.FRONTEND_NR,        nt, 'O.FRONTEND_NR' );
% Assume that just radius is extracted from GPSpos!
L1B.GPSpos      = matrixfield( [0;0;r_earth+z_odin], nt, 'GPSpos'        );
L1B.Hanning     = vectorfield( 1,                    nt, 'Hanning'       );
L1B.IntTime     = vectorfield( inttime,              nt, 'inttime'       );
L1B.Latitude    = vectorfield( lat,                  nt, 'lat'           );
L1B.Longitude   = vectorfield( lon,                  nt, 'lon'           );
L1B.ScanID      = vectorfield( scanid,               nt, 'scanid'        );


%
% LOG
%
if nargout > 1  
  LOG.AltEnd       = ztan(end);
  LOG.AltStart     = ztan(1);
  LOG.EndLat       = lat(end);
  LOG.StartLat     = lat(1);
  LOG.EndLon       = lon(end);
  LOG.StartLon     = lon(1);
  LOG.MJD          = mean( mjd );
  LOG.NumSpec      = length(ztan);
  LOG.ScanID       = scanid;
  %
  if ~isnan( scanid )
    % Set URLs
  end
end
return



function b = vectorfield( a, nt, inname )
  if length(a) == 1
    b = repmat( a, 1, nt );
  elseif length(a) == nt
    b = vec2col( a );
  else
    error( ['Incorrect size of *%s*. It must be a scalar, or have same ' ...
            'length as *ztan*.'], inname );
  end
return

function b = matrixfield( a, nt, inname )
  if ~istensor1(a)
    error( ['*%s* must be a tensor1.'], inname );    
  end
  if size(a,2) == 1
    b = repmat( a, 1, nt );
  elseif length(a) == nt
    b = a;
  else
    error( ['Incorrect size of *%s*. It must be a tensor1, or have number ' ...
            'of columns matching length of *ztan*.'], inname );
  end
return
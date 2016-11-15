% L1B_HOMEMADE   Create L1B for testing and internal usage
%
%   The function creates LOG and L1B structures matching the input arguments and
%   various hard-code settings. This L1B structure just contains the fields
%   used by Qsmr. Several fields are set in an approximate manner. 
%
%   Most input arguments after *ztan* can either be a scalar or a vector. If
%   a vector, the length must be the same as for *ztan*. Several fields of
%   L1B are set following *Q*.
%
%   A basic LOG file can also be obtained. URL fields are not yet filled.
%
% FORMAT   [LOG,L1B] = l1b_homemade(Q,ztans,lat,lon,mjd[,freqs,inttime])
%
% OUT   LOG       Simplified LOG structure
%       L1B       Simplified L1B structure
% IN    O         O structure containing data for frequency mode of concern.
%       ztans     Vector of geometrical tangent altitudes.
%       lat       Latitude(s).
%       lon       Longitude(s).
%       mjd       Modified Julian date(s).
% OPT   scandid   Scan ID (a scalar value). Default is NaN.
%       freqs     Frequency vector. Default is [], which flags to use 
%                 Q.F_RANGES.
%       z_odin    Altitude(s) of Odin. Default is 600 km.
%       inttime   Integration time(s). Default is 0.872.
%       df        Channel frequency spacing. Default is 1 MHz,

% 2015-12-20   Patrick Eriksson

function [LOG,L1B] = l1b_homemade(Q,ztans,lat,lon,mjd,varargin)
%
[scanid,freqs,z_odin,inttime,df] = optargs( varargin, ...
                                            { NaN, [], 600e3, 0.872, 1e6 } );

%
% Hard-coded values
%
f_doppler = -12e6;    % Doppler shift. 
r_earth   = earth_radius;


%
% LOG
%
LOG.AltEnd       = ztans(end);
LOG.AltStart     = ztans(1);
LOG.DateTime     = mjd2string( mean(mjd) );
LOG.LatEnd       = lat(end);
LOG.LatStart     = lat(1);
LOG.LonEnd       = lon(end);
LOG.LonStart     = lon(1);
LOG.MJDEnd       = mjd(end);
LOG.MJDStart     = mjd(1);
LOG.NumSpec      = length(ztans);
LOG.ScanID       = scanid;
LOG.SunZD        = sun_angles( mjd, lat, lon );
%
%if ~isnan( scanid )
%  error( 'URLs not yet set.' );
%    % Set URLs
%end



if nargout > 1

  %
  % Channel frequencies
  %                       
  if isempty(freqs)
    for i = 1:size(Q.F_RANGES,1)    
      freqs = [ freqs; [ Q.F_RANGES(i,1):df:Q.F_RANGES(i,2) ]' ];
    end
  else
    freqs = vec2col( freqs );
  end

  %
  % Main sizes
  %
  nt = length( ztans );
  nf = length( freqs );  
  
  %
  % Frequency field
  %
  L1B.Frequency.AppliedDopplerCorr = vectorfield( f_doppler,      nt, 'f_doppler' );
  L1B.Frequency.ChannelsID         = repmat( NaN, nf, 1 );
  L1B.Frequency.IFreqGrid          = vectorfield( freqs-Q.F_LO_NOMINAL, ...
                                                                  nf, 'IFreqGrid' );  
  L1B.Frequency.LOFreq             = vectorfield( Q.F_LO_NOMINAL, nt, 'LOFreq' );
  L1B.Frequency.SubBandIndex       = repmat( -1, 2, 8 );
  L1B.Frequency.SubBandIndex(:,1)  = [1 nf ];
  
    
  %
  % L1B
  %
  L1B.Altitude    = vectorfield( ztans,                nt, 'ztan'          );
  L1B.Apodization = vectorfield( 1,                    nt, 'Apodization'   );
  L1B.Backend     = vectorfield( Q.BACKEND_NR,         nt, 'Q.BACKEND_NR'  );
  L1B.FreqMode    = vectorfield( Q.FREQMODE,           nt, 'Q.FREQMODE'    );
  L1B.FreqRes     = vectorfield( df,                   nt, 'df'            );
  L1B.Frontend    = vectorfield( Q.FRONTEND_NR,        nt, 'Q.FRONTEND_NR' );
  % Assume that just radius is extracted from GPSpos!
  L1B.GPSpos      = matrixfield( [0;0;r_earth+z_odin], nt, 'GPSpos'        );
  L1B.Hanning     = vectorfield( 1,                    nt, 'Hanning'       );
  L1B.IntTime     = vectorfield( inttime,              nt, 'inttime'       );
  L1B.Latitude    = vectorfield( lat,                  nt, 'lat'           );
  L1B.Longitude   = vectorfield( lon,                  nt, 'lon'           );
  L1B.ScanID      = vectorfield( scanid,               nt, 'scanid'        );

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
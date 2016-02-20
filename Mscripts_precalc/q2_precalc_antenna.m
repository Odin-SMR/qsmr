% Q2_PRECALC_ANTENNA   Pre-calculation of antenna responses
%
%    The function pre-calculates antenna response files for all combinations
%    of frequency mode and integration times.
%
%    Used input files are hard-coded. The input files hold static 1D patterns
%    at 490, 540 and 580 GHz (the same as in Qsmr1). A linear interpolation in
%    frequency is applied. No extrapolation is allowed and only frequencies
%    between 490 and 580 GHz are handled. 
%  
%    The antenna pattern is calculated for the mean of first and last value in
%    Q.F_RANGES
%
%    The effect of vertical scanning is included. This calculation assumes a
%    fixed satellite altitude of 600 km and a tangent altitude of 20 km. The
%    set of integration times is taken from P.INTEGRATION_TIMES.
%
%    Final files are stored in Q.FOLDER_ANTENNA
%
%    Call the function as with O set to o_std(q2_fmodes) to perform
%    pre-calculations for all frequency modes defined.
%
% FORMAT   q2_precalc_antenna(QQ,P)
%        
% IN    QQ  An array of Q structures
%       P   A P structure

% 2015-05-19   Created by Patrick Eriksson.


function q2_precalc_antenna(QQ,P)
  

%- Set in and out folder
%
topfolder = q2_topfolder;
%
infolder  = fullfile( topfolder, 'DataFiles', 'Antenna' );


% Read lab data files
%
flab = [ 490, 540, 580 ];  % GHz
%
for i = 1 : length(flab)

  filename = fullfile( infolder, sprintf('antenna%.0f.dat',flab(i)) );
  fid      = fileopen( filename );

  data     = fscanf( fid, '%f' );
  ldata    = length( data );
  dza{i}   = data( 1:2:ldata );
  
  fileclose( fid );
  
  if i > 1  &  any( dza{i} ~= dza{1} )
    error( 'The input files must use the same zenith angle grid.' );
  end
  
  D(:,i) = data( 2:2:ldata );
end
%
flab   = flab*1e9;     % Now Hz
dza_in = dza{1};
%
clear filename fid data ldata dza


%- Loop all combinations of fmodes and integration times.
%
for i = 1 : length( QQ )

  f0 = mean( [ min(QQ(i).F_RANGES(:)) max(QQ(i).F_RANGES(:)) ] );
  
  for j = 1 : length( P.INTEGRATION_TIMES )

    G = calc_in_subfun( flab, dza_in, D, f0, P.INTEGRATION_TIMES(j) );

    outfolder = QQ(i).FOLDER_ANTENNA;
    
    outfile = fullfile( outfolder, ...
                        sprintf( 'antenna_fmode%02d_tint%04.0fms.xml', ...
                        QQ(i).FREQMODE, P.INTEGRATION_TIMES(j)*1e3 ) );

    xmlStore( outfile, G, 'GriddedField4' );
  end
end


%- Create a simple README
%
fid = fopen( fullfile( outfolder, 'README' ), 'w' );
fprintf( fid, 'The antenna files in this folder were created\n' );
fprintf( fid, sprintf( 'by the function *%s*.', mfilename ) );
fclose( fid );

return
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

function G = calc_in_subfun( flab, dza_in, D, f0, tint )

  if f0 < flab(1) | f0 > flab(end)
    error( 'No extrapolation in frequency allowed.' );
  end
  
  %- Scanning speed is 750 m/s. Convert to an approximate angle.
  %
  R  = constants( 'EARTH_RADIUS' );
  zp = 600e3;
  %
  v = geomztan2za( R, zp, 20e3 ) - geomztan2za( R, zp, 20e3+750 );
  
  %- Select n "middle points" over relative zenith angle scanning range
  %
  n = 101;
  %
  dza = (v*tint/2) * linspace( -1+1/n, 1-1/n, n );
  
  %- Make frequency interpolation
  %
  r = interp1( flab, D', f0, 'linear' )';

  %- Include scanning by simply adding antenna pattern for each dza
  %
  p = 0;
  %
  for i = 1:n
    p = p + interp1( dza_in+dza(i), r, dza_in, 'linear', 'extrap' );
  end

  %- Normalise to max value
  %
  A = [ dza_in p/max(p) ];  

  % Create G  
  %
  G.name      = 'Antenna response function';
  G.gridnames = { 'Polarisation', 'Frequency', 'Zenith angle', 'Azimuth angle' };
  G.dataname  = 'Response';
  G.data      = zeros( 1, 1, length(dza_in), 1 );
  G.grids         = { {'1'}, f0, A(:,1), 0 };
  G.data(1,1,:,1) = A(:,2);
return
  
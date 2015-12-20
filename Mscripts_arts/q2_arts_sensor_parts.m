% Q2_ARTS_SENSOR_PARTS   Calculates the response of the sensor parts
%
%   If part is set to 'total', the complete sensor reponse matrix is calculated
%   (all done in ARTS), but this option is slow and should just be used for
%   reference. The sensor matrix is returned as R.H_TOTAL.
%
%   Otherwise, a compact version of the response matrix for the selected
%   part(s) is generated. These compact versions can expanded and combined by
%   *q2_arts_sensor*, to the full response matrix. 
%
%   These fields are added to R (for the option 'all'):
%    F_MIXER
%    H_ANTEN
%    H_BACKE
%    H_MIXER
%    R_EARTH
%    ZA_BORESI   
%    ZA_PENCIL
%    Z_ODIN
%
%   These fields of O are used
%     O.ABSLOOKUP_OPTION
%     O.DZA_GRID_EDGES
%     O.DZA_MAX_IN_CORE
%     O.FOLDER_ANTENNA
%     O.FOLDER_ABSLOOKUP
%     O.SIDEBAND_LEAKAGE
%     O.F_GRID_NFILL
%     O.SIDEBAND_LEAKAGE
%
% FORMAT R = q2_arts_sensor_parts(L1B,O,R[,part])
%
% OUT   R      Modified R structure.
% IN    L1B    L1B structure.
%       O      O structure.
%       R      R structure.
% OPT   part   What part(s) to calculate. Default is 'all'. This argument
%              matches directly C.PART of q2_artscfile_sensor, and other
%              options are: 'antenna', 'mixer', 'backend', 'all' and 'total'.

% 2015-05-29   Created by Patrick Eriksson.

function R = q2_arts_sensor_parts(L1B,O,R,part)
%
if nargin < 4, part = 'all'; end


% Some variables of general use
%
topfolder = q2_topfolder;
%
do_total  = strcmp( part, 'total' );
%
fmode  = L1B.FreqMode(1);
assert( fmode == O.FMODE );
%
% Determine f_lo and f_backend for middel point of scan
% Always used for mixer+sideband, while LO can vary for backend 
% Set by internal function, at end of file.
[f_lo,f_backend] = get_fmixerback( L1B, round(length(L1B.Altitude)/2) );


% The different parts are calculated in smallest possible block:
%   Antenna: calculated for a single frequency
%   Mixer and backend: calculated for a single beam
% 
% After this, the blocks are expanded and combined
  
  
%
% Antenna part
%
if any( strcmp( part, { 'antenna', 'all' } ) )  |  do_total
  
  C.PART = 'antenna';

  % Determine variables defining the viewing geometry
  [R.R_EARTH,R.Z_ODIN,R.ZA_BORESI] = q2_calc_1dviewgeom( L1B );

  % Pencil beam grid
  za_min      = min( R.ZA_BORESI );
  za_max      = max( R.ZA_BORESI );
  R.ZA_PENCIL = [ flip( za_min - O.DZA_GRID_EDGES ), ...
                 linspace( za_min, za_max, ...
                           1+ceil((za_max-za_min)/O.DZA_MAX_IN_CORE)),...
                 za_max + O.DZA_GRID_EDGES ]';
  xmlStore( fullfile( R.WORK_FOLDER, 'mblock_dlos_grid.xml' ), R.ZA_PENCIL, ...
                                                          'Matrix', 'binary' );

  % Find integration time for pre-calculated spectra
  antfiles = whichfiles( sprintf('antenna_fmode%02d*ms.xml',fmode), ...
                                                            O.FOLDER_ANTENNA );
  %
  tint0 = zeros( size( antfiles ) );
  %
  for i = 1 : length(tint0)
    tint0(i) = str2num( antfiles{i}(end-9:end-6) ) / 1e3;
  end
    
  % Assign an antenna pattern to each spectrum
  iant = zeros( length(L1B.IntTime), 1 );
  %
  for i = 1 : length(iant)
    [dt,iant(i)] = min( abs( L1B.IntTime(i) - tint0 ) );
    if dt > 0.05
      error( ...
      'Integration time found (%.0f ms) with no matching antenna pattern.', ...
                                                                      dt*1e3 );
    end
  end

  % Set of integration times
  iant_unique  = unique( iant );
  %
  % Set size of H for antenna part
  if do_total
    if length( iant_unique ) > 1
      error( 'Only a single integration time range is allowed for ''total''.' );
    end
  else
    R.H_ANTEN = sparse( length(R.ZA_BORESI), length(R.ZA_PENCIL) );
  end
  %
  % Loop antenna patterns and call arts
  for i = 1 : length( iant_unique );
    % 
    ind = find( iant == iant_unique(i) );
    %
    xmlStore( fullfile( R.WORK_FOLDER, 'antenna_dlos.xml' ), R.ZA_BORESI(ind), ...
                                                        'Matrix', 'binary' );
    C.ANTENNA_FILE = antfiles{ iant_unique(i) };
    %
    if ~do_total
      cfile  = q2_artscfile_sensor( C, R.WORK_FOLDER );
      status = arts( cfile );
      Hpart  = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
      %
      for j = 1 : length(ind)
        R.H_ANTEN(ind(j),:) = Hpart(j,:);
      end
    end
  end
end
%
clear Hpart t_int



%
% Mixer + sideband
%
if any( strcmp( part, { 'mixer', 'all' } ) )  |  do_total

  C.PART         = 'mixer';
  C.LO           = f_lo;
  C.F_GRID_NFILL = O.F_GRID_NFILL;

  % Get f_grid from absorption lookup table
  abs_lookup = xmlLoad( fullfile( O.FOLDER_ABSLOOKUP, ...
                                  O.ABSLOOKUP_OPTION, ...
                                  sprintf( 'abslookup_fmode%02d.xml', fmode ) ) );
  f_grid = abs_lookup.f_grid;
  xmlStore( fullfile( R.WORK_FOLDER, 'f_grid.xml' ), f_grid, 'Vector', 'binary' );
  clear abs_lookup
  %
  % Here we use a single angle
  if ~do_total
    xmlStore( fullfile( R.WORK_FOLDER, 'mblock_dlos_grid.xml' ), [0], ...
                                                          'Matrix', 'binary' );
  end
  %
  % Sideband response. So far just a flat function 
  G.name      = 'Sideband response function';
  G.gridnames = { 'Frequency' };
  % Add 1 kHz margin to avoid error due to rounding
  G.grids     = { symgrid( [ 1e9, min(abs(f_grid([1 end])-C.LO))-1e3 ] ) };
  G.dataname  = 'Response';
  %
  rs = O.SIDEBAND_LEAKAGE;
  rm = 1 - rs;
  %
  if f_backend(1) > C.LO
    G.data      = [ rs rs rm rm ];
  else
    G.data      = [ rm rm rs rs ];
  end
  C.SIDEBAND_FILE = fullfile( R.WORK_FOLDER, 'sideband_response.xml' );
  xmlStore( C.SIDEBAND_FILE, G, 'GriddedField1', 'binary' );
  %
  if ~do_total
    cfile     = q2_artscfile_sensor( C, R.WORK_FOLDER );
    status    = arts( cfile );
    R.H_MIXER = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
    R.F_MIXER = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response_f.xml' ) );
  end
end


%
% Backend
%
if any( strcmp( part, { 'backend', 'all' } ) )  |  do_total

  if do_total & ~O.F_BACKEND_COMMON
    error( 'O.F_BACKEND_COMMON must be true for ''total'' option.' );
  end   
  
  C.PART = 'backend';
  
  % f_grid is here set to R.F_MIXER
  if ~do_total  
    xmlStore( fullfile( R.WORK_FOLDER, 'f_grid.xml' ), R.F_MIXER, ...
                                                        'Vector',  'binary' );
  end
  
  % Here we use a single angle
  if ~do_total
    xmlStore( fullfile( R.WORK_FOLDER, 'mblock_dlos_grid.xml' ), [0], ...
                                                         'Matrix', 'binary' );
  end

  % Backend response file
  C.BACKEND_FILE = fullfile( O.FOLDER_BACKEND, ...
                              sprintf( 'backend_df%04.0fkHz', ...
                              floor(diff(f_backend([1 2]))/1e3) ) );
  if L1B.Hanning(1) == true
    C.BACKEND_FILE = sprintf( '%s_withHan.xml', C.BACKEND_FILE );
  else
    C.BACKEND_FILE = sprintf( '%s_noHan.xml', C.BACKEND_FILE );
  end

  % A common set of backend frequencies assumed
  if O.F_BACKEND_COMMON
    % Channel positions, in IF
    xmlStore( fullfile( R.WORK_FOLDER, 'f_backend.xml' ), ...
                              abs( f_backend - f_lo ), 'Vector', 'binary' );
    if ~do_total
      cfile    = q2_artscfile_sensor( C, R.WORK_FOLDER );
      status   = arts( cfile );
      R.H_BACKE = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
    end
    
  % Backend frequencies vary (or rather non-fixed LO)
  else
    for i = 1 : length(L1B.Altitude)
      f_lo = get_fmixerback( L1B, i );
      xmlStore( fullfile( R.WORK_FOLDER, 'f_backend.xml' ), ...
                              abs( f_backend - f_lo ), 'Vector', 'binary' );
      if i == 1
        cfile        = q2_artscfile_sensor( C, R.WORK_FOLDER );
      end
      status       = arts( cfile );
      R.H_BACKE{i} = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
    end
  end
  
end


%
% Or do total
%
if do_total
  %
  C.PART = 'total';
  %
  cfile     = q2_artscfile_sensor( C, R.WORK_FOLDER );
  status    = arts( cfile );
  R.H_TOTAL = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
end

return



% Frequencies picked from spectrum with index *itan*
% Given LO is "doppler corrected" by scaling difference between RestFreq and SkyFreq
function [f_lo,f_backend] = get_fmixerback( L1B, itan )
  f_rest     = L1B.RestFreq(itan );
  lo_rest    = L1B.LOFreq(itan);
  df_doppler = f_rest - L1B.SkyFreq(itan);
  f_lo       = lo_rest + df_doppler * lo_rest / f_rest; 
  f_backend  = L1B.Frequency(:,itan);
return
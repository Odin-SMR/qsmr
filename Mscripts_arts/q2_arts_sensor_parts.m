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
%   Note that 'backend' here is short-hand for mixer + sideband and
%   spectrometer. 
%
%   These fields are added to R (for the option 'all'):
%    F_GRID
%    H_ANTEN
%    H_BACKE
%    LO
%    R_EARTH
%    ZA_BORESI   
%    ZA_PENCIL
%    Z_ODIN
%
%   These fields of O are used
%     Q.DZA_GRID_EDGES
%     Q.DZA_MAX_IN_CORE
%     Q.F_GRID_NFILL
%     Q.FOLDER_ANTENNA
%     Q.FOLDER_ABSLOOKUP
%     Q.FOLDER_BACKEND
%     Q.LO_COMMON
%     Q.LO_ZREF
%     Q.SIDEBAND_LEAKAGE
%
% FORMAT R = q2_arts_sensor_parts(L1B,Q,R[,part])
%
% OUT   R      Modified R structure.
% IN    L1B    L1B structure.
%       Q      Q structure.
%       R      R structure.
% OPT   part   What part(s) to calculate. Default is 'all'. This argument
%              matches directly C.PART of q2_artscfile_sensor, and other
%              options are: 'antenna', 'backend', 'all' and 'total'.

% 2015-05-29   Created by Patrick Eriksson.

function R = q2_arts_sensor_parts(L1B,Q,R,part)
%
if nargin < 4, part = 'all'; end


% Some variables of general use
%
topfolder = q2_topfolder;
%
do_total  = strcmp( part, 'total' );
%
fmode  = L1B.FreqMode(1);
assert( fmode == Q.FREQMODE );


  
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
  R.ZA_PENCIL = [ flip( za_min - Q.DZA_GRID_EDGES ), ...
                 linspace( za_min, za_max, ...
                           1+ceil((za_max-za_min)/Q.DZA_MAX_IN_CORE)),...
                 za_max + Q.DZA_GRID_EDGES ]';
  xmlStore( fullfile( R.workfolder, 'mblock_dlos_grid.xml' ), R.ZA_PENCIL, ...
                                                          'Matrix', 'binary' );

  % Find integration time for pre-calculated spectra
  antfiles = whichfiles( sprintf('antenna_fmode%02d*ms.xml',fmode), ...
                                                            Q.FOLDER_ANTENNA );
  %
  if isempty(antfiles)
    error( 'Could not find any antenna files. Q.FOLDER_ANTENNA correct?' );
  end
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
    if dt > 0.1
      error( ...
      'Integration time found (%.0f ms) with no matching antenna pattern.', ...
                                                                L1B.IntTime(i)*1e3 );
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
    xmlStore( fullfile( R.workfolder, 'antenna_dlos.xml' ), R.ZA_BORESI(ind), ...
                                                        'Matrix', 'binary' );
    C.ANTENNA_FILE = antfiles{ iant_unique(i) };
    %
    if ~do_total
      cfile  = q2_artscfile_sensor( C, R.workfolder );
      result = q2_arts( Q, ['-r000 -b ',fullfile(R.workfolder,'out'),' ',cfile] );
      Hpart  = xmlLoad( fullfile( R.workfolder, 'sensor_response.xml' ) );
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
% Mixer + sideband + backend
%
if any( strcmp( part, { 'backend', 'all' } ) )  |  do_total

  if do_total & ~Q.LO_COMMON
    error( 'Q.LO_COMMON must be true for ''total'' option.' );
  end   

  % Get f_grid from absorption lookup table
  abs_lookup = xmlLoad( fullfile( Q.FOLDER_ABSLOOKUP, ...
                                  sprintf( 'abslookup_fmode%02d.xml', fmode ) ) );
  R.F_GRID = abs_lookup.f_grid;
  xmlStore( fullfile( R.workfolder, 'f_grid.xml' ), R.F_GRID, 'Vector', 'binary' );
  clear abs_lookup
  
  % Here we use a single angle
  if ~do_total
    xmlStore( fullfile( R.workfolder, 'mblock_dlos_grid.xml' ), [0], ...
                                                         'Matrix', 'binary' );
  end

  % Backend response file
  if isempty(Q.BACKEND_FILE)
    C.BACKEND_FILE = fullfile( Q.FOLDER_BACKEND, ...
                               sprintf( 'backend_df%04.0fkHz', ...
                               floor(L1B.FreqRes(1)/1e3) ) );
    if L1B.Apodization(1) == true
      C.BACKEND_FILE = sprintf( '%s_withHan.xml', C.BACKEND_FILE );
    else
      C.BACKEND_FILE = sprintf( '%s_noHan.xml', C.BACKEND_FILE );
    end
  
  else
    C.BACKEND_FILE = fullfile( Q.FOLDER_BACKEND, Q.BACKEND_FILE );
  end

  
  % Set number of lo-s to consider
  %
  if Q.LO_COMMON
    nlo = 1;
  else
    nlo = length(L1B.Altitude);
  end
  
  % Loop lo-s
  %
  R.LO = zeros( length(L1B.Altitude), 1 );
  %
  for i = 1 : nlo
      
    % Set LO and channel frequencies
    %
    if nlo == 1
      [~,iref]  = min( abs( L1B.Altitude - Q.LO_ZREF ) );
      f_backend = l1b_frequency( L1B, iref );
      R.LO(:)   = L1B.Frequency.LOFreq( iref );
    else
      f_backend = l1b_frequency( L1B, i );
      R.LO(i)   = L1B.Frequency.LOFreq( i );
    end
          
    % Run ARTS for "mixer"
    %--------------------------------------------------------------------------------
    %
    C.PART         = 'mixer';
    C.LO           = R.LO(i);
    C.F_GRID_NFILL = Q.F_GRID_NFILL;
    %
    G.name      = 'Sideband response function';
    G.gridnames = { 'Frequency' };
    G.dataname  = 'Response';
    %
    % Sideband filter defined as a single scalar:
    if isnumeric( Q.SIDEBAND_LEAKAGE )  &  isscalar( Q.SIDEBAND_LEAKAGE )
      % Create a 4-point grid. Add 10 kHz margin to avoid error due to rounding
      G.grids     = { symgrid( [ 1e9, min(abs(R.F_GRID([1 end])-R.LO(i)))-10e3 ] ) };
      %
      if f_backend(1) > R.LO(i)
        G.data      = [ Q.SIDEBAND_LEAKAGE*[1 1] (1-Q.SIDEBAND_LEAKAGE)*[1 1] ];
      else
        G.data      = [ (1-Q.SIDEBAND_LEAKAGE)*[1 1] Q.SIDEBAND_LEAKAGE*[1 1] ];
      end

    % Sideband filter follows "standard model"
    elseif ischar( Q.SIDEBAND_LEAKAGE )  &  strcmp( Q.SIDEBAND_LEAKAGE, 'model' )
      % Create a coarse frequency grid. Add 10 kHz margin to avoid error due to rounding
      G.grids = { symgrid( linspace( 3e9, ...
                                     min(abs(R.F_GRID([1 end])-R.LO(i)))-10e3,...
                                     31 ) ) }; 
      % Get response by dedicated function (that wants RF and returns leakage)
      G.data = 1 - sband_from_l1b( L1B, R.LO(i) + G.grids{1} );

    else
      error( 'Unknown format found for Q.SIDEBAND_LEAKAGE.' );
    end
    C.SIDEBAND_FILE = fullfile( R.workfolder, 'sideband_response.xml' );
    xmlStore( C.SIDEBAND_FILE, G, 'GriddedField1', 'binary' );
    %
    if ~do_total
      cfile  = q2_artscfile_sensor( C, R.workfolder );
      result = q2_arts( Q, ['-r000 -b ',fullfile(R.workfolder,'out'),' ',cfile] );
      H1     = xmlLoad( fullfile( R.workfolder, 'sensor_response.xml' ) );
    end

    
    % Run ARTS for "backend" and combine H-matrices
    %--------------------------------------------------------------------------------
    %
    C.PART = 'backend';
    %
    % f_grid is taken as f_mixer saved in mixer part, an IF-grid
    %
    % Channel positions, in IF
    xmlStore( fullfile( R.workfolder, 'f_backend.xml' ), ...
                              abs( f_backend - R.LO(i) ), 'Vector', 'binary' );
    if ~do_total
      cfile  = q2_artscfile_sensor( C, R.workfolder );
      result = q2_arts( Q, ['-r000 -b ',fullfile(R.workfolder,'out'),' ',cfile] );
      H2     = xmlLoad( fullfile( R.workfolder, 'sensor_response.xml' ) );
      %
      R.H_BACKE{i} = H2 * H1;
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
  cfile     = q2_artscfile_sensor( C, R.workfolder );
  result    = q2_arts( Q, ['-r000 -b ',fullfile(R.workfolder,'out'),' ',cfile] );
  R.H_TOTAL = xmlLoad( fullfile( R.workfolder, 'sensor_response.xml' ) );
end

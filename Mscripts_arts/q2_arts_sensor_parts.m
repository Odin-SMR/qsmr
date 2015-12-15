% Q2_ARTS_SENSOR_PARTS   Calculates the response of the sensor parts
%
%   If part is set to 'total', the complete sensor reposne matrix is calculated
%   (all done in ARTS), but this option is slow and should just be used for
%   reference. The sensor matrix is returned as R.H_TOTAL.
%
%   Otherwise, a compact version of the response matrix for the selected
%   part(s) is generated. These compact versions can expanded and combined by
%   *q2_arts_sensor*, to the full response matrix. 
%
%   These fields are added to R (for the option 'all'):
%    F_MIXER
%    ZA_BORESI   
%    ZA_PENCIL
%    H_ANTEN
%    H_BACKE
%    H_MIXER
%
%   Combined information in O and L1B are used:
%     O.ABSLOOKUP_OPTION
%     O.DZA_GRID_EDGES
%     O.DZA_MAX_IN_CORE
%     O.FBAND
%     O.F_BACKEND_NOMINAL
%     O.F_LO_NOMINAL
%     -
%     L1B.HANNING
%     L1B.T_INT
%     L1B.Z_PLAT
%     L1B.Z_TAN
%
% FORMAT R = q2_arts_sensor_parts(O,R,L1B[,part])
%
% OUT   R      Modified R structure.
% IN    O      O structure.
%       R      R structure.
%       L1B    ????
% OPT   part   What part(s) to calculate. Default is 'all'. This argument
%              matches directly C.PART of q2_artscfile_sensor, and other
%              options are: 'antenna', 'mixer', 'backend', 'all' and 'total'.

% 2015-05-29   Created by Patrick Eriksson.

function R = q2_arts_sensor_parts(O,R,L1B,part)
%
if nargin < 4, part = 'all'; end


topfolder = q2_topfolder;

do_total  = strcmp( part, 'total' );


% The different parts are calculated in smallest possible block:
%   Antenna: calculated for a singel frequency
%   Mixer and backend: calculated for a single beam
% 
% After this, the blocks are expanded and combined
  
  
%
% Antenna part
%
if any( strcmp( part, { 'antenna', 'all' } ) )  |  do_total
  
  C.PART = 'antenna';

  % Zenith angle grids:
  R.ZA_BORESI = vec2col( geomztan2za( constants('EARTH_RADIUS'), L1B.Z_PLAT, ...
                                                                 L1B.Z_TAN ) );
  za_min      = min( R.ZA_BORESI );
  za_max      = max( R.ZA_BORESI );
  R.ZA_PENCIL = [ flip( za_min - O.DZA_GRID_EDGES ), ...
                 linspace( za_min, za_max, ...
                           1+ceil((za_max-za_min)/O.DZA_MAX_IN_CORE)),...
                 za_max + O.DZA_GRID_EDGES ]';
  xmlStore( fullfile( R.WORK_FOLDER, 'mblock_dlos_grid.xml' ), R.ZA_PENCIL, ...
                                                          'Matrix', 'binary' );

  %
  % Set of integration times
  t_int  = unique( L1B.T_INT );
  %
  % Set size of H for antenna part
  if do_total
    if length( t_int ) > 1
      error( 'Only a single integration time is allowed for ''total''.' );
    end
  else
    R.H_ANTEN = sparse( length(R.ZA_BORESI), length(R.ZA_PENCIL) );
  end
  %
  % Loop integration times and call arts
  for i = 1 : length( t_int );
    % 
    ind = find( L1B.T_INT == t_int(i) );
    %
    xmlStore( fullfile( R.WORK_FOLDER, 'antenna_dlos.xml' ), R.ZA_BORESI(ind), ...
                                                        'Matrix', 'binary' );
    C.ANTENNA_FILE = fullfile( O.FOLDER_ANTENNA, ...
                                sprintf( 'antenna_fband%d_tint%04.0fms.xml', ...
                                O.FBAND, t_int(i)*1e3 ) );
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
  C.LO           = O.F_LO_NOMINAL;
  C.F_GRID_NFILL = O.F_GRID_NFILL;

  % Get f_grid from absorption lookup table
  abs_lookup = xmlLoad( fullfile( O.FOLDER_ABSLOOKUP, ...
                                  O.ABSLOOKUP_OPTION, ...
                                  sprintf( 'abslookup_fband%d.xml', O.FBAND ) ) );
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
  G.grids     = { [f_grid(1)-C.LO -1e9 1e9 f_grid(end)-C.LO] };
  G.dataname  = 'Response';
  %
  rs = O.SIDEBAND_LEAKAGE;
  rm = 1 - rs;
  %
  if O.F_BACKEND_NOMINAL(1) > C.LO
    G.data      = [ rs rs rm rm ];
  else
    G.data      = [ rm rm rs rs ];
  end
  C.SIDEBAND_FILE = fullfile( R.WORK_FOLDER, 'sideband_response.xml' );
  xmlStore( C.SIDEBAND_FILE, G, 'GriddedField1' );
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
  
  % Channel positions, in IF
  xmlStore( fullfile( R.WORK_FOLDER, 'f_backend.xml' ), ...
                              abs( O.F_BACKEND_NOMINAL - O.F_LO_NOMINAL ), ... 
                                                         'Vector', 'binary' );
  % Backend response
  C.BACKEND_FILE = fullfile( O.FOLDER_BACKEND, ...
                              sprintf( 'backend_df%04.0fkHz', ...
                              floor(diff(O.F_BACKEND_NOMINAL([1 2]))/1e3) ) );
  if L1B.HANNING == true
    C.BACKEND_FILE = sprintf( '%s_withHan.xml', C.BACKEND_FILE );
  else
    C.BACKEND_FILE = sprintf( '%s_noHan.xml', C.BACKEND_FILE );
  end
  %
  if ~do_total
    cfile    = q2_artscfile_sensor( C, R.WORK_FOLDER );
    status   = arts( cfile );
    R.H_BACKE = xmlLoad( fullfile( R.WORK_FOLDER, 'sensor_response.xml' ) );
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
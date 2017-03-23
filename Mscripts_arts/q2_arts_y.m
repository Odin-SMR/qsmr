% Q2_ARTS_Y   Stand-alone calculation of spectra
%
%   The function calculates spectra, with or without including sensor
%   responses.
%
%   Defualt is to use pre-calculated absorption tables. 
%
%   "On-the-fly" absorption can be triggered by setting *use_abstable* to
%   false, but this is only allowed with *do_sensor* set to false. The
%   frequency grid is then set to channel centre positions of the first
%   tangent altitude. The pressure grid is taken from Q.P_GRID. The reading 
%   of HITRAN is restricted to +-10 GHz around the frequency band.   
%
% FORMAT [Y,F] = q2_arts_y(L1B,ATM,Q[,do_sensor,use_abstable])
%
% OUT   Y              Spectra, as a matrix.
%       F              Frequencies for each value in Y.
% IN    L1B            L1B structure.
%       ATM            Structure of ATM-type, see *q2_get_atm*.
%       Q              Q structure.
% OPT   do_sensor      Flag to include sensor or not. Default is true.
%       use_abstable   Flag to use precalculated absorption table or not. 
%                      Default is true.

% 2015-05-29   Created by Patrick Eriksson.

function [Y,F] = q2_arts_y(L1B,ATM,Q,varargin)
%
[do_sensor,use_abstable] = optargs( varargin, { true, true } );
%
if ~use_abstable & do_sensor
  error( 'On-the-fly absorptiuon can only be used with do_sensor=false.' );
end


%
% Frequency mode 
%
fmode  = L1B.FreqMode(1);
assert( fmode == Q.FREQMODE );


%
% Set/create work folder
%
[R.workfolder,rm_wfolder] = q2_create_workfolder( Q );
%
if rm_wfolder
  cu = onCleanup( @()q2_delete_workfolder( R.workfolder ) );
end
  
  
%
% Set atmospheric data and geo-pos
%
xmlStore( fullfile( R.workfolder, 'p_grid.xml' ), ATM.P, ...
                                                         'Vector', 'binary' );
xmlStore( fullfile( R.workfolder, 't_field.xml' ), ATM.T, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.workfolder, 'z_field.xml' ), ATM.Z, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.workfolder, 'vmr_field.xml' ), ATM.VMR, ...
                                                        'Tensor4', 'binary' );
xmlStore( fullfile( R.workfolder, 'lat_true.xml' ), ...
                 L1B.Latitude(round(length(L1B.Latitude)/2)), ...
                                                        'Vector', 'binary' );
xmlStore( fullfile( R.workfolder, 'lon_true.xml' ), ...
                 L1B.Longitude(round(length(L1B.Longitude)/2)), ...
                                                        'Vector', 'binary' );


%
% Sensor 
%
if do_sensor
  R  = q2_arts_sensor_parts( L1B, Q, R );
  R  = q2_arts_sensor( R );
  za = R.ZA_PENCIL;
else
  [R.R_EARTH,R.Z_ODIN,za] = q2_calc_1dviewgeom( L1B );
end
%
xmlStore( fullfile( R.workfolder, 'sensor_pos.xml' ), ...
                             repmat( R.Z_ODIN, size(za) ), 'Matrix', 'binary' );
xmlStore( fullfile( R.workfolder, 'sensor_los.xml' ), za, 'Matrix', 'binary' );


%
% Set structure defining cfile
%
C.REFRACTION_DO      = Q.REFRACTION_DO;
C.PPATH_LMAX         = Q.PPATH_LMAX;
C.PPATH_LRAYTRACE    = Q.PPATH_LRAYTRACE;
C.SPECIES            = arts_tgs_cnvrt( Q.ABS_SPECIES );
C.R_EARTH            = R.R_EARTH;
C.JACOBIAN_DO        = false;


%
% Absorption settings
%
if use_abstable
    %
  C.ABSORPTION         = 'LoadTable';
  C.ABS_LOOKUP_TABLE   = fullfile( Q.FOLDER_ABSLOOKUP, ...
                                    sprintf( 'abslookup_fmode%02d.xml', fmode ) );
  C.ABS_P_INTERP_ORDER = Q.ABS_P_INTERP_ORDER;
  C.ABS_T_INTERP_ORDER = Q.ABS_T_INTERP_ORDER;
  %
else
  %
  C.ABSORPTION      = 'OnTheFly';
  P                 = p_stnd;
  f                 = l1b_frequency( L1B, 1 );
  C.PARTITION_FILE  = P.PARTITION_FILE;
  C.CONTINUA_FILE   = P.CONTINUA_FILE;
  C.SPECTRO_FILE    = P.SPECTRO_FILE;
  C.SPECTRO_FMIN    = min(f) - 10e9;
  C.SPECTRO_FMAX    = max(f) + 10e9;
  %
  xmlStore( fullfile( R.workfolder, 'f_grid.xml' ), f, ...
                                                        'Vector', 'binary' );
  xmlStore( fullfile( R.workfolder, 'p_grid.xml' ), Q.P_GRID, ...
                                                        'Vector', 'binary' );  
  %
end


%
% Create cfile, calculate and load spectra
%
cfile  = q2_artscfile_full( C, R.workfolder );
result = q2_arts( Q, ['-r000 ',cfile] );
%
y      = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
%
if do_sensor
  y = R.H_TOTAL * y;
  Y = reshape( y, size(L1B.Spectrum) );
  if nargout > 1
    F = l1b_frequency( L1B );
  end
else  
  Y = reshape( y, length(y)/length(za), length(za) );
  if nargout > 1
    if use_abstable
      A = xmlLoad( C.ABS_LOOKUP_TABLE );
      f = A.f_grid;
    end
    %
    F = repmat( vec2col(f), 1, length(za), 1 );
    %
  end
end


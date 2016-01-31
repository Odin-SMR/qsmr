% Q2_ARTS_Y   Stand-alone calculation of spectra
%
%   The function calculates spectra, with or without including sensor
%   responses, based on a pre-calculated absorption lookup table.
%
% FORMAT [f,Y] = q2_arts_y(L1B,ATM,Q[,do_sensor])
%
% OUT   f           Frequency grid for spectra.
%       Y           Spectra, as a matrix.
% IN    L1B         L1B structure.
%       ATM         Structure of ATM-type, see *q2_get_atm*.
%       Q           Q structure.
% OPT   do_sensor   Flag to include sensor or not. Default is true.

% 2015-05-29   Created by Patrick Eriksson.

function Y = q2_arts_y(L1B,ATM,Q,varargin)
%
[do_sensor] = optargs( varargin, { true } );
  

%
% Frequency mode 
%
fmode  = L1B.FreqMode(1);
assert( fmode == Q.FMODE );


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
C.ABSORPTION         = 'LoadTable';
C.ABS_LOOKUP_TABLE   = fullfile( Q.FOLDER_ABSLOOKUP, Q.ABSLOOKUP_OPTION, ...
                                  sprintf( 'abslookup_fmode%02d.xml', fmode ) );
C.ABS_P_INTERP_ORDER = Q.ABS_P_INTERP_ORDER;
C.ABS_T_INTERP_ORDER = Q.ABS_T_INTERP_ORDER;
C.PPATH_LMAX         = Q.PPATH_LMAX;
C.PPATH_LRAYTRACE    = Q.PPATH_LRAYTRACE;
C.SPECIES            = arts_tgs_cnvrt( Q.ABS_SPECIES );
C.R_EARTH            = R.R_EARTH;
C.JACOBIAN_DO        = false;


%
% Create cfile, calculate and load spectra
%
cfile  = q2_artscfile_full( C, R.workfolder );
result = q2_arts( ['-r000 ',cfile] );
%
y      = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
%
if do_sensor
  y = R.H_TOTAL * y;
  Y = reshape( y, size(L1B.Spectrum) );
else
  A = xmlLoad( C.ABSORPTION );
  f = A.f_grid;
  Y = reshape( y, length(f), length(za) );
end


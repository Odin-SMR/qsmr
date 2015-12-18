% Q2_ARTS_Y   Stand-alone calculation of spectra
%
%   The function calculates spectra, with or without including sensor
%   responses, based on a pre-calculated absorption lookup table.
%
% FORMAT [f,Y] = q2_arts_y(O,R,L1B,ATM[,do_sensor])
%
% OUT   f           Frequency grid for spectra.
%       Y           Spectra, as a matrix.
% IN    O           O structure.
%       R           R structure.
%       L1B         L1B structure.
%       ATM         Structure of ATM-type, see *q2_get_atm*.
% OPT   do_sensor   Flag to include sensor or not. Default is true.

% 2015-05-29   Created by Patrick Eriksson.

function Y = q2_arts_y(L1B,ATM,O,R,varargin)
%
[do_sensor] = optargs( varargin, { true } );
  

%
% Absorption lookup table
%
topfolder = q2_topfolder;
%
abslookupfile = fullfile( O.FOLDER_ABSLOOKUP, O.ABSLOOKUP_OPTION, ...
                          sprintf( 'abslookup_fband%d.xml', O.FBAND ) );


%
% Set atmospheric data
%
xmlStore( fullfile( R.WORK_FOLDER, 'p_grid.xml' ), ATM.P, ...
                                                         'Vector', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 't_field.xml' ), ATM.T, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'z_field.xml' ), ATM.Z, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'vmr_field.xml' ), ATM.VMR, ...
                                                        'Tensor4', 'binary' );


%
% Sensor 
%
if do_sensor
  R  = q2_arts_sensor_parts( L1B, O, R );
  R  = q2_arts_sensor( R );
  za = R.ZA_PENCIL;
else
  [R.R_EARTH,R.Z_ODIN,za] = q2_calc_1dviewgeom( L1B );
end
%
xmlStore( fullfile( R.WORK_FOLDER, 'sensor_pos.xml' ), ...
                             repmat( R.Z_ODIN, size(za) ), 'Matrix', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'sensor_los.xml' ), za, 'Matrix', 'binary' );


%
% Set structure defining cfile
%
C.ABSORPTION         = 'LoadTable';
C.ABS_LOOKUP_TABLE   = abslookupfile;
C.ABS_P_INTERP_ORDER = O.ABS_P_INTERP_ORDER;
C.ABS_T_INTERP_ORDER = O.ABS_T_INTERP_ORDER;
C.PPATH_LMAX         = O.PPATH_LMAX;
C.PPATH_LRAYTRACE    = O.PPATH_LRAYTRACE;
C.SPECIES            = arts_tgs_cnvrt( O.ABS_SPECIES );
C.R_EARTH            = R.R_EARTH;


%
% Create cfile, calculate and load spectra
%
cfile  = q2_artscfile_full( C, R.WORK_FOLDER );
status = arts( cfile );
%
y      = xmlLoad( fullfile( R.WORK_FOLDER, 'y.xml' ) );
%
if do_sensor
  f = O.F_BACKEND_NOMINAL;
  y = R.H_TOTAL * y;
  Y = reshape( y, length(f), length(R.ZA_BORESI) );
else
  A = xmlLoad( abslookupfile );
  f = A.f_grid;
  Y = reshape( y, length(f), length(za) );
end

function L2 = q2_inv(LOG,L1B,Q,varargin)  

  
%
% Frequency mode 
%
fmode  = L1B.FreqMode(1);
assert( fmode == Q.FMODE );


%
% Set/create work folder
%
[R.WORK_FOLDER,rm_wfolder] = q2_create_workfolder( Q );
%
if rm_wfolder
  cu = onCleanup( @()q2_delete_workfolder( R.WORK_FOLDER ) );
end
  
  
%
% Get and set initial atmospheric data
%
R.ATM = q2_get_atm( LOG, Q );
%
xmlStore( fullfile( R.WORK_FOLDER, 'p_grid.xml' ), R.ATM.P, ...
                                                         'Vector', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 't_field.xml' ), R.ATM.T, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'z_field.xml' ), R.ATM.Z, ...
                                                        'Tensor3', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'vmr_field.xml' ), R.ATM.VMR, ...
                                                        'Tensor4', 'binary' );


%
% Initial sensor responses 
%
R  = q2_arts_sensor_parts( L1B, Q, R );
R  = q2_arts_sensor( R );
za = R.ZA_PENCIL;
%
xmlStore( fullfile( R.WORK_FOLDER, 'sensor_pos.xml' ), ...
                             repmat( R.Z_ODIN, size(za) ), 'Matrix', 'binary' );
xmlStore( fullfile( R.WORK_FOLDER, 'sensor_los.xml' ), za, 'Matrix', 'binary' );


%
% Create cfiles to use, with and without Jacobian calculation
%
jac_cfile = fullfile( R.WORK_FOLDER, 'jacobian.arts' );
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
%
C.JACOBIAN_DO        = false;
R.cfile_y            = q2_artscfile_full( C, R.WORK_FOLDER, 'cfile_y.arts' );
%
C.JACOBIAN_DO        = true;
C.JACOBIAN_FILE      = jac_cfile;
R.cfile_yj           = q2_artscfile_full( C, R.WORK_FOLDER, 'cfile_yj.arts' );
%
clear C


%
% Set-up Jacobian (by sub-function found below)
%
R = subfun4jac( Q, R, jac_cfile );
  

%
% Create Sx and its inverse
%
[Sx,Sxinv] = subfun4sx( Q, R );


%
% Create Se and its inverse
%
[Se,Seinv] = subfun4se( L1B );


%
% Define O
%
O = oem;
%
[O.A,O.cost,O.e,O.ga] = deal( true );
%
O.stop_dx             = Q.STOP_DX;
O.ga_start            = Q.GA_START;
O.ga_factor_not_ok    = Q.GA_FACTOR_NOT_OK;
O.ga_factor_ok        = Q.GA_FACTOR_OK;
O.ga_max              = Q.GA_MAX;


%
% Run OEM
%
[X,R] = oem( O, Q, R, @q2_artsoem, Sx, Se, Sxinv, Seinv, xa, L1B.Spectrum(:) );


%
% Create L2
%
L2 = X;




%---------------------------------------------------------------------------
%--- Jacobian
%---------------------------------------------------------------------------

function R = subfun4jac( Q, R, jac_cfile )
  
% Open and init jacobian cfile
%
fid = fileopen( jac_cfile, 'w' );
cu = onCleanup( @()fileclose( fid ) );
%
fprintf( fid, 'Arts2{\n' );
fprintf( fid, ''jacobianInit' );


% Loop retrieval quantities



% Close jacobian cfile
fprintf( fid, ''jacobianClose' );
fprintf( fid, '\n}\n' );


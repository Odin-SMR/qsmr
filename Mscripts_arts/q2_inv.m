function L2 = q2_inv(LOG,L1B,Q)  

  
%
% Asserts
%
assert( L1B.FreqMode(1) == Q.FMODE );


%
% Set/create work folder
%
[R.WORK_FOLDER,rm_wfolder] = q2_create_workfolder( Q );
%
if rm_wfolder
  cu = onCleanup( @()q2_delete_workfolder( R.WORK_FOLDER ) );
  clear rm_workfolder
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
% Set up things around each retrieval quantity
%
[xa,Q,R] = subfun4retqs( Q, R );
  

%
% Create full Sx and its inverse (using Atmlab)
%
[Sx,Sxinv] = arts_sx( Q, R );


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
[X,R] = oem( O, Q, R, @q2_oemiter, Sx, Se, Sxinv, Seinv, xa, L1B.Spectrum(:) );


%
% Create L2
%
L2 = X;

return




%---------------------------------------------------------------------------
%--- Retrieval quantities set-up
%---------------------------------------------------------------------------

function[xa,Q,R] = subfun4retqs( Q, R )

  %
  % Create cfiles to use, with and without Jacobian calculation
  %
  R.jac_cfile = fullfile( R.WORK_FOLDER, 'jacobian.arts' );
  %
  C.ABSORPTION         = 'LoadTable';
  C.ABS_LOOKUP_TABLE   = fullfile( Q.FOLDER_ABSLOOKUP, Q.ABSLOOKUP_OPTION, ...
                                    sprintf( 'abslookup_fmode%02d.xml', Q.FMODE ) );
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
  C.JACOBIAN_FILE      = R.jac_cfile;
  R.cfile_yj           = q2_artscfile_full( C, R.WORK_FOLDER, 'cfile_yj.arts' );
  %
  clear C 

  
  % Init main bookkeeping variables
  R.ji    = [];    
  R.jq    = [];
  lx      = 0;

  % Init variable defining jac_file
  T{1} = 'Arts2{';
  T{2} = 'VectorCreate( empty_vector )';
  T{3} = 'VectorSet( empty_vector, [] )';
    
  % Abs specices
  %
  R.i_asj = find( [ Q.ABS_SPECIES.RETRIEVE ] );
  %
  for i = R.i_asj
    %
    iq               = length(R.jq) + 1;
    np               = length( Q.ABS_SPECIES(i).GRID );
    R.jq{iq}.maintag = 'Absorption species';
    R.jq{iq}.mode    = 'rel';
    R.ji{iq}{1}      = lx + 1;
    R.ji{iq}{2}      = lx + np;
    lx               = lx + np;
    %
    vector_name      = sprintf( 'retgrid%d', iq );
    file_name        = fullfile( R.WORK_FOLDER, [vector_name,'.xml'] );
    xmlStore( file_name, Q.ABS_SPECIES(iq).GRID, 'Vector' );
    %
    T{end+1} = sprintf( 'ReadXML( %s, "%s" )', vector_name, file_name );
    T{end+1} = sprintf( 'jacobianAddAbsSpecies( species = %s,', ...
                                               arts_tgs_cnvrt(Q.ABS_SPECIES(i).TAG) );
    T{end+1} = sprintf( '   g1 = %s, g2 = empty_vector, g3 = empty_vector,', ...
                                                                        vector_name );
    T{end+1} = '   unit = "rel" )';
    %
    Q.ABS_SPECIES(i).SX = covmat1d_from_cfun( Q.ABS_SPECIES(i).GRID, ...
                                              Q.ABS_SPECIES(i).UNC_REL, ...
                                                           'lin', 0.3, 0.00, @log10 );
  end

  
  % Create file setting up the jacobian
  %
  T{end+1} = '}';
  strs2file( R.jac_cfile, T );    

  % Create xa
  %
  xa = zeros( lx, 1 );
  %
  for i = 1 : length(R.jq)

    ind = R.ji{i}{1} : R.ji{i}{2};
    
    switch R.jq{i}.maintag
     case 'Absorption species'
      if strcmp( R.jq{i}.mode, 'rel' )
        xa(ind) = 1;
      end
    end   
  end
  
return



%---------------------------------------------------------------------------
%--- Se
%---------------------------------------------------------------------------

function [Se,Seinv] = subfun4se( L1B )

  % Calculate covariance matrix for one spectrum and unit variance, and its
  % inverse
  f    = L1B.Frequency(:,1);
  nf   = length( f );
  df   = L1B.FreqRes(1);
  % A correlation length of 1.6*df gives a rough fit of emperically derived
  % correlations. 1.6_df gives 0.6 and 0.2 to two closest channels.
  S    = covmat1d_from_cfun( f, 1, 'lin', 1.6*df );
  Sinv = S \ speye(nf);

  % Compile complete matrices
  %
  [i1,j1,s1] = find( S );
  [i2,j2,s2] = find( Sinv );
  %
  n1   = length( i1 );
  n2   = length( i2 );
  ntan = length( L1B.EffTime );
  %
  [ii1,jj1,ss1] = deal( zeros( n1*ntan, 1 ) );
  [ii2,jj2,ss2] = deal( zeros( n2*ntan, 1 ) );
  [nn1,nn2]     = deal( 0 );
  %
  for t = 1 : ntan
    %
    var      = L1B.Trec(t) / sqrt( df * L1B.EffTime(t) );
    % Se
    ind      = nn1 + (1:n1);
    ii1(ind) = nf*(t-1) + i1;
    jj1(ind) = nf*(t-1) + j1;    
    ss1(ind) = var * s1;    
    nn1      = nn1 + n1;
    % Seinv
    ind      = nn2 + (1:n2);
    ii2(ind) = nf*(t-1) + i2;
    jj2(ind) = nf*(t-1) + j2;    
    ss2(ind) = (1/var) * s2;    
    nn2      = nn2 + n2;
  end
  %
  Se    = sparse( ii1, jj1, ss1, nf*ntan, nf*ntan );
  Seinv = sparse( ii2, jj2, ss2, nf*ntan, nf*ntan );

return

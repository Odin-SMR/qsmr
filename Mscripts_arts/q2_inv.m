function [L2,L2d] = q2_inv(LOG,L1B,Q)  

%  
% Basic checks of data
%
assert( L1B.FreqMode(1) == Q.FMODE );


%
% Set/create work folder
%
[R.workfolder,rm_wfolder] = q2_create_workfolder( Q );
%
if rm_wfolder
  % Make sure temporary folders are removed
  cu = onCleanup( @()q2_delete_workfolder( R.workfolder ) );
  clear rm_workfolder
end
  
  
%
% Get a priori atmosphere
%
R.ATM = q2_get_atm( LOG, Q );
%
% (Atmospheric data stored to ARTS files in q2_oemiter)


%
% Store a rough geo-position (used for HSE)
%
xmlStore( fullfile( R.workfolder, 'lat_true.xml' ), ...
                 L1B.Latitude(round(length(L1B.Latitude)/2)), ...
                                                        'Vector', 'binary' );
xmlStore( fullfile( R.workfolder, 'lon_true.xml' ), ...
                 L1B.Longitude(round(length(L1B.Longitude)/2)), ...
                                                        'Vector', 'binary' );
  
  
  
%
% Initial sensor variables 
%
R  = q2_arts_sensor_parts( L1B, Q, R );
R  = q2_arts_sensor( R );
za = R.ZA_PENCIL;
%
xmlStore( fullfile( R.workfolder, 'sensor_pos.xml' ), ...
                             repmat( R.Z_ODIN, size(za) ), 'Matrix', 'binary' );
xmlStore( fullfile( R.workfolder, 'sensor_los.xml' ), za, 'Matrix', 'binary' );
%
% Copy those parts of L1B that are needed to recalculate sensor resposnes to
% adopt to retrieved frequency off-set
R.L1B.Altitude    = L1B.Altitude;
R.L1B.Apodization = L1B.Apodization;
R.L1B.FreqMode    = L1B.FreqMode; 
R.L1B.Frequency   = L1B.Frequency;


%
% Set up things around each retrieval quantity
%
[xa,Q,R] = subfun4retqs( Q, R, L1B );
  

%
% Create full Sx and its inverse (using a function from Atmlab)
%
[Sx,Sxinv] = arts_sx( Q, R );


%
% Create Se and its inverse
%
[Se,Seinv] = subfun4se( Q, L1B );


%
% Define O
%
O = oem;
%
[O.A,O.cost,O.e,O.ga,O.yf] = deal( true );
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
R.z_field = xmlLoad( fullfile( R.workfolder, 'z_field.xml' ) );
%
[L2,L2d] = subfun4l2( R, L1B, X );

return




%---------------------------------------------------------------------------
%--- Retrieval quantities
%---------------------------------------------------------------------------

function[xa,Q,R] = subfun4retqs( Q, R, L1B )

  %
  % Create cfiles to use, with and without Jacobian calculation
  %
  R.jac_cfile = fullfile( R.workfolder, 'jacobian.arts' );
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
  R.cfile_y            = q2_artscfile_full( C, R.workfolder, 'cfile_y.arts' );
  %
  C.JACOBIAN_DO        = true;
  C.JACOBIAN_FILE      = R.jac_cfile;
  R.cfile_yj           = q2_artscfile_full( C, R.workfolder, 'cfile_yj.arts' );
  %
  clear C 

  
  % Init some of the bookkeeping variables
  R.ji    = [];    % Matches ARTS' jacobian_indices, but 1-based indexing
  R.jq    = [];    % A slim version of ARTS' jacobian_quantities
  R.i_rel = [];    % Index in x of abs- species. using rel, and not logrel
  lx      = 0;     % Length of x

  % Init array-of-string variable defining jac_file
  T{1} = 'Arts2{';
  T{2} = 'VectorCreate( empty_vector )';
  T{3} = 'VectorSet( empty_vector, [] )';
  T{4} = 'jacobianInit';

  
  % Abs specices
  % -------------------------------------------------------------------------------- 
  %
  R.i_asj = find( [ Q.ABS_SPECIES.RETRIEVE ] );
  %
  for i = R.i_asj
    %
    iq               = length(R.jq) + 1;
    np               = length( Q.ABS_SPECIES(i).GRID );
    R.jq{iq}.maintag = 'Absorption species';
    R.ji{iq}{1}      = lx + 1;
    R.ji{iq}{2}      = lx + np;
    lx               = lx + np;
    %
    if Q.ABS_SPECIES(i).LOG_ON
      R.jq{iq}.mode    = 'logrel';
    else
      R.jq{iq}.mode    = 'rel';
      R.i_rel          = [ R.i_rel R.ji{iq}{1}:R.ji{iq}{2} ];
    end
    %
    vector_name      = sprintf( 'retgrid%d', iq );
    file_name        = fullfile( R.workfolder, [vector_name,'.xml'] );
    xmlStore( file_name, Q.ABS_SPECIES(iq).GRID, 'Vector' );
    %
    T{end+1} = sprintf( 'VectorCreate( %s )', vector_name );
    T{end+1} = sprintf( 'ReadXML( %s, "%s" )', vector_name, file_name );
    T{end+1} = sprintf( 'jacobianAddAbsSpecies( species = %s,', ...
                                               arts_tgs_cnvrt(Q.ABS_SPECIES(i).TAG) );
    T{end+1} = sprintf( '   g1 = %s, g2 = empty_vector, g3 = empty_vector,', ...
                                                                        vector_name );
    T{end+1} = '   unit = "rel" )';
    %
    % A priori uncertainty: Select max between rel and abs uncertainty, but
    % don't exceed 1e6.
    R.xa_vmr{i} = interpp( R.ATM.P, R.ATM.VMR(i,:)', Q.ABS_SPECIES(i).GRID );
    std         = min( 1e6, max( Q.ABS_SPECIES(i).UNC_REL, ...
                                 Q.ABS_SPECIES(i).UNC_ABS./R.xa_vmr{i} ) );
    lc          = Q.ABS_SPECIES(i).CORRLEN/15.5e3;
    cco         = 0.001;
    %
    if 0
      % This version calculates the inverse purely numerically, in arts_sx:
      Q.ABS_SPECIES(i).SX = covmat1d_from_cfun( Q.ABS_SPECIES(i).GRID, ...
                                                [ Q.ABS_SPECIES(i).GRID, std ], ...
                                                'exp', lc, cco, @log10 );
    else
      % This version uses analytical expression for the inverse, but works
      % only for constant spacing:
      dz       = abs( diff( log10( Q.ABS_SPECIES(i).GRID ) ) );
      assert( max(abs(dz-dz(1))) < 1e-9 );
      [Q.ABS_SPECIES(i).SX,Q.ABS_SPECIES(i).SXINV] = ...
                               covmat1d_markov( length(std), std, dz(1), lc, cco );
    end
  end
  %
  clear vector_name file_name std lc cco dz

  
  % Temperature profile
  % -------------------------------------------------------------------------------- 
  %
  if Q.T.RETRIEVE
    iq               = length(R.jq) + 1;
    np               = length( Q.T.GRID );
    R.jq{iq}.maintag = 'Atmospheric temperatures';
    R.ji{iq}{1}      = lx + 1;
    R.ji{iq}{2}      = lx + np;
    lx               = lx + np;
    %
    vector_name      = sprintf( 'retgrid%d', iq );
    file_name        = fullfile( R.workfolder, [vector_name,'.xml'] );
    xmlStore( file_name, Q.T.GRID, 'Vector' );
    %
    T{end+1} = sprintf( 'VectorCreate( %s )', vector_name );
    T{end+1} = sprintf( 'ReadXML( %s, "%s" )', vector_name, file_name );
    T{end+1} = 'jacobianAddTemperature( method = "analytical",';
    T{end+1} = sprintf( '   g1 = %s, g2 = empty_vector, g3 = empty_vector,', ...
                                                                        vector_name );
    T{end+1} = '   hse = "on" )';
    %
    dz       = abs( diff( log10( Q.T.GRID ) ) );
    assert( max(abs(dz-dz(1))) < 1e-9 );
    std      = interpp( [100e2 10e2 1e2 10 1]', vec2col(Q.T.UNC), Q.T.GRID );
    [Q.T.SX,Q.T.SXINV] = covmat1d_markov( length(std), std, dz(1), ...
                                          Q.T.CORRLEN/15.5e3, 0.001 );
  end
  
  
  % Pointing off-set
  % -------------------------------------------------------------------------------- 
  %
  if Q.POINTING.RETRIEVE
    iq                = length(R.jq) + 1;
    R.jq{iq}.maintag  = 'Sensor pointing';
    R.jq{iq}.subtag   = 'Zenith angle off-set';
    lx                = lx + 1;
    R.ji{iq}{1}       = lx;
    R.ji{iq}{2}       = lx;
    %
    % Jacobian derived in *q2_oeimiter*.
    %
    var               = Q.POINTING.UNC * Q.POINTING.UNC;
    Q.POINTING.SX     = var;
    Q.POINTING.SXINV  = 1/var;
  end
  
  
  % Frequency off-set
  % -------------------------------------------------------------------------------- 
  %
  if Q.FREQUENCY.RETRIEVE
    iq                = length(R.jq) + 1;
    R.jq{iq}.maintag  = 'Frequency';
    R.jq{iq}.subtag   = 'Shift';
    lx                = lx + 1;
    R.ji{iq}{1}       = lx;
    R.ji{iq}{2}       = lx;
    %
    % Jacobian derived in *q2_oeimiter*.
    %
    var               = Q.FREQUENCY.UNC * Q.FREQUENCY.UNC;
    Q.FSHIFTFIT.SX    = var;
    Q.FSHIFTFIT.SXINV = 1/var;
  end
  
  
  % Baseline fit
  % -------------------------------------------------------------------------------- 
  %
  % We can here not use ARTS as sensor is done outside ARTS. If using ARTS
  % we would get a baseline off-set for each pencil beam spectrum. Instead J
  % is expanded in q2_oemiter to include the baseline fit.
  %
  % The columns of R.bline_ilims give the start and end index for each part
  % of the baseline fit. If sub-bands are not fit, there is only a single column.
  %
  if Q.BASELINE.RETRIEVE
    %  
    if Q.BASELINE.PIECEWISE 
      R.bline_ilims  = zeros(2,4);
      for i = 1 : 4
        is = L1B.Frequency.SubBandIndex(:,(i-1)*2+[1:2]);
        is = is(:);
        if any( is > 0 )
          R.bline_ilims(1,i) = min( is(is>0) );
          R.bline_ilims(2,i) = max( is );
        end
      end
      i              = find( R.bline_ilims(1,:) > 0 );
      R.bline_ilims  = R.bline_ilims(:,i);
    else
      R.bline_ilims  = [ 1; size(R.H_BACKE,1) ];
    end    
    %
    np               = size(R.bline_ilims,2) * length(R.ZA_BORESI);
    iq               = length(R.jq) + 1;
    R.jq{iq}.maintag = 'Polynomial baseline fit';
    R.jq{iq}.subtag  = 'Coefficient 0';  
    R.ji{iq}{1}      = lx + 1;
    R.ji{iq}{2}      = lx + np;
    lx               = lx + np;
    %
    Q.POLYFIT.SX0    = (Q.BASELINE.UNC*Q.BASELINE.UNC) * speye(np);
  end
  
  
  % Finalise and create file setting up the jacobian
  %
  T{end+1} = 'jacobianClose';
  T{end+1} = '}';
  %
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

function [Se,Seinv] = subfun4se( Q, L1B )

  % Calculate covariance matrix for one spectrum and unit variance.
  f    = L1B.Frequency.IFreqGrid(:,1);
  nf   = length( f );
  df   = L1B.FreqRes(1);
  % A correlation length of 2*df + exponential function gives a rough fit to
  % correlation between adjacent channels (0.6). 
  S    = covmat1d_from_cfun( f, 1, 'exp', 2*df, 0.001 );

  % Its inverse. This should be close to a tri-diagonal matrix. Remove all
  % very smalle elemenets to save space
  %
  Sinv = S \ speye(nf);
  %
  [i,j,s] = find( Sinv );
  n       = size(Sinv,1);
  ind     = find( abs(s) > 0.0001 );
  Sinv    = sparse(i(ind),j(ind),s(ind),n,n);  

  % Compile complete matrices by repeating S and Sinv, weighted with thermal
  % noise standard deviation.
  % This is done by determong row and column indexes, to create the final
  % sparse matrices in one go. 

  % Row, column, value, and number variables
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

  % Loop tangent altitudes / spectra
  for t = 1 : ntan

    % Standard deviation of thermal noise for t:th spectrum 
    thn = L1B.TrecSpectrum'  .* ( Q.NOISE_SCALEFAC / sqrt(df*L1B.EffTime(t)) );

    % Se
    ind      = nn1 + (1:n1);
    ii1(ind) = nf*(t-1) + i1;
    jj1(ind) = nf*(t-1) + j1;    
    ss1(ind) = thn(i1) .* thn(j1) .* s1;    
    nn1      = nn1 + n1;

    % Seinv
    ind      = nn2 + (1:n2);
    ii2(ind) = nf*(t-1) + i2;
    jj2(ind) = nf*(t-1) + j2;    
    ss2(ind) = s2 ./ ( thn(i2) .* thn(j2) );
    nn2      = nn2 + n2;
  end

  % Create the matrices
  Se    = sparse( ii1, jj1, ss1, nf*ntan, nf*ntan );
  Seinv = sparse( ii2, jj2, ss2, nf*ntan, nf*ntan );
return



%---------------------------------------------------------------------------
%--- L2
%---------------------------------------------------------------------------

function [L2,L2d] = subfun4l2( R, L1B, X )

  F = l1b_frequency( L1B );
  
  plot( F/1e9, L1B.Spectrum, '.' )
  hold on
  plot( F/1e9, reshape(X.yf,size(L1B.Spectrum) )) 
  hold off

  L2    = X;
  L2.jq = R.jq;
  L2.ji = R.ji;
  L2d   = NaN;
return
% ATMDATA_RNDMZ_BY_COVAR   Adds random disturbances of an ATMDATA variable
%
%
%       FORMAT     String giving the format used to describe the disturbances.
%                  Valid options listed below.
%       TYPE       Can either be 'abs' or 'rel'. Determines if given data 
%                  specifies an absolute or relative disturbance.  In the
%                  first case, standard deviations are given in same unit as
%                  the data, while in the second case relative values are 
%                  given (such as 0.5 for a 50% disturbance).
%       DATALIMS   Lower and upper limit for data. A vector. The first value 
%                  gives lower limit, and second value upper limit. Data 
%                  below/above a limit, is set to the limit value. 
%                  The field is not mandatory. Upper limit can be left out.
%                  If a limit is set to NaN, all values will be accepted.
%
%    The format of *covmat3d* is here used to specify the disturbances. 
%    That is, the covariance matrix for selected variability is described
%    in a parametrised way.
%
% FORMAT   G = atmdata_rndmz_by_covar( G, D)
%        
% OUT   G   Modified ATMDATA data. 
% IN    
%       G   ATMDATA  data.
%       D   Disturbance settings strucure
%
% Example usage:
%
% Example shows how to add correlated 3-dimensional noise
% with 1 K standard deviation on temperature data
%
% p_grid = vec2col( z2p_simple( [-1e3:1e3:70e3] ) );
% lat_grid = vec2col( [-10 : 10] );
% lon_grid = vec2col( [-10 : 10] );
% grids = {p_grid, lat_grid, lon_grid};
% fascod_data_path = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', ...
%                                    'Earth', 'Fascod', 'tropical' );
% datafile = fullfile(fascod_data_path, 'tropical.t.xml');
% G{1} = gf_artsxml(datafile, 'temperature','t_field');
% G= asg_regrid(G,grids);
% RND.FORMAT    = 'param';
% RND.SEPERABLE = 1;
% RND.CCO       = 0.01;               % Cut-off for correlation values 
% RND.TYPE      = 'abs';              % Absolute disturbances as default
% RND.SI        = 1;                  % 1 K as default
% RND.DATALIMS  = [0];                % Do not allow negative values
% RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
% RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
% RND.CL1_GRID1 = [1100e2 10e2 1e-3];    
% RND.CFUN2     = 'lin';              % Linear correlation function for lat-dim.
% RND.CL2       = 0.5;                % Corr. length 0.5 deg everywhere
% RND.CFUN3     = 'lin';              % Linear correlation function for lat-dim.
% RND.CL3       = 0.5;                % Corr. length 0.5 deg everywhere
% G1 = atmdata_rndmz_by_covar( G{1}, RND)
 
% 2007-10-22   Created by Patrick Eriksson.
% 2014-08-29   Modified by Bengt Rydberg.

function G = atmdata_rndmz_by_covar( G , RNDMZ)

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert
  rqre_datatype( G, @isatmdata );
end
  
G = do_param( G, RNDMZ);
    
%- Remove too low values
if isfield( RNDMZ, 'DATALIMS' )
  if ~isnan( RNDMZ.DATALIMS(1) )
    ind = find( G.DATA < RNDMZ.DATALIMS(1) );
    G.DATA(ind) = RNDMZ.DATALIMS(1);
  end
  if length( RNDMZ.DATALIMS ) > 2  &  ~isnan( RNDMZ.DATALIMS(1) )
    ind = find( G.DATA > RNDMZ.DATALIMS(2) );
    G.DATA(ind) = RNDMZ.DATALIMS(2);
  end
end

%------------------------------------------------------------------------------
function G = do_param( G, RNDMZ )

  %- Check G.DIM and determine dimensionality
  %
  dim = G.DIM;
  %
  if isempty(dim)
    error( '0D data not handled' );
  end
  
  %- Create covariance matrix for disturbance
  %
  % Use try-catch for more informative error message
  %
  try
    S = covmat3d( dim, RNDMZ, G.GRID1, G.GRID2, G.GRID3, 'atm' );
  catch 
    fprintf( '%s\n\n', lasterr );
    error( sprintf('Incorrect covariance definition.') );
  end

  %- Create disturbance (loop around cases)
  %
  if strcmp( RNDMZ.TYPE, 'rel' )
    for ic = 1 : size( G.DATA, 4 )
      G.DATA(:,:,:,ic) = G.DATA(:,:,:,ic) .* ...
              reshape( randmvar_normal2( 1, S, 1 ), size(G.DATA(:,:,:,ic)) );
    end
  elseif strcmp( RNDMZ.TYPE, 'abs' )
    for ic = 1 : size( G.DATA, 4 )
      G.DATA(:,:,:,ic) = G.DATA(:,:,:,ic) + ...
              reshape( randmvar_normal2( 0, S, 1 ), size(G.DATA(:,:,:,ic)) );
    end
    
  else
    error( 'Unknown selection in RNDMZ.TYPE.' );
  end
  
return


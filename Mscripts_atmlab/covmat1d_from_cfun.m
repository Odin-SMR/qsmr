% COVMAT1D_FROM_CFUN   Correlation function based covariance matrix
%
%    This function sets up a covariance matrix from a defined correlation 
%    function. The correlation function is specified by giving a functional
%    form (such as exponential decreasing) and correlation lengths. The
%    correlation length is throughout defined as the distance where the 
%    correlation has dropped to exp(-1). For off-diagonal values, the 
%    correlation length is averaged between the two involved positions.
%
%    Correlation matrices are obtained by setting *Std* to [].
%
% FORMAT   S = covmat1d_from_cfun( xp, Std, cfun, Cl, [, cco, mapfun] )
%        
% OUT   S      The covariance matrix
% IN    xp     The data abscissa.
%       Std    Standard deviations. Given as a two column matrix. First column
%              holds position in same unit as *xp*. The second column is the 
%              standard deviation at the postions of the first column. These
%              values are then interpolated to *xp*, extrapolating end
%              values to +-Inf (in a "nearest" manner).
%              If set to a scalar, this value is applied for all *xp*.
%              If set to [], unit standard deviation is assumed.
%       cfun   Correlation function. Possible choices are
%               'drc' : Dirac. No correlation. Any given correlation length
%                       is ignored here.
%               'lin' : Linearly decreasing (down to zero).
%               'exp' : Exponential decreasing (exp(-dx/cl)).
%               'gau' : Gaussian (normal) deceasing (exp(-(dx/cl))^2).
% OPT   Cl     Correlation lengths. Given as a column matrix as *Std*.
%              Must be given for all *cfun* beside 'drc'. Extrapolation as
%              for *Std*. Scalar input is allowed.
%       cco    Correlation cut-off. All values below this limit are set to 0.
%       mapfun Mapping function from grid unit to unit for correlation
%              lengths. For example, if correlation lengths are given in
%              pressure decades, while the basic coordinate is Pa, this is
%              *mapfun* handled by setting *mapfun* to @log10. 

% 2005-05-20   Created by Patrick Eriksson.


function S = covmat1d_from_cfun(xp,Std,cfun,varargin)
%
[Cl,cco,mapfun] = optargs( varargin, { [], 0, [] } );


%- Determine standard deviations
%
n  = length( xp );
%
if isempty( Std )
  si = ones( n, 1 );
elseif isscalar( Std )
  si = repmat( Std, n, 1 );
else  
  si = interp1( Std(:,1), Std(:,2), handle_expand(Std(:,1),xp) );
end


%= Handle diagonal matrices separately (note return)
%
if strcmp( lower(cfun), 'drc' )
  %
  S = sparse( 1:n, 1:n, si.^2, n, n );
  return
  %
end


%= Conversion of length unit
%
if ~isempty(mapfun)
  if ~isa( mapfun, 'function_handle' )
    error( 'Input *mapfun* must be empty or a function handle.' );
  end
  xp = mapfun( xp );
  if ~isscalar( Cl )
    Cl(:,1) = mapfun( Cl(:,1) );
  end
end


%= Distance matrix
%
[X1,X2] = meshgrid( xp, xp );
D       = abs( X1 - X2 );


%= Correlation length matrix 
%
if isscalar( Cl )
  L = Cl;
else
  cl = interp1( Cl(:,1), Cl(:,2), handle_expand(Cl(:,1),xp) );
  [X1,X2] = meshgrid( cl, cl );
  L       = ( X1 + X2 ) / 2;
  %
  clear X1 X2
end


%= Create correlation matrix
%
switch lower(cfun)

  case 'lin'
    %
    S = 1 - (1-exp(-1)) * ( D./L );
    % Negativa values removed by cco

  case 'exp'
    %
    S = exp( -D./L );

  case 'gau'
    %
    S = exp( -(D./L).^2 );

  otherwise                                                                 %&%
    %                                                                       %&%
    error( sprintf('Unknown correlation function (%s)',cfun) );             %&%
end


%- Remove values below correlation cut-off limit, convert to sparse and
%- include standard deviations
%
S( find( S < cco )) = 0;
%
[i,j,s] = find( S );
S       = (si*si') .* sparse( i, j, s, n, n );

return



%---
function xi = handle_expand(x,xi)
  %
  v1 = min( x );
  i1 = find( xi<v1 );
  %
  v2 = max( x );
  i2 = find( xi>v2 );
  %
  if ~isempty(v1) 
    xi(i1) = v1;
  end
  %
  if ~isempty(v2) 
    xi(i2) = v2;
  end
  %
return
